//
//  FZViewController.m
//  FZTimerEngine
//
//  Created by wufuzeng on 07/30/2019.
//  Copyright (c) 2019 wufuzeng. All rights reserved.
//

#import "FZViewController.h"
#import "FZTimerEngine.h"
@interface FZViewController ()

@end

@implementation FZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[FZTimerEngine sharedTimer] registerAction:^(NSTimeInterval timeinterval) {
        NSLog(@"%ld",(long)timeinterval);
    } frequency:10 name:@"key1"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FZTimerEngine sharedTimer] removeActionForName:@"key1"];
    });
}



@end
