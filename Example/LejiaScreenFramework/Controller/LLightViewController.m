//
//  LLightViewController.m
//  LeJiaScreenProject
//
//  Created by sos1a2a3a on 2018/11/12.
//  Copyright © 2018 lijiarui. All rights reserved.
//

#import "LLightViewController.h"

#import "HUDWAYProjectManager.h"

@interface LLightViewController ()

@property(nonatomic,strong)UIButton *getButtonLight;
@property(nonatomic,strong)UIButton *addButtonLight;
@property(nonatomic,strong)UILabel *subLabLight;
@property(nonatomic,strong)UIButton *deleteButtonLight;


@property(nonatomic,strong)UIButton *getButtonUnit;
@property(nonatomic,strong)UIButton *addButtonUnit;
@property(nonatomic,strong)UILabel *subLabUnit;
@end
@implementation LLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass([self class]);
    
    if (![HUDWAYProjectManager sharedManager].isConnectTcpInfo) {
        NSString *msg = @"please HUDWAYProjectManager method start";
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    [self.view addSubview:self.subLabLight];
    [self.view addSubview:self.getButtonLight];
    [self.view addSubview:self.addButtonLight];
    [self.view addSubview:self.deleteButtonLight];
    
    [self.view addSubview:self.subLabUnit];
    [self.view addSubview:self.getButtonUnit];
    [self.view addSubview:self.addButtonUnit];
}

- (UIButton *)getButtonLight
{
    if (!_getButtonLight) {
        _getButtonLight = [[UIButton alloc]initWithFrame:CGRectMake(30, 80+120, 100, 50)];
        [_getButtonLight setTitle:@"get Light" forState:UIControlStateNormal];
        [_getButtonLight addTarget:self action:@selector(getLightaction) forControlEvents:UIControlEventTouchDown];
        [_getButtonLight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _getButtonLight;
}

- (UIButton *)addButtonLight
{
    if (!_addButtonLight) {
        _addButtonLight = [[UIButton alloc]initWithFrame:CGRectMake(30, 80, 100, 50)];
        [_addButtonLight setTitle:@"add Light" forState:UIControlStateNormal];
        [_addButtonLight addTarget:self action:@selector(addLightaction) forControlEvents:UIControlEventTouchDown];
        [_addButtonLight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _addButtonLight;
}

- (UIButton *)deleteButtonLight
{
    if (!_deleteButtonLight) {
        _deleteButtonLight = [[UIButton alloc]initWithFrame:CGRectMake(30, CGRectGetMaxY(self.subLabLight.frame)+20, 100, 50)];
        [_deleteButtonLight setTitle:@"delete Light" forState:UIControlStateNormal];
        [_deleteButtonLight addTarget:self action:@selector(deleteLightaction) forControlEvents:UIControlEventTouchDown];
        [_deleteButtonLight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _deleteButtonLight;
}

- (UILabel *)subLabLight
{
    if (!_subLabLight) {
        _subLabLight = [[UILabel alloc]initWithFrame:CGRectMake(30, self.view.bounds.size.height/2-50/2, 100, 50)];
        _subLabLight.textAlignment = NSTextAlignmentCenter;
        _subLabLight.textColor  = [UIColor redColor];
        _subLabLight.font = [UIFont systemFontOfSize:18];
        
        
    }
    return _subLabLight;
}

-(void)getLightaction
{
    
    [[HUDWAYProjectManager sharedManager] getBrightLevel:^(NSString *lightStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.subLabLight.text = lightStr;
        });
        
    }];
}
-(void)deleteLightaction
{
    
    [[HUDWAYProjectManager sharedManager] setBrightLevel:[self.subLabLight.text integerValue]-1 brightLevelBlock:^(NSString *lightStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.subLabLight.text = lightStr;
        });
        
    }];
}

-(void)addLightaction
{
    [[HUDWAYProjectManager sharedManager] setBrightLevel:[self.subLabLight.text integerValue]+1 brightLevelBlock:^(NSString *lightStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.subLabLight.text = lightStr;
        });
        
    }];
}

- (UIButton *)getButtonUnit
{
    if (!_getButtonUnit) {
        _getButtonUnit = [[UIButton alloc]initWithFrame:CGRectMake(170, 80+120, 100, 50)];
        [_getButtonUnit setTitle:@"get unit" forState:UIControlStateNormal];
        [_getButtonUnit addTarget:self action:@selector(getUnitaction) forControlEvents:UIControlEventTouchDown];
        [_getButtonUnit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _getButtonUnit;
}

- (UIButton *)addButtonUnit
{
    if (!_addButtonUnit) {
        _addButtonUnit = [[UIButton alloc]initWithFrame:CGRectMake(170, 80, 100, 50)];
        [_addButtonUnit setTitle:@"set unit" forState:UIControlStateNormal];
        [_addButtonUnit addTarget:self action:@selector(setUnitaction) forControlEvents:UIControlEventTouchDown];
        [_addButtonUnit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _addButtonUnit;
}

- (UILabel *)subLabUnit
{
    if (!_subLabUnit) {
        _subLabUnit = [[UILabel alloc]initWithFrame:CGRectMake(170, self.view.bounds.size.height/2-50/2, 150, 50)];
        _subLabUnit.textAlignment = NSTextAlignmentCenter;
        _subLabUnit.textColor  = [UIColor redColor];
        _subLabUnit.font = [UIFont systemFontOfSize:18];
        
        
    }
    return _subLabUnit;
}

-(void)getUnitaction
{
    [[HUDWAYProjectManager sharedManager] getSpeedunitStr:^(NSString *unitStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.subLabUnit.text = unitStr;
        });
        
    }];
}

-(void)setUnitaction
{
    //mph or kmh
    NSString *unitStr = @"mph";
    if ([unitStr isEqualToString:self.subLabUnit.text]) {
        unitStr = @"kmh";
    }
    [[HUDWAYProjectManager sharedManager] setSpeedunitStr:unitStr speedUnitBlock:^(NSString *unitStr){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.subLabUnit.text = unitStr;
        });
        
    }];
}



@end
