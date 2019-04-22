//
//  HUDWAYProjectManager.m
//  CocoaAsyncSocket
//
//  Created by sos1a2a3a on 2019/4/22.
//


#import "HUDWAYProjectManager.h"
#import "WirelessAsyncUdpSocket.h"
#import "WirelessAsyncTcpSocket.h"
#import "ScreenMacro.h"
#import <pthread.h>
typedef NS_ENUM(NSInteger,CRCommunicationModel) {
    CRCommunicationModelNormal = 0,
    CRCommunicationModelUpgrade
};

@interface HUDWAYProjectManager ()
@property(nonatomic,strong)id screenData;
@property (nonatomic,strong) NSString *strIP;
@property (nonatomic,assign) NSInteger interPort;
@property (nonatomic,assign) NSInteger OBDPort;
@property(nonatomic,assign)NSInteger screenPort;
@property(nonatomic,strong)dispatch_source_t times;
@property(nonatomic,strong)dispatch_source_t udpTimes;
@property(nonatomic,strong)dispatch_source_t times_info;
@property(nonatomic,strong)NSTimer *cTimerSendHeartBeat;
@property(nonatomic,strong)dispatch_queue_t connectTcpQueue;
@property(nonatomic,strong)dispatch_queue_t connectTcpInfoQueue;
@property(nonatomic,assign)BOOL isUnusual;
@property (nonatomic,assign) CRCommunicationModel communicationModel;
@end

static id sharedManagerInstance;
static dispatch_once_t onceToken;
@implementation HUDWAYProjectManager

+ (HUDWAYProjectManager *)sharedManager
{
    dispatch_once(&onceToken, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}
+(void)attemptDealloc{
    sharedManagerInstance = nil;
    onceToken=0l;
}

#pragma mark private
- (void)findHud
{
    //    AILogVerbose(@"SplitScreen:udp 定时器开始");
    if (self.isConnectTcp && self.isConnectTcpInfo) {
        //        AILogVerbose(@"SplitScreen: udp 定时器结束");
        return;
    }
    //        [WirelessAsyncUdpSocket  attemptDealloc];
    @weakify(self);
    [[WirelessAsyncUdpSocket sharedManager ] findHud:^(NSString * strIP, NSInteger interPort, NSInteger OBDPort, NSInteger screenPort) {
        //        AILogVerbose(@"SplitScreen:udp success %@ %ld %ld %ld",strIP,(long)interPort,(long)OBDPort,(long)screenPort);
        @strongify(self);
        self.isUnusual=NO;
        [self deallocUdpTime];
        self.strIP = strIP;
        self.interPort = interPort;
        self.OBDPort = OBDPort;
        self.screenPort = screenPort;
        [self startTime];
        [WirelessAsyncUdpSocket  attemptDealloc];
        //        AILogVerbose(@"SplitScreen:udp 定时器结束");
        
    } notFindBlock:^{
        @strongify(self);
        //        AILogVerbose(@"SplitScreen:udp notFind");
        [self udpTimes];
        //        [self findHud];
        //self.isConnectTcp = NO;
        //        AILogVerbose(@"SplitScreen:udp 定时器结束");
        
    } errorBlock:^(NSError *error) {
        @strongify(self);
        //        AILogVerbose(@"SplitScreen:udp error %@",error);
        [self udpTimes];
        //        [self findHud];
        //        AILogVerbose(@"SplitScreen:udp 定时器结束");
    }];
}

- (dispatch_queue_t)connectTcpInfoQueue
{
    if (!_connectTcpInfoQueue) {
        _connectTcpInfoQueue = dispatch_queue_create("com.socket.tcpInfo", DISPATCH_QUEUE_CONCURRENT);
    }
    return _connectTcpInfoQueue;
}
- (dispatch_queue_t)connectTcpQueue
{
    if (!_connectTcpQueue) {
        _connectTcpQueue = dispatch_queue_create("com.socket.tcpScreen", DISPATCH_QUEUE_CONCURRENT);
    }
    return _connectTcpQueue;
}
- (void)startTime
{
    if (!self.isConnectTcpInfo) {
        @weakify(self);
        dispatch_async(self.connectTcpInfoQueue, ^{
            @strongify(self);
            [self conectTcpInfo];
        });
    }
    if (!self.isConnectTcp) {
        @weakify(self);
        dispatch_async(self.connectTcpQueue, ^{
            @strongify(self);
            [self connectTcp];
        });
    }
    
}

-(void)startScreenTcp
{
    //    AILogVerbose(@"SplitScreen:screen tcp  定时器开始");
    @synchronized(self){
        if (!self.isConnectTcp) {
            @weakify(self);
            dispatch_async(self.connectTcpQueue, ^{
                @strongify(self);
                [self connectTcp];
            });
        }
        else
        {
            [self deallocTime];
        }
        
    }
}
-(void)startInfoTcp
{
    //    AILogVerbose(@"SplitScreen:info screen 定时器开始");
    @synchronized(self){
        if (!self.isConnectTcpInfo) {
            @weakify(self);
            dispatch_async(self.connectTcpInfoQueue, ^{
                @strongify(self);
                [self conectTcpInfo];
            });
        }
        else
        {
            [self deallocTimeinfo];
        }
    }
}

-(void)conectTcpInfo
{
    if (_isUnusual) {
        return;
    }
    @weakify(self);
    [[WirelessAsyncTcpSocket sharedManager] socketConnectTcpForInfo:self.strIP screenPort:self.screenPort interPort:self.interPort successBlock:^{
        //        @strongify(self);
        
    } notFindHudBlock:^{
        @strongify(self);
        self.isConnectTcpInfo = NO;
        [self times_info];
        //        [WirelessAsyncTcpSocket  attemptDealloc];
        //        [self.tcpLock unlock];
        //        [self connectTcp];
        
        //        AILogVerbose(@"SplitScreen:info tcp notFind");
        
    } errorBlock:^(NSError *error) {
        @strongify(self);
        self.isConnectTcpInfo = NO;
        //        [self connectTcp];
        if (!self.isUnusual) {
            [self times_info];
        }
        
        //        [WirelessAsyncTcpSocket  attemptDealloc];
        //         [self.tcpLock unlock];
        //        AILogVerbose(@"SplitScreen:info tcp  error %@",error);
    } connectHostBlock:^(GCDAsyncSocket *socket) {
        @strongify(self);
        //        AILogVerbose(@"SplitScreen:info tcp success");
        //        [self.lock unlock];
        [self deallocTimeinfo];
        
        self.isConnectTcpInfo = YES;
        
        //        [self tcpDidConnectHost:socket];
        //         [self.tcpLock unlock];
        
    } receiveDataBlock:^{
        @strongify(self);
        [self CRTcpReceiveData];
    }];
    
}
-(void)CRTcpReceiveData
{
    if (self.cTimerSendHeartBeat.isValid) {
        [self.cTimerSendHeartBeat invalidate];
    }
    @weakify(self);
    dispatch_async_on_main_queue(^{
        @strongify(self);
        self.cTimerSendHeartBeat = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerLifeCycle) userInfo:nil repeats:NO];
    });
}

-(void)connectTcp
{
    //    [self.tcpLock lock];
    if (_isUnusual) {
        return;
    }
    @weakify(self);
    [[WirelessAsyncTcpSocket sharedManager] socketConnectTcpForScreen:self.strIP screenPort:self.screenPort interPort:self.interPort customView:self.screenData successBlock:^{
        @strongify(self);
        [self deallocTime];
        self.isConnectTcp = YES;
        //        if (self.isConnectTcpInfo) {
        //        [self deallocTime];
        //        }
        //        AILogVerbose(@"SplitScreen:screen tcp success");
    } notFindHudBlock:^{
        @strongify(self);
        
        self.isConnectTcp = NO;
        [self times];
        //        [WirelessAsyncTcpSocket  attemptDealloc];
        //        [self.tcpLock unlock];
        //        [self connectTcp];
        
        //        AILogVerbose(@"SplitScreen:screen tcp notFind");
        
    } errorBlock:^(NSError *error) {
        @strongify(self);
        self.isConnectTcp = NO;
        if (error.code == -100) {
            //            AILogVerbose(@"SplitScreen:error.code =-100");
            if (!self.isUnusual) {
                self.isUnusual = YES;
                [self deallocTime];
                [self deallocTimeinfo];
                [self deallocUdpTime];
                [WirelessAsyncTcpSocket attemptDealloc];
                //延迟3秒
                @weakify(self);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    @strongify(self);
                    [self udpTimes];
                });
            }
        }
        else{
            if (!self.isUnusual) {
                [self times];
            }
            
        }
        
        //         [self.tcpLock unlock];
        //        AILogVerbose(@"SplitScreen:screen tcp error %@",error);
    } connectHostBlock:^(GCDAsyncSocket *socket) {
        
        
    } receiveDataBlock:^{
        
    }];
    
}
//
//-(void)tcpDidConnectHost:(GCDAsyncSocket *)sock
//{
//    if ([WirelessAsyncTcpSocket sharedManager].asyncSocket_info == sock) {
//
//        if (self.communicationModel == CRCommunicationModelNormal) {
//            [[WirelessAsyncTcpSocket sharedManager] getSpeedCorrectParam];
//            [[WirelessAsyncTcpSocket sharedManager] getVersionInfo];
//            [[WirelessAsyncTcpSocket sharedManager] getBrightLevel];
//            [[WirelessAsyncTcpSocket sharedManager] getAtacct];
//            [[WirelessAsyncTcpSocket sharedManager] getCmac];
//
//        }
//    }
//    if (self.cTimerSendHeartBeat) {
//        if (self.cTimerSendHeartBeat.isValid) {
//            [self.cTimerSendHeartBeat invalidate];
//        }
//        self.cTimerSendHeartBeat= nil;
//    }
//    @weakify(self);
//    dispatch_async_on_main_queue(^{
//        @strongify(self);
//        self.cTimerSendHeartBeat = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerLifeCycle) userInfo:nil repeats:NO];
//
//    });
//}

-(void)timerLifeCycle
{
    if(self.communicationModel != CRCommunicationModelNormal)
    {
        return;
    }
    
    [self sendHeartBeat];
}

-(void)sendHeartBeat
{
    [[WirelessAsyncTcpSocket sharedManager] sendHeartBeat];
}
- (void)deallocTime
{
    if (_times) {
        dispatch_source_cancel(_times);
        _times = nil;
    }
    
}

- (void)deallocTimeinfo
{
    if (_times_info) {
        dispatch_source_cancel(_times_info);
        _times_info = nil;
    }
    
}

- (void)deallocUdpTime
{
    if (_udpTimes) {
        dispatch_source_cancel(_udpTimes);
        _udpTimes = nil;
    }
    
}

- (void)dealloc
{
    
}

- (dispatch_source_t )times
{
    if (!_times) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //        dispatch_queue_t queue = dispatch_get_main_queue();
        _times = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_times, dispatch_walltime(NULL, 0), 10 * NSEC_PER_SEC, 0);
        @weakify(self);
        dispatch_source_set_event_handler(_times, ^{
            @strongify(self);
            [self startScreenTcp];
        });
        dispatch_resume(_times);
    }
    return _times;
}


- (dispatch_source_t )times_info
{
    if (!_times_info) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //        dispatch_queue_t queue = dispatch_get_main_queue();
        _times_info = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_times_info, dispatch_walltime(NULL, 0), 10 * NSEC_PER_SEC, 0);
        @weakify(self);
        dispatch_source_set_event_handler(_times_info, ^{
            @strongify(self);
            [self startInfoTcp];
        });
        dispatch_resume(_times_info);
    }
    return _times_info;
}

- (dispatch_source_t )udpTimes
{
    if (!_udpTimes) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //        dispatch_queue_t queue = dispatch_get_main_queue();
        _udpTimes = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_udpTimes, dispatch_walltime(NULL, 0), 10 * NSEC_PER_SEC, 0);
        @weakify(self);
        dispatch_source_set_event_handler(_udpTimes, ^{
            @strongify(self);
            [self findHud];
        });
        dispatch_resume(_udpTimes);
    }
    return _udpTimes;
}
static inline void dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


#pragma mark public
- (void)start:(id)data
{
    self.screenData = data;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    @weakify(self);
    dispatch_async(queue, ^{
        @strongify(self);
        [self findHud];
    });
}
-(void)stop
{
    self.isUnusual = YES;
    [self deallocTime];
    [self deallocUdpTime];
    [self deallocTimeinfo];
    self.isConnectTcp = NO;
    self.isConnectTcpInfo = NO;
    [self releaseData];
    [WirelessAsyncUdpSocket attemptDealloc];
    [WirelessAsyncTcpSocket  attemptDealloc];
    
}

-(void)releaseData
{
    self.screenData = nil;
    [WirelessAsyncTcpSocket sharedManager].screenData = nil;
}
-(void)getBrightLevel:(void(^)(NSString *))brightLevelBlock;
{
    [[WirelessAsyncTcpSocket sharedManager ] getBrightLevel:brightLevelBlock];
}
-(void)setBrightLevel:(NSInteger)level brightLevelBlock:(void(^)(NSString *))brightLevelBlock;
{
    [[WirelessAsyncTcpSocket sharedManager ] setBrightLevel:level brightLevelBlock:brightLevelBlock];
}
-(void)getSpeedunitStr:(void(^)(NSString *))speedUnitBlock;
{
    [[WirelessAsyncTcpSocket sharedManager ] getSpeedUnit:speedUnitBlock];
}
-(void)setSpeedunitStr:(NSString *)spustr speedUnitBlock:(void(^)(NSString *)) speedUnitBlock;
{
    [[WirelessAsyncTcpSocket sharedManager ] setSpeedUnit:speedUnitBlock spustr:spustr];
}
-(void)sendUpgradeFile:(NSString *) filePath fileName:(NSString *)fileName statusBlock:(void(^)(NSDictionary *)) statusBlock errorBlock:(void(^)(NSError *))errorBlock{
    
    [[WirelessAsyncTcpSocket sharedManager] sendUpgradeFile:filePath fileName:fileName statusBlock:statusBlock errorBlock:errorBlock];
    
}

-(void)mappingScreenData:(id)screenData
{
    self.screenData = screenData;
    [WirelessAsyncTcpSocket sharedManager ].screenData = screenData;
}


@end
