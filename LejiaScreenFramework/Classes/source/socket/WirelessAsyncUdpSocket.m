//
//  WirelessAsyncUdpSocket.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import "WirelessAsyncUdpSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDDelay.h"
#import "DTNetworkTools.h"
#import "ScreenMacro.h"
#import "Tool.h"
@interface WirelessAsyncUdpSocket()<GCDAsyncUdpSocketDelegate>
@property(nonatomic,strong)GCDAsyncUdpSocket *cSocket;
@property(nonatomic,copy)UDPSuccessBlock successBlock;
@property(nonatomic,copy)UDPNotFindHudBlock notFindBlock;
@property(nonatomic,copy)UDPErrorBlock errorBlock;
@property(nonatomic,copy)GCDTask task;
@end
static id sharedManagerInstance;
static dispatch_once_t onceToken;
@implementation WirelessAsyncUdpSocket

+ (WirelessAsyncUdpSocket *)sharedManager
{
    dispatch_once(&onceToken, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}
+(void)attemptDealloc{
    [[self sharedManager]resetSocket];
    if (sharedManagerInstance) {
        sharedManagerInstance = nil;
        onceToken=0l;
    }
}
- (void)findHud:(UDPSuccessBlock)successBlock notFindBlock:(UDPNotFindHudBlock)notFindBlock errorBlock:(UDPErrorBlock)errorBlock
{
    
    self.successBlock = successBlock;
    self.notFindBlock = notFindBlock;
    self.errorBlock = errorBlock;
    [self resetSocket];
    NSString *strBroadcastIp = [DTNetworkTools getBroadcastIp];
    if (!strBroadcastIp) {
        [self errorInfo:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"error":@"获取不到IP地址"}]];
        return;
    }
    [self initSingleSocket];
    [self sendBroadDic:[self broadCastDic]];
    
}

-(void)resetSocket
{
    if (self.cSocket) {
        [self.cSocket close];
        [self.cSocket setDelegate:nil delegateQueue:nil];
        self.cSocket = nil;
    }
    
}
-(void)errorInfo:(NSError *)error
{
    [self resetSocket];
    if (self.errorBlock) {
        self.errorBlock(error);
    }
}
-(void)initSingleSocket
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    GCDAsyncUdpSocket *cSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];
    self.cSocket = cSocket;
    NSError *errorBind;
    [cSocket bindToPort:SOCKET_PORT error:&errorBind];
    if (errorBind) {
        [self errorInfo:errorBind];
    }
    NSError *errorEnable;
    [cSocket enableBroadcast:YES error:&errorEnable];
    if (errorEnable) {
        [self errorInfo:errorEnable];
    }
    else
    {
        [cSocket beginReceiving:&errorEnable];
        if (errorEnable) {
            [self errorInfo:errorEnable];
        }
    }
    
    
}
-(NSDictionary *)broadCastDic
{
    return @{@"msg":@"reqConn"};
}
-(void)sendBroadDic:(NSDictionary *)dict
{
    NSString *strBroadcastIp = [DTNetworkTools getBroadcastIp];
    if (!strBroadcastIp) {
        [self errorInfo:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"error":@"获取不到IP地址"}]];
        return;
    }
    
    [self sendDic:dict toHost:strBroadcastIp port:SOCKET_PORT withTimeout:5 tag:TAG_SOCKET_SEND_BROAD];
}

-(void)sendDic:(NSDictionary *)dic toHost:(NSString *)host port:(UInt16)port withTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str =  [Tool dictionaryToJson:dic];
    NSData *data=[str dataUsingEncoding:encode];
    [self.cSocket sendData:data toHost:host port:port withTimeout:timeout tag:tag];
    
    @weakify(self);
    self.task = [GCDDelay gcdDelay:5 task:^{
        @strongify(self);
        [self requestTimeout];
    }];
    
    
}
-(void)requestTimeout
{
    
    [self resetSocket];
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC));
    @weakify(self);
    dispatch_after(delayTime, dispatch_get_global_queue(0,0), ^{
        @strongify(self);
        [self errorInfo:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"error":@"udp 超时"}]];
    });
}
#pragma mark - AsyncUdpSocketDelegate
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    //    [self errorInfo:error];
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //字符串再生成NSData
    NSData * receivedata = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    //再解析
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:receivedata options:NSJSONReadingMutableLeaves error:nil];
    NSDictionary  *cDicResult = jsonDict;
    // NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    AILogVerbose(@"SplitScreen:%@...%@",cDicResult,result);
    if ([cDicResult objectForKey:@"msg"]) {
        [self processMessage:cDicResult[@"msg"] data:cDicResult];
    }
}
-(void)notFindHUD
{
    [self resetSocket];
    if (self.notFindBlock) {
        self.notFindBlock();
    }
}

-(void)processMessage:(NSString *)msg data:(NSDictionary *)cDicResult
{
    if ([msg isEqualToString:@"reqConn"]) {
        if(cDicResult[@"ip"]&&cDicResult[@"factoryPort"]){
            if (self.successBlock) {
                //                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestTimeout) object:nil];
                [GCDDelay gcdCancel:self.task];
                self.successBlock(cDicResult[@"ip"], [cDicResult[@"factoryPort"] integerValue], [cDicResult[@"OBDPort"] integerValue], 8880);
            }
        }else{
            
            //            AILogVerbose(@"SplitScreen:收到广播数据：%@",cDicResult);
        }
        
    }
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    [self errorInfo:error];
}
@end
