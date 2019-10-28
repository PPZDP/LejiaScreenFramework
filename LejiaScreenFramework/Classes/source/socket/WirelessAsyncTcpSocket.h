//
//  WirelessAsyncTcpSocket.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


#define MSG @"msg"
#define DATA @"data"
//tcp
#define TAG_SOCKET_TCP_WRITE  4000
#define TCP_IOS_PORT  8880
#define imgSize 0.5


typedef NS_ENUM(NSInteger,CRUpgradeState) {
    
    
    CRUpgradeStateErrorTcpInit     = -10000,
    CRUpgradeStateErrorTcpDisConnect,
    CRUpgradeStateErrorTcpCoder,
    CRUpgradeStateErrorTcpBeginOrEnd,
    CRUpgradeStateErrorTcpGetVersion,
    CRUpgradeStateErrorTcpSof,
    CRUpgradeStateErrorTcpDownloading,
    CRUpgradeStateErrorTcpEof,
    
    
    CRUpgradeStateNormal,
    
    CRUpgradeStateFindHUD,
    CRUpgradeStateNotFindHUD,
    CRUpgradeStateFindHUDError,
    
    
    CRUpgradeStateConnectHUD,
    CRUpgradeStateGetVersionSuccess,
    CRUpgradeStateGetVersionFail,
    
    CRUpgradeStateNew,
    CRUpgradeStateDownloadFail,
    CRUpgradeStateUpgrading,
    CRUpgradeStateSuccess,
    CRUpgradeStateFail,
    
    CRUpgradeStateUnzipFail,
    
    
    
    
};

typedef NS_ENUM(NSInteger,CRSocketOfflineStyle){
    CRSocketOfflineByServer,// 服务器掉线，默认为0
    CRSocketOfflineByUser,  // 用户主动cut
};

typedef NS_ENUM(NSInteger,CRUpgradeHUDState){
    CRUpgradeHUDStateNormal,
    CRUpgradeHUDStateConnect,
    CRUpgradeHUDStateGetVersion,
    CRUpgradeHUDStateReady,
    CRUpgradeHUDStateSof,
    CRUpgradeHUDStateDownloading,
    CRUpgradeHUDStateEof,
    CRUpgradeHUDStateEnd,
    CRUpgradeHUDStateError,
};


@protocol CRAsyncTcpSocketDelegate <NSObject>
@optional
-(void)CRTcpDidConnectHost;
-(void)CRTcpProgramError;
-(void)CRTcpProgramError:(NSError*)error;
-(void)CRTcpGetVersionSuccess:(NSDictionary *)dic;
-(void)CRTcpGetMacAddrSuccess:(NSDictionary *)dic;
-(void)CRTcpResponse:(NSDictionary *)dic state:(CRUpgradeHUDState)upgradeHUDState;
//OBD数据
//-(void)CRTcpResponseOBDRealTimeModel:(CROBDRealTimeModel *)OBDRealTimeModel;

-(void)CRTcpGetSpeedFactor;
-(void)CRTcpSetSpeedFactorState:(NSString *)state;
-(void)CRTcpGetBrightLevel;
-(void)CRTcpSetBrightLevelState:(NSString *)state;
-(void)CRTcpGetAtacct;
-(void)CRTcpSetAtacctState:(NSString *)state;

@end



typedef void(^TCPSuccessBlock)(void);
typedef void(^statusBlock)(NSDictionary *);
typedef void(^errorBlock)(NSError *);
typedef void(^TCPNotFindHudBlock)(void);
typedef void(^TCPErrorBlock)(NSError *);

typedef void(^ConnectHostBlock)(GCDAsyncSocket *);
typedef void(^ReceiveDataBlock)(void);


typedef void(^BrightLevelBlock)(NSString *);
typedef void(^SpeedUnitBlock)(NSString *);
typedef void(^SpeedfactorBlock)(NSString *);
typedef void(^AtacctBlock)(NSString *);
typedef void(^RomUpgradeBlock)(NSDictionary *);
@interface WirelessAsyncTcpSocket : NSObject

+ (WirelessAsyncTcpSocket *)sharedManager;
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket_info;
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket_screen;
@property(nonatomic,assign)BOOL isFirst;
@property(nonatomic,assign)BOOL isFirstInfo;
@property(nonatomic,strong)NSData *screenData;
+(void)attemptDealloc;


-(void)sendHUDData:(NSData *)data;
-(void)sendHeartBeat;
-(void)getSpeedCorrectParam;
-(void)getVersion :(RomUpgradeBlock)romUpgradeBlock;
-(void)getBrightLevel:(BrightLevelBlock)brightLevelBlock;
-(void)getAtacct;
-(void)getCmac;
-(void)getVersionInfo;
-(void)setBrightLevel:(NSInteger)level  brightLevelBlock:(BrightLevelBlock)brightLevelBlock ;

-(void)getSpeedUnit:(SpeedUnitBlock)getspeedunitblock;
-(void)setSpeedUnit:(SpeedUnitBlock)setspeedunitblock spustr:(NSString *)spustr;

-(void)setAtacct:(NSString *)timeString atacctBlock:(AtacctBlock)atacctBlock;
- (BOOL)isDataChannelConnect;

-(void)upgrade;

-(void)cutOffSocketScreen;
-(void)cutOffSocketInfo;


//3. 开始下载升级包
-(void)beginLoadName:(NSString *)fileName;
//4.传输数据
-(void)downloadingFileOffset:(NSNumber *)offset payload:(NSNumber *)payload data:(NSString *)data;
//5.升级包传输完成
-(void)downloadEof:(NSString *)filename len:(NSNumber *)fileLength;
//6. 升级结束
-(void)dowloadEnd;


-(void)registerCRAsyncTcpSocketDelegate:(id<CRAsyncTcpSocketDelegate>)delegate;



- (void)socketConnectTcpForInfo:(NSString *)strIP screenPort:(NSInteger )screenPort  interPort:(NSInteger)interPort successBlock: (TCPSuccessBlock)successBlock notFindHudBlock:(TCPNotFindHudBlock)notFindHudBlock errorBlock:(TCPErrorBlock)errorBlock connectHostBlock:(ConnectHostBlock)connectHostBlock receiveDataBlock:(ReceiveDataBlock)receiveDataBlock;

- (void)socketConnectTcpForScreen:(NSString *)strIP screenPort:(NSInteger)screenPort interPort:(NSInteger)interPort customView:(NSData *)screenData successBlock:(TCPSuccessBlock)successBlock notFindHudBlock:(TCPNotFindHudBlock)notFindHudBlock errorBlock:(TCPErrorBlock)errorBlock connectHostBlock:(ConnectHostBlock)connectHostBlock receiveDataBlock:(ReceiveDataBlock)receiveDataBlock;

-(void)sendUpgradeFile:(NSString *) filePath fileName:(NSString *)fileName statusBlock:(void(^)(NSDictionary *)) statusBlock errorBlock:(void(^)(NSError *))errorBlock;
@end


