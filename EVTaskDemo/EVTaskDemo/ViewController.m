//
//  ViewController.m
//  EVTaskDemo
//
//  Created by Ever on 2019/4/3.
//  Copyright © 2019 Ever. All rights reserved.
//

#import "ViewController.h"
#import "EVTaskDispatch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[EVTaskDispatch shared] addTaskWithTarget:self action:@selector(task1) priority:EVTaskPriorityNormal];
    
    //查询是否添加了某个任务
    [[EVTaskDispatch shared] containsTaskWithTarget:self action:@selector(task1) result:^(BOOL isContains) {
        
    }];
    
    NSLog(@"view did load");
}

- (void)task1 {
    NSLog(@"dispatch vc task");
}

- (void)print {
    NSLog(@"%@",self);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

@end
