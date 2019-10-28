//
//  CRSocketMsgAssistManager.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import "CRSocketMsgAssistManager.h"
#import "WirelessAsyncTcpSocket.h"
#import "Tool.h"
#import <pthread.h>
//#import "CRAsyncTcpSocket.h"

#define MsgTimeOut 2
//数据暂存管理
/*
 管理规则：
 1.暂存管理会将所添加的数据按顺序逐个完成发送、等待返回
 */
@interface CRSocketMsgAssistManager ()
@property(nonatomic,strong)NSMutableArray *arrMutMsgs;
@property(nonatomic,strong)NSTimer *timer;
@end
@implementation CRSocketMsgAssistManager

+ (CRSocketMsgAssistManager *)sharedManager
{
    static CRSocketMsgAssistManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
        sharedManagerInstance.arrMutMsgs = [[NSMutableArray alloc] init];
    });
    return sharedManagerInstance;
}
+(void)sendData:(NSDictionary *)dic
{
    
    CRSocketMsgAssistManager *manager = [CRSocketMsgAssistManager sharedManager];
    [manager.arrMutMsgs addObject:dic];
    if ([manager.arrMutMsgs count]==1) {
        [manager socketSendData:dic];
        if (manager.timer.isValid) {
            [manager.timer invalidate];
        }
        dispatch_async_on_main_queue(^{
//            manager.timer = [NSTimer scheduledTimerWithTimeInterval:MsgTimeOut target:manager selector:@selector(timerMsgTimeOut) userInfo:nil repeats:NO];
        });
        
    }else{
        //有没有返回的数据等待返回
    }
    
}
+(void)socketReceiveData:(NSDictionary *)dic
{
    CRSocketMsgAssistManager *manager = [CRSocketMsgAssistManager sharedManager];
    if (manager.timer) {
        [manager.timer invalidate];
    }
    [manager socketReceiveData:dic];
}
-(void)socketReceiveData:(NSDictionary *)dic
{
    CRSocketMsgAssistManager *manager = [CRSocketMsgAssistManager sharedManager];
    if ([manager.arrMutMsgs count]>0) {
        [manager.arrMutMsgs removeObjectAtIndex:0];
        if ([manager.arrMutMsgs count]>0) {
            [manager socketSendData:[manager.arrMutMsgs firstObject]];
        }
    }
}
-(void)socketSendData:(NSDictionary *)dic
{
    //    BLYLogInfo(@"socket发送的数据：%@",dic);
    WirelessAsyncTcpSocket *asyncTcpSocket = [WirelessAsyncTcpSocket sharedManager];
    NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str =  [Tool dictionaryToJson:dic];
    NSData *data=[str dataUsingEncoding:encode];
    [asyncTcpSocket.asyncSocket_info writeData:data withTimeout:2 tag:TAG_SOCKET_TCP_WRITE];
}
-(void)timerMsgTimeOut
{
    CRSocketMsgAssistManager *manager = [CRSocketMsgAssistManager sharedManager];
    if ([manager.arrMutMsgs count]) {
        NSDictionary *dic = [manager.arrMutMsgs firstObject];
        NSString *strMsg = dic[@"msg"];
        if (strMsg&&[strMsg isEqualToString:@"ping"]) {
        }else{
            //  [CRSocketMsgAssistManager tcpProgramError:[CRTcpError errorCode:disConnect userInfo:@{@"description":@"通信超时"}]];
        }
    }
    
    [manager socketReceiveData:@{@"data":@"timeOut"}];
    
}
+(void)tcpProgramError:(NSError *)error{
    //    WirelessAsyncTcpSocket *asyncTcpSocket = [WirelessAsyncTcpSocket sharedManager];
    //    if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpProgramError:)]) {
    //        [asyncTcpSocket.delegate CRTcpProgramError:error];
    //    }
}
+(void)disable
{
    CRSocketMsgAssistManager *manager = [CRSocketMsgAssistManager sharedManager];
    if (manager.timer.isValid) {
        [manager.timer invalidate];
    }
    if ([manager.arrMutMsgs count]) {
        [manager.arrMutMsgs removeAllObjects];
    }
}

static inline void dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
@end
