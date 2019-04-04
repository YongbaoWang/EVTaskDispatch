//
//  EVTaskDispatch.m
//  EVTaskDemo
//
//  Created by Ever on 2019/4/3.
//  Copyright © 2019 Ever. All rights reserved.
//

#import "EVTaskDispatch.h"
#import <CoreFoundation/CFRunLoop.h>

@interface EVTaskDispatch ()

@property (nonatomic, strong) NSMapTable<NSObject *, NSMutableArray *> *lowPriorityTaskMapTable;
@property (nonatomic, strong) NSMapTable<NSObject *, NSMutableArray *> *normalPriorityTaskMapTable;
@property (nonatomic, strong) NSMapTable<NSObject *, NSMutableArray *> *highPriorityTaskMapTable;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (nonatomic, assign) CFRunLoopObserverRef observerRef;

@end

@implementation EVTaskDispatch

static EVTaskDispatch *_dispatch = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dispatch = [[EVTaskDispatch alloc] init];
        
        _dispatch.lowPriorityTaskMapTable = [NSMapTable weakToStrongObjectsMapTable];
        _dispatch.normalPriorityTaskMapTable = [NSMapTable weakToStrongObjectsMapTable];
        _dispatch.highPriorityTaskMapTable = [NSMapTable weakToStrongObjectsMapTable];
        
        _dispatch.serialQueue = dispatch_queue_create("com.ever.evtaskdispatch", DISPATCH_QUEUE_SERIAL);
        
        _dispatch.observerRef = nil;
    });
    return _dispatch;
}

- (void)addRunLoopObserver {
    self.observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, &runLoopObserverCallBack, NULL);
    CFRunLoopAddObserver(CFRunLoopGetMain(), self.observerRef, kCFRunLoopDefaultMode);
    CFRelease(self.observerRef);
}

- (void)removeRunLoopObserver {
    if (self.observerRef) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observerRef, kCFRunLoopDefaultMode);
        self.observerRef = nil;
    }
}

void (runLoopObserverCallBack)(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    [_dispatch beginDispatchTaskProcess];
}

- (void)beginDispatchTaskProcess {
    dispatch_async(_dispatch.serialQueue, ^{

        NSMapTable *mapTable = [self getOneValidMapTable];
        
        if (mapTable == nil) {
            [self removeRunLoopObserver];
            return;
        }
        
        NSEnumerator *enumerator = [mapTable keyEnumerator];
        NSObject *target = enumerator.nextObject;
        
        if (target == nil) {
            return;
        }
        
        id value = [mapTable objectForKey:target];
        
        if ([value isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *valueArrayM = (NSMutableArray *)value;
            NSString *action = [valueArrayM firstObject];
            
            SEL selector = NSSelectorFromString(action);
            if([target respondsToSelector:selector]) {
                [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
            }
            
            if (valueArrayM.count <= 1) {
                [mapTable removeObjectForKey:target];
            } else {
                [valueArrayM removeObjectAtIndex:0];
                [mapTable setObject:target forKey:valueArrayM];
            }
        } else {
            NSAssert(false, @"EVTaskDispatch Error:runLoopObserverCallBack Error! value type must be NSMutableArray.In fact is:%@",value);
        }

    });
}

- (NSMapTable *)getOneValidMapTable {
    BOOL (^checkMapTableBlock)(NSMapTable *) = ^BOOL(NSMapTable *mapTable) {
        return NSAllMapTableKeys(mapTable).count > 0;
    };
    
    NSMapTable *mapTable = nil;
    
    if (checkMapTableBlock(_dispatch.highPriorityTaskMapTable)) {
        mapTable = _dispatch.highPriorityTaskMapTable;
    } else if (checkMapTableBlock(_dispatch.normalPriorityTaskMapTable)) {
        mapTable = _dispatch.normalPriorityTaskMapTable;
    } else if( checkMapTableBlock(_dispatch.lowPriorityTaskMapTable)) {
        mapTable = _dispatch.lowPriorityTaskMapTable;
    }
    
    return mapTable;
}

- (BOOL)containsTaskWithTarget:(NSObject *)target action:(SEL)action priority:(EVTaskPriority)priority {
    if (target == nil || action == nil) {
        return NO;
    }
    NSMapTable *mapTable = priority == EVTaskPriorityHigh ? self.highPriorityTaskMapTable : (priority == EVTaskPriorityNormal ? self.normalPriorityTaskMapTable : self.lowPriorityTaskMapTable);
    id value = [mapTable objectForKey:target];
    
    if ([value isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *valueArrayM = (NSMutableArray *)value;
        
        if([valueArrayM containsObject:NSStringFromSelector(action)]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Public API
- (void)addTaskWithTarget:(NSObject *)target action:(SEL)action priority:(EVTaskPriority)priority {
    dispatch_async(self.serialQueue, ^{
        NSMapTable *mapTable = priority == EVTaskPriorityHigh ? self.highPriorityTaskMapTable : (priority == EVTaskPriorityNormal ? self.normalPriorityTaskMapTable : self.lowPriorityTaskMapTable);
        
        id value = [mapTable objectForKey:target];
        if (value == nil) {
            value = [NSMutableArray array];
        }
        if ([value isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *valueArrayM = (NSMutableArray *)value;
            NSString *actionName = NSStringFromSelector(action);
            if (![valueArrayM containsObject:actionName]) {
                [valueArrayM addObject:actionName];
            }
            [mapTable setObject:valueArrayM forKey:target];
            
            if (self.observerRef == nil) {
                [self addRunLoopObserver];
                CFRunLoopWakeUp(CFRunLoopGetMain());
            }
        } else {
            NSAssert(false, @"EVTaskDispatch Error:%@:value type must be NSMutableArray.In fact is:%@",NSStringFromClass(self.class),value);
        }
    });
}

- (void)containsTaskWithTarget:(NSObject *)target action:(SEL)action result:(void(^)(BOOL isContains))result {
    dispatch_async(self.serialQueue, ^{
        BOOL isContains = NO;
        isContains = [self containsTaskWithTarget:target action:action priority:EVTaskPriorityNormal];
        if (!isContains) {
            isContains = [self containsTaskWithTarget:target action:action priority:EVTaskPriorityLow];
        }
        if (!isContains) {
            isContains = [self containsTaskWithTarget:target action:action priority:EVTaskPriorityHigh];
        }
        if (result) {
            result(isContains);
        }
    });
}

- (void)setHighPriorityTaskMapTable:(NSMapTable<NSObject *,NSMutableArray *> *)highPriorityTaskMapTable {
    _highPriorityTaskMapTable = highPriorityTaskMapTable;
}

@end
