//
//  CRDataManager.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import "CRDataManager.h"

@implementation CRDataManager

+ (CRDataManager *)sharedManager
{
    static CRDataManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

//+(void)setVersion:(NSString *)version
//{
//    [CRDataManager sharedManager].version = version;
//}
@end
