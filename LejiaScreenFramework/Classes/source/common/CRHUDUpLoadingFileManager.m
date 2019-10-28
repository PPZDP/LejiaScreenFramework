//
//  CRHUDUpLoadingFileManager.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/27.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import "CRHUDUpLoadingFileManager.h"
#import "CRHUDUploadingFile.h"

#define payLoad 1024*50
#define CRDebugSocketError 10086

@implementation CRHUDUpLoadingFileManager
{
    NSInteger interCurrentCount;
    NSMutableArray *arrmutFiles;
}
-(void)upgradeFolderPath:(NSString *)folderPath
{
    NSString *path = folderPath;
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *myDirectoryEnumerator =[myFileManager enumeratorAtPath: folderPath];
    arrmutFiles = [[NSMutableArray alloc] init];
    while((path=[myDirectoryEnumerator nextObject])!=nil)
    {
        CRHUDUploadingFile *file = [[CRHUDUploadingFile alloc] init];
        file.name = path;
        NSString *filePath = [[folderPath stringByAppendingString:@"/"] stringByAppendingString:path];
        file.filePath = filePath;
        file.length = [self fileSizeAtPath:filePath];
        [arrmutFiles addObject:file];
    }
    if ([arrmutFiles count]) {
        interCurrentCount = 0;
        [self upload];
    }else{
        [self upgradeError:[NSError errorWithDomain:NSCocoaErrorDomain code:CRDebugSocketError userInfo:@{@"description":@"file is null"}]];
    }
    
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
-(void)upload{
    if (interCurrentCount<[arrmutFiles count]) {
        CRHUDUploadingFile *file = arrmutFiles[interCurrentCount];
        [[WirelessAsyncTcpSocket sharedManager] beginLoadName:file.name];
    }else{
        [self upgradeEnd];
    }
}

-(void)CRTcpResponse:(NSDictionary *)dic state:(CRUpgradeHUDState)upgradeHUDState{
    
    switch (upgradeHUDState) {
        case CRUpgradeHUDStateSof:
        case CRUpgradeHUDStateDownloading:
        {
            [self downLoading];
        }
            break;
        case CRUpgradeHUDStateEof:
        {
            interCurrentCount ++;
            [self upload];
        }
            
        default:
            //            BLYLogInfo(@"传输错误");
            break;
    }
    
}
-(void)upgradeError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(upgradeError:)]) {
        [_delegate upgradeError:error];
    }
}
-(void)upgradeEnd
{
    if ([_delegate respondsToSelector:@selector(upgradeFinish)]) {
        [_delegate upgradeFinish];
    }
}
-(void)downLoading
{
    CRHUDUploadingFile *file = arrmutFiles[interCurrentCount];
    if (file.offset>=file.length) {
        [ [WirelessAsyncTcpSocket sharedManager] downloadEof:file.name len:[NSNumber numberWithLongLong:file.length]];
        return;
    }
    
    NSFileHandle *readFile = [NSFileHandle fileHandleForReadingAtPath:file.filePath];
    [readFile seekToFileOffset:file.offset];
    NSData * buffer = [readFile readDataOfLength:payLoad];
    NSData  *base64Data = [buffer base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSASCIIStringEncoding];
    base64String =  [base64String stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    base64String =  [base64String stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [[WirelessAsyncTcpSocket sharedManager] downloadingFileOffset:[NSNumber numberWithLongLong:file.offset] payload:[NSNumber numberWithInteger:buffer.length] data:base64String];
    file.offset += buffer.length;
    
    
    NSLog(@"%lld  %lu",file.offset,(unsigned long)buffer.length);
    [readFile closeFile];
}
@end
