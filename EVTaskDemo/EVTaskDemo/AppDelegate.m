//
//  AppDelegate.m
//  EVTaskDemo
//
//  Created by Ever on 2019/4/3.
//  Copyright © 2019 Ever. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "EVTaskDispatch.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //添加两个不同优先级的任务
//    [[EVTaskDispatch shared] addTaskWithTarget:self action:@selector(task1) priority:EVTaskPriorityHigh];
//    [[EVTaskDispatch shared] addTaskWithTarget:self action:@selector(task2) priority:EVTaskPriorityLow];
    
    //vc 为临时变量；vc释放后，添加的该任务，将不再执行；
    ViewController *vc = [ViewController new];
    [[EVTaskDispatch shared] addTaskWithTarget:vc action:@selector(print) priority:EVTaskPriorityHigh];
    
        [[EVTaskDispatch shared] addTaskWithTarget:self action:@selector(task1) priority:EVTaskPriorityHigh];

    NSLog(@"didFinish end");
    
    return YES;
}

- (void)task1 {
    NSLog(@"dispatch appdelegate task 1");
}

- (void)task2 {
    NSLog(@"dispatch appdelegate task 2");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
