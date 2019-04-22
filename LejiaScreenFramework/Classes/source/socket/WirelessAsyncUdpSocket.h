//
//  WirelessAsyncUdpSocket.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SOCKET_TIME_OUT 2
//udp
#define UDP_IOS_PORT 1001
#define SOCKET_PORT 1000
#define SOCKET_BROADCAST_IP @"192.168.49.255"

#define TAG_SOCKET_RECEIVE 1000
#define TAG_SOCKET_SEND_BROAD 2000
#define TAG_SOCKET_SEND_HUD 2001
#define TAG_SOCKET_SEND_HUD_GET_VERSION 2001

typedef void(^UDPSuccessBlock)(NSString *,NSInteger,NSInteger,NSInteger);
typedef void(^UDPNotFindHudBlock)(void);
typedef void(^UDPErrorBlock)(NSError *);



NS_ASSUME_NONNULL_BEGIN

@interface WirelessAsyncUdpSocket : NSObject
+ (WirelessAsyncUdpSocket *)sharedManager;
+(void)attemptDealloc;

-(void)findHud:(UDPSuccessBlock) successBlock notFindBlock:(UDPNotFindHudBlock)notFindBlock errorBlock:(UDPErrorBlock) errorBlock;

@end

NS_ASSUME_NONNULL_END
