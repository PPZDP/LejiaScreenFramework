//
//  CRHUDUpLoadingFileManager.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/27.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WirelessAsyncTcpSocket.h"
@protocol CRHUDUpLoadingFileManagerDelegate <NSObject>
-(void)upgradeError:(NSError *)error;
-(void)upgradeFinish;
@end

@interface CRHUDUpLoadingFileManager : NSObject
@property(nonatomic,weak)id<CRHUDUpLoadingFileManagerDelegate> delegate;
-(void)upgradeFolderPath:(NSString *)folderPath;
-(void)CRTcpResponse:(NSDictionary *)dic state:(CRUpgradeHUDState)upgradeHUDState;


-(void)upload;
@end
