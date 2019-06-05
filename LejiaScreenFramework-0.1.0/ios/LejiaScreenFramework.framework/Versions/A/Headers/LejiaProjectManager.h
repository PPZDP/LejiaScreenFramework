//
//  LejiaProjectManager.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface LejiaProjectManager : NSObject


@property(nonatomic,assign)BOOL isConnectTcp;

/**
 hud info Example: brightness,hudunit
 */
@property(nonatomic,assign)BOOL isConnectTcpInfo;


+ (LejiaProjectManager *)sharedManager;



/**
  start

 @param data  Example: data or UIView ,if  it is nil, The default  is UIWindow
 */
- (void)start:(nonnull id )data;
/**
 *  close
 *
 */
-(void)stop;


/**
 release Data -1
 */
-(void)releaseData;


/**
 get hud brightness
 
 @param brightLevelBlock block
 */
-(void)getBrightLevel:(void(^)(NSString *))brightLevelBlock;

/**
 setup hud brightness
 
 @param level  1-6
 @param brightLevelBlock block
 */
-(void)setBrightLevel:(NSInteger)level brightLevelBlock:(void(^)(NSString *))brightLevelBlock;



/**
 get hudunit
 
 @param speedUnitBlock block
 */
-(void)getSpeedunitStr:(void(^)(NSString *))speedUnitBlock;
/**
 setup hudunit
 
 @param spustr mph  or kmh
 @param speedUnitBlock block
 */
-(void)setSpeedunitStr:(NSString *)spustr speedUnitBlock:(void(^)(NSString *)) speedUnitBlock;


/**
 upgrade hud rom
 
 */
-(void)sendUpgradeFile:(NSString *) filePath fileName:(NSString *)fileName statusBlock:(void(^)(NSDictionary *)) statusBlock errorBlock:(void(^)(NSError *))errorBlock;


/**
 data

 @param screenData setImgeData
 */
-(void)mappingScreenData:(id)screenData;
@end



