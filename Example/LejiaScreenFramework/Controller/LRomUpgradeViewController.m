//
//  LRomUpgradeViewController.m
//  LeJiaScreenProject
//
//  Created by sos1a2a3a on 2018/11/12.
//  Copyright © 2018 lijiarui. All rights reserved.
//

#import "LRomUpgradeViewController.h"
#import "HUDWAYProjectManager.h"
#import "SSZipArchive.h"
@interface LRomUpgradeViewController ()
@property(nonatomic,strong)UIButton *getUpgradeBt;
@property(nonatomic,strong)UILabel *subLab;
@end

@implementation LRomUpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass([self class]);
    
    if (![HUDWAYProjectManager sharedManager].isConnectTcpInfo) {
        NSString *msg = @"please HUDWAYProjectManager method start ";
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [self.view addSubview:self.getUpgradeBt];
    [self.view addSubview:self.subLab];
}

- (UILabel *)subLab
{
    if (!_subLab) {
        _subLab = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height/2-50/2, self.view.frame.size.width, 300)];
        _subLab.textAlignment = NSTextAlignmentCenter;
        _subLab.numberOfLines = 0;
        _subLab.textColor  = [UIColor redColor];
        _subLab.font = [UIFont systemFontOfSize:18];
        _subLab.text = @"Upgrade info:";
        
    }
    return _subLab;
}

- (UIButton *)getUpgradeBt
{
    if (!_getUpgradeBt) {
        _getUpgradeBt = [[UIButton alloc]initWithFrame:CGRectMake(30, 80, 100, 50)];
        [_getUpgradeBt setTitle:@"getUpgrade" forState:UIControlStateNormal];
        [_getUpgradeBt addTarget:self action:@selector(getUpgradeAction) forControlEvents:UIControlEventTouchDown];
        [_getUpgradeBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _getUpgradeBt;
}

-(void)getUpgradeAction
{
    NSString * appDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *appLib = [appDir stringByAppendingString:@"/Caches"];
    NSString *cachesfileName = @"Carrobot_RK_V21_190612.zip";
    NSString *cachesfilePath =  [NSString stringWithFormat:@"%@/%@",appLib,cachesfileName];
    NSString *fileName = @"Carrobot_RK_V21_190612";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"zip"];
    [self copyMissingFile:filePath toPath:appLib];
    
     NSString *desFilePath = [cachesfilePath stringByReplacingOccurrencesOfString:@".zip" withString:@"zip"];
    
    [SSZipArchive unzipFileAtPath:cachesfilePath toDestination:desFilePath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            #pragma mark wait  1minute - 3minute
            [[HUDWAYProjectManager sharedManager]  sendUpgradeFile:desFilePath fileName:cachesfileName statusBlock:^(NSDictionary * _Nonnull dict) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.subLab.text = [self DataTOjsonString:dict];
                });
                
            } errorBlock:^(NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.subLab.text = [self DataTOjsonString:error.userInfo];
                });
            }];
            
            
        }
        
        
    }];

}

- (BOOL)copyMissingFile:(NSString *)sourcePath toPath:(NSString *)toPath
{
    BOOL retVal = YES;
    NSString * finalLocation = [toPath stringByAppendingPathComponent:[sourcePath lastPathComponent]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalLocation])
    {
        NSError *error;
        retVal = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:finalLocation error:&error];
    }
    return retVal;
}



-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


@end
