//
//  CRTcpError.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    init     = -10000,
    disConnect,
    coder,
    beginOrEnd,
    getVersion,
    sof,
    downloading,
    eof,
    getCmac,
    noSuchMsg
} CRTcpErrorCode;

@interface CRTcpError : NSObject


+ (NSError *)errorCode:(CRTcpErrorCode)code userInfo:(NSDictionary *)dic;
+ (NSString *)transformCodeToStringInfo:(CRTcpErrorCode)code;
@end
