//
//  WirelessAsyncTcpSocket.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WirelessAsyncTcpSocket.h"
#import "CRSocketMsgAssistManager.h"
#import "ScreenMacro.h"
#import "CRTcpError.h"
#import "CRHUDUpLoadingFileManager.h"


@interface WirelessAsyncTcpSocket() <GCDAsyncSocketDelegate,CRHUDUpLoadingFileManagerDelegate>
@property(nonatomic,assign)CRUpgradeHUDState upgradeHUDState;

@property(nonatomic,copy)TCPSuccessBlock successBlockScreen;
@property(nonatomic,copy)TCPNotFindHudBlock notFindHudBlockScreen;
@property(nonatomic,copy)TCPErrorBlock errorBlockScreen;


@property(nonatomic,copy)TCPSuccessBlock successBlockInfo;
@property(nonatomic,copy)TCPNotFindHudBlock notFindHudBlockInfo;
@property(nonatomic,copy)TCPErrorBlock errorBlockInfo;
@property(nonatomic,copy)ConnectHostBlock connectHostBlockInfo;
@property(nonatomic,copy)ReceiveDataBlock receiveDataBlockInfo;
@property(nonatomic,copy)RomUpgradeBlock romUpgradeBlockInfo;

@property(nonatomic,assign)CRUpgradeState upgradeState;
@property(nonatomic,assign)CRSocketOfflineStyle socketOfflineStyle;

@property(nonatomic,weak)id<CRAsyncTcpSocketDelegate> delegate;

@property(nonatomic,assign)BOOL ison;
@property(nonatomic,strong) NSRecursiveLock *lock;
@property(nonatomic,strong)dispatch_source_t times;
@property(nonatomic,assign)NSInteger index;


@property(nonatomic,copy)BrightLevelBlock getbrightLevelBlock;
@property(nonatomic,copy)BrightLevelBlock brightLevelBlock;
@property(nonatomic,copy)SpeedUnitBlock getSpeedUnitBlock;
@property(nonatomic,copy)SpeedUnitBlock setSpeedUnitBlock;
@property(nonatomic,copy)SpeedfactorBlock  speedfactorBlock;
@property(nonatomic,copy)AtacctBlock atacctBlock;


@property(nonatomic,strong)CRHUDUpLoadingFileManager *upLoadingFileManager;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,copy)NSString *fileName;
@property(nonatomic,copy)statusBlock  statusBlock;
@property(nonatomic,copy)errorBlock   errorBlock;

@end
static id sharedManagerInstance;
static dispatch_once_t onceToken;

@implementation WirelessAsyncTcpSocket

+ (WirelessAsyncTcpSocket *)sharedManager
{
    dispatch_once(&onceToken, ^{
        sharedManagerInstance = [[self alloc] init];
        
    });
    return sharedManagerInstance;
}
+(void)attemptDealloc{
//    AILogVerbose(@"SplitScreen:TCP 销毁.");
    
    [self sharedManager].isFirst = NO;
    [[self sharedManager] cutOffSocketInfo];
    [[self sharedManager] cutOffSocketScreen];
    if (sharedManagerInstance) {
        sharedManagerInstance = nil;
        onceToken=0l;
    }
    
}
- (void)dealloc
{
//    AILogVerbose(@"SplitScreen:TCP 释放成功.");
}

- (void)socketConnectTcpForScreen:(NSString *)strIP screenPort:(NSInteger)screenPort interPort:(NSInteger)interPort customView:(id )screenData successBlock:(TCPSuccessBlock)successBlock notFindHudBlock:(TCPNotFindHudBlock)notFindHudBlock errorBlock:(TCPErrorBlock)errorBlock connectHostBlock:(ConnectHostBlock)connectHostBlock receiveDataBlock:(ReceiveDataBlock)receiveDataBlock
{
    [self  cutOffSocketScreen];
    self.screenData = screenData;
    if ([screenData isKindOfClass:[UIView class]]) {
    
    }
    else if([screenData isKindOfClass:[NSData class]])
    {
        
    }
    else
    {
        [self errorInfo:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"error":@"screenData must NSData,UIView  "}]socket:self.asyncSocket_screen];
        
        return ;
    }
    
    
    self.successBlockScreen = successBlock;
    self.notFindHudBlockScreen = notFindHudBlock;
    self.errorBlockScreen = errorBlock;
    dispatch_queue_t queue = dispatch_queue_create("com.socket.tcpScreen", DISPATCH_QUEUE_CONCURRENT);
    self.asyncSocket_screen  = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    NSError *error_screen = nil;
    [self.asyncSocket_screen connectToHost:strIP onPort:screenPort withTimeout:-1 error:&error_screen];
    if (error_screen) {
        [self errorInfo:error_screen socket:self.asyncSocket_screen];
    }
    else
    {
//        AILogVerbose(@"SplitScreen:asyncSocket_screen 初始化");
    }
}

- (void)socketConnectTcpForInfo:(NSString *)strIP screenPort:(NSInteger)screenPort interPort:(NSInteger)interPort successBlock:(TCPSuccessBlock)successBlock notFindHudBlock:(TCPNotFindHudBlock)notFindHudBlock errorBlock:(TCPErrorBlock)errorBlock connectHostBlock:(ConnectHostBlock)connectHostBlock receiveDataBlock:(ReceiveDataBlock)receiveDataBlock
{
    [self  cutOffSocketInfo];
    self.receiveDataBlockInfo = receiveDataBlock;
    self.connectHostBlockInfo= connectHostBlock;
    self.successBlockInfo = successBlock;
    self.notFindHudBlockInfo = notFindHudBlock;
    self.errorBlockInfo = errorBlock;
    
    dispatch_queue_t queue_info = dispatch_queue_create("com.socket.tcpInfo", DISPATCH_QUEUE_CONCURRENT);
    
    self.asyncSocket_info = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue_info];
    NSError *error_asyncSocket_info = nil;
    [self.asyncSocket_info connectToHost:strIP onPort:interPort withTimeout:-1 error:&error_asyncSocket_info];
    if (error_asyncSocket_info) {
        [self errorInfo:error_asyncSocket_info socket:self.asyncSocket_info];
    }
    else
    {
//        AILogVerbose(@"SplitScreen:asyncSocket_info 初始化.");
    }
}



-(void)cutOffSocketScreen
{
    self.isFirst = NO;
    self.screenData = nil;
    self.socketOfflineStyle = CRSocketOfflineByUser;
    if (self.asyncSocket_screen) {
        [self.asyncSocket_screen disconnect];
        [self.asyncSocket_screen setDelegate:nil delegateQueue:nil];
        self.asyncSocket_screen= nil;
        
    }
    if (_times) {
        dispatch_source_cancel(_times);
        _times = nil;
    }
}
-(void)cutOffSocketInfo
{
    self.isFirstInfo = NO;
    if (self.asyncSocket_info) {
        [self.asyncSocket_info disconnect];
        [self.asyncSocket_info setDelegate:nil delegateQueue:nil];
        self.asyncSocket_info = nil;
    }
}



- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    
    if (sock == self.asyncSocket_screen) {
        [self.asyncSocket_screen readDataWithTimeout:-1 tag:0];
        self.ison = YES;
        if (!self.isFirst) {
            [self startScreenInit];
            if (self.successBlockScreen) {
                self.successBlockScreen();
            }
        }
        self.isFirst = YES;
        
    }
    else if(sock == self.asyncSocket_info)
    {
        self.upgradeHUDState = CRUpgradeHUDStateConnect;
        [self.asyncSocket_info readDataWithTimeout:-1 tag:0];
        if (!self.isFirstInfo) {
            if (self.connectHostBlockInfo) {
                self.connectHostBlockInfo(sock);
            }
        }
        self.isFirstInfo = YES;
        
    }
    self.socketOfflineStyle = CRSocketOfflineByServer;
    
}
- (void)close
{
    [self cutOffSocketInfo];
}

//获取HUDmac地址
-(void)getCmac
{
    [self writeData:[self macAddr]];
}
///获取速度矫正参数
-(void)getSpeedCorrectParam{
    [self writeData:[self correctParam]];
}


///获取连读等级
-(void)getBrightLevel:(BrightLevelBlock)brightLevelBlock
{
    self.getbrightLevelBlock = brightLevelBlock;
    [self writeData:[self getBrightLevelDic]];
}
///设置亮度等级
-(void)setBrightLevel:(NSInteger)level brightLevelBlock:(BrightLevelBlock)brightLevelBlock
{
    self.brightLevelBlock = brightLevelBlock;
    [self writeData:[self setBrightLevelDic:level-1]];
}

///获取延迟断电参数
-(void)getAtacct
{
    [self writeData:@{MSG:@"getatacct"}];
}
-(void)getSpeedUnit:(SpeedUnitBlock)getspeedunitblock
{
    self.getSpeedUnitBlock = getspeedunitblock;
    [self writeData:@{MSG:@"getspeedunit"}];
}
-(void)setSpeedUnit:(SpeedUnitBlock)setspeedunitblock spustr:(NSString *)spustr
{
    self.setSpeedUnitBlock = setspeedunitblock;
    [self writeData:[self setSpeedUnitStr:spustr]];
}

-(NSDictionary *)setSpeedUnitStr:(NSString *)spustr
{
    return @{MSG:@"setspeedunit",DATA:spustr};
}


///设置延迟断电参数 ok/error
-(void)setAtacct:(NSString *)timeString atacctBlock:(AtacctBlock)atacctBlock
{
    self.atacctBlock= atacctBlock;
    if (timeString&&timeString.length<4) {
        NSInteger interTimerStringLenght = timeString.length;
        if (interTimerStringLenght == 1) {
            timeString = [NSString stringWithFormat:@"000%@",timeString];
        }else if (interTimerStringLenght == 2) {
            timeString = [NSString stringWithFormat:@"00%@",timeString];
        }else if (interTimerStringLenght == 3) {
            timeString = [NSString stringWithFormat:@"0%@",timeString];
        }
    }else{
        timeString = @"90";
    }
    [self writeData:@{MSG:@"setatacct",DATA:[NSString stringWithFormat:@"ATACCT%@",timeString]}];
}


//写数据
-(void)writeData:(NSDictionary*)dic
{
    [CRSocketMsgAssistManager sendData:dic];
}

-(void)getVersionInfo
{
    [self writeData:[self getVersionDic]];
}

//1.获取版本号
-(void)getVersion:(RomUpgradeBlock)romUpgradeBlock
{
//    AILogVerbose(@"SplitScreen getVersion");
    if (romUpgradeBlock!=nil) {
        self.romUpgradeBlockInfo = romUpgradeBlock;
    }
    [self writeData:[self getVersionDic]];
}


//2. 通知升级开始
-(void)upgrade
{
    [self writeData:[self notiUpgredaStartDic]];
}
//3. 开始下载升级包
-(void)beginLoadName:(NSString *)fileName
{
    [self writeData:[self sof:fileName ]];
}
//4.传输数据
-(void)downloadingFileOffset:(NSNumber *)offset payload:(NSNumber *)payload data:(NSString *)data
{
    [self writeData:[self downloadingOffset:offset payload:payload data:data]];
}
//5.升级包传输完成
-(void)downloadEof:(NSString *)filename len:(NSNumber *)fileLength
{
    [self writeData:[self eof:filename lenth:fileLength]];
}
//6. 升级结束
-(void)dowloadEnd
{
    [self writeData:[self upgradeEnd]];
}

/*
 1. 获取版本号：
 请求{“msg”:”version”}
 响应{“msg”:”version”, “data”:”xxxxxxxx”}
 */
-(NSDictionary *)getVersionDic
{
    return @{MSG:@"version"};
}
/*
 2. 通知升级开始：
 请求{“msg”:”upgrade”, “data”:”start"}
 响应{“msg”:”upgrade”, “data”:”ready"}
 */
-(NSDictionary *)notiUpgredaStartDic
{
    return @{MSG:@"upgrade",DATA:@"start"};
}
/*
 3. 开始下载升级包：
 请求{“msg”:”sof”, “name”:”filename”, “len”:filelength}
 响应{“msg”:”sof”, “data”:”ready”}
 */
-(NSDictionary *)sof:(NSString *)filename
{
    return @{MSG:@"sof",@"name":filename};
}
/*
 4. 传输数据：
 请求{“msg”:”downloading”, “offset”:1234, “payload”:5678, “data”:“base64 encode string”}
 响应{“msg”:”downloading”, “offset”:1234, “data”:”ok/error”} // error就重传当前数据包
 payload 是base64编码之前的字节数
 data 是base64编码后，去掉回车的字符串
 */
-(NSDictionary *)downloadingOffset:(NSNumber *)offset payload:(NSNumber *)payload data:(NSString *)data
{
    return @{MSG:@"downloading",@"offset":offset,@"payload":payload,DATA:data};
}
/*
 5. 升级包传输完成：
 请求{“msg”:”eof”, “name”:”filename”}
 响应{“msg”:”eof”,”data”:”ok/error”} // error 就重传文件
 */
-(NSDictionary *)eof:(NSString *)filename lenth:(NSNumber *)filelength
{
    return @{MSG:@"eof",@"name":filename,@"len":filelength};
}
/*
 6. 升级结束：
 请求{“msg”:”upgrade”, “data”:”end”}
 响应{“msg”:”upgrade”, “data”:”success/md5error/failed”}
 */
-(NSDictionary *)upgradeEnd
{
    return @{MSG:@"upgrade",DATA:@"end"};
}
/*
 获取萝卜mac地址
 请求{“msg”:”upgrade”, “data”:”end”}
 响应{“msg”:”upgrade”, “data”:”success/md5error/failed”}
 */
-(NSDictionary *)macAddr
{
    return @{MSG:@"macAddr"};
}
/*
 获取速度矫正参数
 请求{“msg”:”getspeedfactor”}
 响应{“msg”:”setspeedfactor”, “data”:”kParam bParam/”}
 */
-(NSDictionary *)correctParam
{
    return @{MSG:@"getspeedfactor"};
}
/*
 设置速度矫正参数
 请求{"msg":"setspeedfactor", "data":"kParam bParam"}
 响应
 传递参数有误：
 {"msg":"setspeedfactor", "data":"data section error"}
 设置正确：
 {"msg":"setspeedfactor", "data":"ok"}
 设置出错：
 {"msg":"setspeedfactor", "data":"error"}
 */
-(NSDictionary *)correctParamK:(CGFloat)k b:(CGFloat)b
{
    return @{MSG:@"setspeedfactor",DATA:[NSString stringWithFormat:@"%f %f",k,b]};
}

/*
 获取亮度数据
 请求{“msg”:”getbrightlevel”}
 响应{“msg”:”getbrightlevel”, “data”:”%d”}
 */
-(NSDictionary *)getBrightLevelDic
{
    return @{MSG:@"getbrightlevel"};
}
/*
 设置速度矫正参数
 请求{"msg":"setbrightlevel", "data":"0-5"}
 响应
 传递参数有误：
 {"msg":"setbrightlevel", "data":"error","value":"%d"}
 设置正确：
 {"msg":"setbrightlevel", "data":"ok","value":"%d"}
 */
-(NSDictionary *)setBrightLevelDic:(NSInteger)level
{
    return @{MSG:@"setbrightlevel",DATA:[NSNumber numberWithInteger:level]};
}

/*
 心跳包
 */
-(void)sendHeartBeat
{
    [self writeData:@{MSG:@"ping"}];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    [self.asyncSocket_screen readDataWithTimeout:-1 tag:0];
    [self.asyncSocket_info readDataWithTimeout:-1 tag:0];
    if(sock == self.asyncSocket_screen)
    {
        NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        //        AILogVerbose(@"SplitScreen:tcp didReadData %@ ",result);
        if (result !=nil) {
            self.ison=YES;
        }
    }
    else if(sock == self.asyncSocket_info)
    {
        
        NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //字符串再生成NSData
        NSData * receivedata = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
        //再解析
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:receivedata options:NSJSONReadingMutableLeaves error:nil];
        NSDictionary  *cDicResult = jsonDict;
        
//        if (cDicResult == nil) {
//            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//            NSString *strTemp = [[NSString alloc] initWithData:data encoding:enc];
//            cDicResult = [strTemp objectFromAIJSONString];
//        }
        if ([cDicResult objectForKey:@"msg"]) {
            [self processMessage:cDicResult[@"msg"] data:cDicResult];
        }
    }
    else
    {
        //        NSLog(@"sock:%@",sock);
    }
}
-(void)processMessage:(NSString *)msg data:(NSDictionary *)cDicResult
{
    [CRSocketMsgAssistManager socketReceiveData:cDicResult];
    if (self.receiveDataBlockInfo) {
        self.receiveDataBlockInfo();
    }
    if ([msg isEqualToString:@"version"]) {
//        AILogVerbose(@"SplitScreen setVersion");
        if (cDicResult[DATA]) {
            self.upgradeHUDState = CRUpgradeHUDStateGetVersion;
            NSString *strData = cDicResult[DATA];
            if ([strData isKindOfClass:[NSString class]]&&strData.length) {
//                [CRDataManager setVersion:strData];
            }
            if (self.romUpgradeBlockInfo) {
                self.romUpgradeBlockInfo(cDicResult);
            }
            //            CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
            //            if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpGetVersionSuccess:)]) {
            //                [asyncTcpSocket.delegate CRTcpGetVersionSuccess:cDicResult];
            //            }
        }else{
            self.upgradeHUDState = CRUpgradeHUDStateError;
            // [CRAsyncTcpSocket tcpProgramError];
            // [CRAsyncTcpSocket tcpProgramError:[CRTcpError errorCode:getVersion userInfo:@{@"description":@"获取版本号失败"}]];
        }
        
        
    }else if ([msg isEqualToString:@"upgrade"]) {
        if ([cDicResult[DATA] isEqualToString:@"ready"]||[cDicResult[DATA] isEqualToString:@"upgrade already started"]) {
            self.upgradeHUDState = CRUpgradeHUDStateReady;
            if (self.statusBlock) {
                self.statusBlock(@{@"status":@"CRUpgradeHUDStateReady"});
            }
            [self tcpUpdateResponse:cDicResult state:self.upgradeHUDState];
            //  [CRAsyncTcpSocket tcpUpdateResponse:cDicResult state:asyncTcpSocket.upgradeHUDState];
        }else if ([cDicResult[DATA] isEqualToString:@"success"]||[cDicResult[DATA] isEqualToString:@"installing"]) {
            self.upgradeHUDState = CRUpgradeHUDStateEnd;
            if (self.statusBlock) {
                self.statusBlock(@{@"status":@"CRUpgradeHUDStateEnd"});
            }
//            AILogVerbose(@"SplitScreen CRUpgradeHUDStateEnd");
            [self tcpUpdateResponse:cDicResult state:self.upgradeHUDState];
            
            //  [CRAsyncTcpSocket cutOffSocket];
        }else{
            self.upgradeHUDState = CRUpgradeHUDStateError;
            // [CRAsyncTcpSocket tcpProgramError];
            [self tcpProgramError:[CRTcpError errorCode:beginOrEnd userInfo:@{@"description":@"通知开始或结束失败"}]];
        }
        
    }else if ([msg isEqualToString:@"sof"]) {
        if ([cDicResult[DATA] isEqualToString:@"ready"]) {
            self.upgradeHUDState = CRUpgradeHUDStateSof;
            if (self.statusBlock) {
                self.statusBlock(@{@"status":@"CRUpgradeHUDStateSof"});
            }
            [self tcpUpdateResponse:cDicResult state:self.upgradeHUDState];
        }else{
            self.upgradeHUDState = CRUpgradeHUDStateError;
            //  [CRAsyncTcpSocket tcpProgramError];
            [self tcpProgramError:[CRTcpError errorCode:sof userInfo:@{@"description":@"开始下载升级包失败"}]];
        }
        
    }else if ([msg isEqualToString:@"downloading"]) {
        if ([cDicResult[DATA] isEqualToString:@"ok"]) {
            self.upgradeHUDState = CRUpgradeHUDStateDownloading;
            if (self.statusBlock) {
                self.statusBlock(@{@"status":@"CRUpgradeHUDStateDownloading"});
            }
            [self tcpUpdateResponse:cDicResult state:self.upgradeHUDState];
        }else{
            self.upgradeHUDState = CRUpgradeHUDStateError;
            //  [CRAsyncTcpSocket tcpProgramError];
            [self tcpProgramError:[CRTcpError errorCode:downloading userInfo:@{@"description":@"传输数据失败"}]];
        }
        
    }else if ([msg isEqualToString:@"eof"]) {
        if ([cDicResult[DATA] isEqualToString:@"ok"]) {
            self.upgradeHUDState = CRUpgradeHUDStateEof;
            if (self.statusBlock) {
                self.statusBlock(@{@"status":@"CRUpgradeHUDStateEof"});
            }
            [self tcpUpdateResponse:cDicResult state:self.upgradeHUDState];
        }else{
            self.upgradeHUDState = CRUpgradeHUDStateError;
            // [CRAsyncTcpSocket tcpProgramError];
            [self tcpProgramError:[CRTcpError errorCode:downloading userInfo:@{@"description":@"升级包传输完成失败"}]];
        }
        
    }else if ([msg isEqualToString:@"macAddr"]) {
        NSString *strMac = cDicResult[DATA];
        if ([strMac isKindOfClass:[NSString class]]&&strMac.length) {
//            [CRDataManager setCMacAddr:strMac];
            //   CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
            if ([self.delegate respondsToSelector:@selector(CRTcpGetMacAddrSuccess:)]) {
                [self.delegate CRTcpGetMacAddrSuccess:cDicResult];
            }
        }else{
            
            //               BLYLogInfo(@"获取HUDmac地址失败");
        }
        
    }else if ([msg isEqualToString:@"getspeedfactor"]) {
        
        NSString *strData = cDicResult[DATA];
        if (strData&&strData.length) {
            NSArray *arrTemp = [strData componentsSeparatedByString:@" "];
            if ([arrTemp count]==2) {
                NSString *strK = [arrTemp firstObject];
                NSString *strB = [arrTemp lastObject];
                if (strK&&strB) {
//                    [CRDataManager setFK:[strK floatValue]];
//                    [CRDataManager setFB:[strB floatValue]];
                }
            }
        }
        
        //    CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
        //    if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpGetSpeedFactor)]) {
        //        [asyncTcpSocket.delegate CRTcpGetSpeedFactor];
        //    }
    }else if ([msg isEqualToString:@"setspeedfactor"]) {
        NSString *strData = cDicResult[DATA];
        if ([strData isKindOfClass:[NSString class]]&&strData.length) {
            if (self.speedfactorBlock) {
                self.speedfactorBlock(strData);
            }
            //  CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
            //  if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpSetSpeedFactorState:)]) {
            //      [asyncTcpSocket.delegate CRTcpSetSpeedFactorState:strData];
            //  }
        }else{
            //  BLYLogInfo(@"HUD发过来的数据属于没有约定的数据");
        }
        
    }else if ([msg isEqualToString:@"getbrightlevel"]) {
        
        NSString *strData = cDicResult[DATA];
        if (strData&&strData.length) {
            if (self.getbrightLevelBlock) {
                self.getbrightLevelBlock([NSString stringWithFormat:@"%ld",(long)[strData integerValue]+1]);
            }
//            [CRDataManager setBrightLevel:[strData integerValue]+1];
        }
        //    CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
        //    if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpGetBrightLevel)]) {
        //        [asyncTcpSocket.delegate CRTcpGetBrightLevel];
        //    }
    }else if ([msg isEqualToString:@"setbrightlevel"]) {
        NSString *strData = cDicResult[DATA];
        if ([strData isKindOfClass:[NSString class]]&&strData.length) {
            if ([strData isEqualToString:@"ok"]) {
                
            }else{
                
            }
            NSString *value =  cDicResult[@"value"];
            if (value) {
//                [CRDataManager setBrightLevel:[value integerValue]+1];
            }
            
            if (self.brightLevelBlock) {
                self.brightLevelBlock([NSString stringWithFormat:@"%ld",(long)[value integerValue ]+1]);
            }
            //            if([Setting getInst].settingState != SET_LIGHT_CHANGE)
            //            {
            //                [[AISpeech sharedInstance] output:[NSString stringWithFormat:@"亮度%ld",[value integerValue]+1]];
            //                [[Setting getInst] startInput];
            //            }
            //            CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
            //            if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpSetBrightLevelState:)]) {
            //                [asyncTcpSocket.delegate CRTcpSetBrightLevelState:strData];
            //            }
        }else{
            //  BLYLogInfo(@"HUD发过来的数据属于没有约定的数据");
        }
        
    }else if ([msg isEqualToString:@"getatacct"]) {
        
        NSString *strData = cDicResult[DATA];
        if (strData&&strData.length) {
            strData = [[[strData stringByReplacingOccurrencesOfString:@"ATACCT00" withString:@""] stringByReplacingOccurrencesOfString:@"ATACCT0" withString:@""] stringByReplacingOccurrencesOfString:@"ATACCT" withString:@""];
//            [CRDataManager setAtacct:[strData integerValue]];
        }
        //        CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
        //        if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpGetAtacct)]) {
        //            [asyncTcpSocket.delegate CRTcpGetAtacct];
        //        }
    }else if ([msg isEqualToString:@"setatacct"]) {
        NSString *strMac = cDicResult[DATA];
        if ([strMac isKindOfClass:[NSString class]]&&strMac.length) {
            if (self.atacctBlock) {
                self.atacctBlock(strMac);
            }
            //            CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
            //            if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpSetAtacctState:)]) {
            //                [asyncTcpSocket.delegate CRTcpSetAtacctState:strMac];
            //            }
        }else{
            //  BLYLogInfo(@"HUD发过来的数据属于没有约定的数据");
        }
        
    }
    else if ([msg isEqualToString:@"getspeedunit"])
    {
        NSString *strMac = cDicResult[DATA];
        if ([strMac isKindOfClass:[NSString class]]&&strMac.length) {
            if (self.getSpeedUnitBlock) {
                self.getSpeedUnitBlock(strMac);
            }
        }else{
            //  BLYLogInfo(@"HUD发过来的数据属于没有约定的数据");
        }
    }
    else if ([msg isEqualToString:@"setspeedunit"])
    {
        NSString *strMac = cDicResult[DATA];
        if ([strMac isKindOfClass:[NSString class]]&&strMac.length) {
            if (self.setSpeedUnitBlock) {
                self.setSpeedUnitBlock(strMac);
            }
        }else{
            //  BLYLogInfo(@"HUD发过来的数据属于没有约定的数据");
        }
    }
    
    else if ([msg isEqualToString:@"no such msg"]) {
        //     CRAsyncTcpSocket *asyncTcpSocket = [CRAsyncTcpSocket sharedManager];
        //     if ([asyncTcpSocket.delegate respondsToSelector:@selector(CRTcpProgramError:)]) {
        //         [asyncTcpSocket.delegate CRTcpProgramError:[CRTcpError errorCode:noSuchMsg userInfo:@{@"description":@"no such msg"}]];
        //    }
    }
}

-(void)tcpProgramError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(CRTcpProgramError:)]) {
        [self.delegate CRTcpProgramError:error];
    }
    if (self.errorBlock) {
        self.errorBlock(error);
    }
}

-(void)tcpUpdateResponse:(NSDictionary *)dic state:(CRUpgradeHUDState)upgradeHUDState
{
    
    [self CRTcpResponse:dic state:upgradeHUDState];
//    if ([self.delegate respondsToSelector:@selector(CRTcpResponse:state:)]) {
//        [self.delegate CRTcpResponse:dic state:upgradeHUDState];
//    }
}
-(void)sendUpgradeFile:(NSString *) filePath fileName:(NSString *)fileName statusBlock:(void(^)(NSDictionary *)) statusBlock errorBlock:(void(^)(NSError *))errorBlock
{
    self.filePath = filePath;
    self.fileName =fileName;
    self.errorBlock=errorBlock;
    self.statusBlock = statusBlock;
    [[WirelessAsyncTcpSocket sharedManager] upgrade];
    
}

-(void)CRTcpResponse:(NSDictionary *)dic state:(CRUpgradeHUDState)upgradeHUDState
{
    switch (upgradeHUDState) {
        case CRUpgradeHUDStateReady:
        {
            _upLoadingFileManager = [[CRHUDUpLoadingFileManager alloc] init];
            _upLoadingFileManager.delegate = self;
            NSURL *filePath = [NSURL URLWithString:self.filePath];
            NSString *strFileName = self.fileName;
            [_upLoadingFileManager upgradeFolderPath:[filePath.absoluteString stringByReplacingOccurrencesOfString:strFileName withString:[strFileName stringByReplacingOccurrencesOfString:@".zip" withString:@"zip"]]];
        }
            break;
        case CRUpgradeHUDStateSof:
            
        case CRUpgradeHUDStateDownloading:
            
        case CRUpgradeHUDStateEof:
            [_upLoadingFileManager CRTcpResponse:dic state:upgradeHUDState];
            break;
        case CRUpgradeHUDStateEnd:
        {
            
            self.upgradeState = CRUpgradeStateSuccess;
            
            
            
            
            //            [self.upgradeView feedSuccess];
        }
        default:
            break;
    }
}
-(void)upgradeFinish
{
    [[WirelessAsyncTcpSocket sharedManager] dowloadEnd];
}
- (void)upgradeError:(NSError *)error
{
    self.upgradeState = CRUpgradeStateDownloadFail;
    if (self.errorBlock) {
        self.errorBlock(error);
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    //断开连接
    //    if (self.socketOfflineStyle == CRSocketOfflineByServer) {
    //        [self errorInfo:err];
    //    }
    //
    //    else
    //    {
    
    //    [self cutOffSocket];
    //    if (self.notFindHudBlock) {
    //        self.notFindHudBlock();
    //    }
    //    if (sock==self.asyncSocket_screen) {
    //
    //    }
    if (sock==self.asyncSocket_info) {
        [self errorInfo:err socket:sock];
    }
    else if(sock == self.asyncSocket_screen)
    {
        [self errorInfo:err socket:sock];
    }
    else{
        [self errorInfo:err socket:sock];
    }
    //    }
}
-(void)startScreenInit
{
    if (_times == nil) {
        [self sendData];
    }
    [self times];
}

-(void)sendData
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.lock lock];
        self.index++;
        if (self.ison) {
            self.index = 0;
            if ([self.screenData isKindOfClass:[UIView class]]) {
                UIView *view = (UIView *)self.screenData;
                UIImage *img = [self snapshot:view];
                NSData *data =UIImageJPEGRepresentation(img,imgSize);
                
                //            AILogVerbose(@"SplitScreen:screenSize %u",data.length/1024);
                
                //            AILogDebug(@"SplitScreen:screenSize %ld", (long)data.length/1024);
                
                NSMutableData *muData = [[NSMutableData alloc]init];
                Byte src [4];
                src[3] =  (Byte) ((data.length>>24) & 0xFF);
                src[2] =  (Byte) ((data.length>>16) & 0xFF);
                src[1] =  (Byte) ((data.length>>8) & 0xFF);
                src[0] =  (Byte) (data.length & 0xFF);
                [muData appendBytes:src length:4];
                [muData appendData:data];
                if (muData.length>0) {
                    [self.asyncSocket_screen writeData:muData withTimeout:2 tag:TAG_SOCKET_TCP_WRITE];
                }
                self.ison = NO;
                img = nil;
            }
            else if ([self.screenData isKindOfClass:[NSData class]])
            {
                NSData *data =(NSData *)self.screenData;
                NSMutableData *muData = [[NSMutableData alloc]init];
                Byte src [4];
                src[3] =  (Byte) ((data.length>>24) & 0xFF);
                src[2] =  (Byte) ((data.length>>16) & 0xFF);
                src[1] =  (Byte) ((data.length>>8) & 0xFF);
                src[0] =  (Byte) (data.length & 0xFF);
                [muData appendBytes:src length:4];
                [muData appendData:data];
                if (muData.length>0) {
                    [self.asyncSocket_screen writeData:muData withTimeout:2 tag:TAG_SOCKET_TCP_WRITE];
                }
                self.ison = NO;
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                UIView *view = window;
                UIImage *img = [self snapshot:view];
                NSData *data =UIImageJPEGRepresentation(img,imgSize);
                
                //            AILogVerbose(@"SplitScreen:screenSize %u",data.length/1024);
                
                //            AILogDebug(@"SplitScreen:screenSize %ld", (long)data.length/1024);
                
                NSMutableData *muData = [[NSMutableData alloc]init];
                Byte src [4];
                src[3] =  (Byte) ((data.length>>24) & 0xFF);
                src[2] =  (Byte) ((data.length>>16) & 0xFF);
                src[1] =  (Byte) ((data.length>>8) & 0xFF);
                src[0] =  (Byte) (data.length & 0xFF);
                [muData appendBytes:src length:4];
                [muData appendData:data];
                if (muData.length>0) {
                    [self.asyncSocket_screen writeData:muData withTimeout:2 tag:TAG_SOCKET_TCP_WRITE];
                }
                self.ison = NO;
                img = nil;
            }
            
        }
        if (self.index == 1000) {
            [self errorInfo:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"error":@"ison is NO  time out"}]socket:self.asyncSocket_screen];
        }
        [self.lock unlock];
        
    });
    
}

-(void)registerCRAsyncTcpSocketDelegate:(id<CRAsyncTcpSocketDelegate>)delegate
{
    
    self.delegate = delegate;
}

- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc]init];
    }
    return _lock;
}

- (UIImage *)snapsHotView:(UIView *)view
{
    UIImage *viewImage = nil;
    UIGraphicsBeginImageContext(view.frame.size);
    //[screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    //    viewImage = [self scaleToSize:viewImage size:CGSizeMake(480, 240)];
    return viewImage;
}
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)snapshot:(UIView *)view
{
    @autoreleasepool {
        
        
        //        size_t width = view.bounds.size.width;
        //        size_t height = view.bounds.size.height;
        //
        //        unsigned char *imageBuffer = (unsigned char *)malloc(width*height*4);
        //        CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
        //
        //        CGContextRef imageContext =
        //        CGBitmapContextCreate(imageBuffer, width, height, 8, width*4, colourSpace,
        //                              kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
        //
        //        CGColorSpaceRelease(colourSpace);
        //
        //        [view.layer renderInContext:imageContext];
        //         view.layer.contents = (id)nil;
        //        CGImageRef outputImage = CGBitmapContextCreateImage(imageContext);
        //        UIImage *snapshot = [UIImage imageWithCGImage:outputImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        //        CGImageRelease(outputImage);
        //        CGContextRelease(imageContext);
        //        free(imageBuffer);
        
        
        
        // 不能用 [UIScreen mainScreen].scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 1);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //        if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        //            //锁屏会白屏 不能用 drawViewHierarchyInRect
        //            [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
        //        }
        //        else
        //  {
        [view.layer renderInContext:context];
        //   }
//        view.layer.contents = (id)nil;
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshot;
    }
}
- (dispatch_source_t )times
{
    if (!_times) {
        //        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t queue = dispatch_get_main_queue();
        _times = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        dispatch_source_set_timer(_times, dispatch_walltime(NULL, 0), 0.2 * NSEC_PER_SEC, 0);
        @weakify(self);
        dispatch_source_set_event_handler(_times, ^{
            @strongify(self);
            [self sendData];
        });
        dispatch_resume(_times);
        // dipatch_cancel(self.timer);
    }
    return _times;
}

- (BOOL)isDataChannelConnect{
    if (self.asyncSocket_info) {
        return self.asyncSocket_info.isConnected;
    }else{
        return NO;
    }
}


-(void)errorInfo:(NSError *)error socket:(GCDAsyncSocket *)socket
{
//    AILogVerbose(@"SplitScreen 断开");
    if (socket==self.asyncSocket_info) {
        [self cutOffSocketInfo];
        if (self.errorBlockInfo) {
            self.errorBlockInfo(error);
        }
    }
    else if(socket == self.asyncSocket_screen)
    {
        
        [self cutOffSocketScreen];
        if (_times) {
            dispatch_source_cancel(_times);
            _times = nil;
        }
        if (self.errorBlockScreen) {
            self.errorBlockScreen(error);
        }
        
    }
    else
    {
        
        if (self.errorBlockScreen) {
             self.errorBlockScreen([NSError errorWithDomain:NSCocoaErrorDomain code:-100 userInfo:@{@"error":@"未知 socket"}]);
        }
        if (self.errorBlockScreen) {
            self.errorBlockScreen(error);
        }
       
    }
}
@end
