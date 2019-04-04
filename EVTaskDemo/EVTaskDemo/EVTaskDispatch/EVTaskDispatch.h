//
//  EVTaskDispatch.h
//  EVTaskDemo
//
//  Created by Ever on 2019/4/3.
//  Copyright © 2019 Ever. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//任务优先级
typedef enum : NSUInteger {
    EVTaskPriorityLow,
    EVTaskPriorityNormal,
    EVTaskPriorityHigh,
} EVTaskPriority;

/*
 任务派遣类
 适用场景: 占用主线程时间过长、且可以延迟执行的任务；例如：在App启动时，一些三方库的注册、用户信息的同步 等；
 内部原理: 监控主线程 runloop，当即将休眠时，取出一个之前添加的任务，并在主线程执行；
 */

@interface EVTaskDispatch : NSObject

+ (instancetype)shared;

/**
 添加任务

 @param target 对象
 @param action 方法
 @param priority 优先级
 
 对于相同的任务，只会添加一次
 */
- (void)addTaskWithTarget:(NSObject *)target action:(SEL)action priority:(EVTaskPriority)priority;

/**
 是否包含某项任务

 @param target 对象
 @param action 方法
 @param result 是否包含该任务回调
 */
- (void)containsTaskWithTarget:(NSObject *)target action:(SEL)action result:(void(^)(BOOL isContains))result;

@end

NS_ASSUME_NONNULL_END
