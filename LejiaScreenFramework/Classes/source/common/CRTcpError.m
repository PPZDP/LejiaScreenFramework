//
//  CRTcpError.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//


#import "CRTcpError.h"
static NSDictionary *errorDictionary = nil;
@implementation CRTcpError
+ (void)initialize
{
    if (self == [CRTcpError class])
    {
        errorDictionary = \
        @{
          @(init)        :        @"init",
          @(disConnect)  :        @"disConnect",
          @(coder)       :        @"coder",
          @(beginOrEnd)  :        @"beginOrEnd",
          @(getVersion)  :        @"getVersion",
          @(sof)         :        @"sof",
          @(downloading) :        @"downloading",
          @(eof)         :        @"eof",
          @(getCmac)     :        @"getCmac",
          @(noSuchMsg)   :        @"noSuchMsg"
          };
    }
}

+ (NSError *)errorCode:(CRTcpErrorCode)code userInfo:(NSDictionary *)dic
{
    return [NSError errorWithDomain:errorDictionary[@(code)]
                               code:code
                           userInfo:dic];
}

+ (NSString *)transformCodeToStringInfo:(CRTcpErrorCode)code
{
    return errorDictionary[@(code)];
}
@end
