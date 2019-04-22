//
//  GCDDelay.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//


#import "GCDDelay.h"

@implementation GCDDelay
+(void)gcdLater:(NSTimeInterval)time block:(gcdBlock)block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_global_queue(0,0), block);
}

+(GCDTask)gcdDelay:(NSTimeInterval)time task:(gcdBlock)block
{
    __block dispatch_block_t closure = block;
    __block GCDTask result;
    GCDTask delayedClosure = ^(BOOL cancel){
        if (closure) {
            if (!cancel) {
                dispatch_async(dispatch_get_global_queue(0,0), closure);
            }
        }
        closure = nil;
        result = nil;
    };
    result = delayedClosure;
    [self gcdLater:time block:^{
        if (result)
            result(NO);
    }];
    
    return result;
}

+(void)gcdCancel:(GCDTask)task
{
    task(YES);
}

+(void)gcdTest
{
    GCDTask task = [self gcdDelay:2 task:^{
        NSLog(@"oc output after 5 seconds");
    }];
    [self gcdCancel:task];
}

@end
