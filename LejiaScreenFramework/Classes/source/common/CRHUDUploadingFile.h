//
//  CRHUDUploadingFile.h
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/27.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRHUDUploadingFile : NSObject

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *filePath;
@property(nonatomic,assign)long long offset;
@property(nonatomic,assign)long long length;
@property(nonatomic,assign)long payload;
@property(nonatomic,assign)BOOL isFinish;

@end

NS_ASSUME_NONNULL_END
