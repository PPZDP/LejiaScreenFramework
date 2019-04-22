//
//  GCDDelay.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^GCDTask)(BOOL cancel);
typedef void(^gcdBlock)(void);

@interface GCDDelay : NSObject

+(GCDTask)gcdDelay:(NSTimeInterval)time task:(gcdBlock)block;
+(void)gcdCancel:(GCDTask)task;

+(void)gcdTest;

@end



NS_ASSUME_NONNULL_END
