//
//  CRSocketMsgAssistManager.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRSocketMsgAssistManager : NSObject

+ (CRSocketMsgAssistManager *)sharedManager;
+(void)sendData:(NSDictionary *)dic;
+(void)socketReceiveData:(NSDictionary *)dic;
+(void)disable;

@end

NS_ASSUME_NONNULL_END
