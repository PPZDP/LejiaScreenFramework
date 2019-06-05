//
//  LScreenViewController.m
//  LeJiaScreenProject
//
//  Created by sos1a2a3a on 2018/11/12.
//  Copyright © 2018 lijiarui. All rights reserved.
//

#import "LScreenViewController.h"
#import "HUDWAYProjectManager.h"

@interface CustomLab : UILabel

@end


@implementation CustomLab


-(void)dealloc
{
    NSLog(@"%s",__func__);
}

@end



@interface LScreenViewController ()
@property(nonatomic,strong)NSTimer *times;
@property(nonatomic,strong)CustomLab *showView;

@end

@implementation LScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSStringFromClass([self class]);
    
    UIButton *startBt = [[UIButton alloc]initWithFrame:CGRectMake(20, 64+30, 100, 50)];
    startBt.backgroundColor = [UIColor redColor];
    startBt.titleLabel.font = [UIFont systemFontOfSize:13];
    [startBt setTitle:@"start" forState:UIControlStateNormal];
    [startBt addTarget:self action:@selector(startScreen:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:startBt];
    
    
    UIButton *startBtdata = [[UIButton alloc]initWithFrame:CGRectMake(20+50+100, 64+30, 150, 50)];
    startBtdata.backgroundColor = [UIColor redColor];
    startBtdata.titleLabel.font = [UIFont systemFontOfSize:13];
    [startBtdata setTitle:@"start for data" forState:UIControlStateNormal];
    [startBtdata addTarget:self action:@selector(startScreenData:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:startBtdata];
    
    
    UIButton *closeBt = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(startBt.frame)+20, 100, 50)];
    closeBt.backgroundColor = [UIColor blueColor];
    closeBt.titleLabel.font = [UIFont systemFontOfSize:13];
    [closeBt setTitle:@"close" forState:UIControlStateNormal];
    [closeBt addTarget:self action:@selector(closeScreen:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:closeBt];
    
    
    
    CustomLab *showView = [[CustomLab alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(closeBt.frame)+20, 480, 240)];
    self.showView = showView;
    showView.textAlignment = NSTextAlignmentCenter;
    showView.text = [NSString stringWithFormat:@"%@",[NSDate new]];
    showView.font = [UIFont systemFontOfSize:18];
    showView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:showView];
    
    
    _times = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refeshData) userInfo:nil repeats:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

-(void)refeshData
{
    
    
    self.showView.text = [NSString stringWithFormat:@"%@",[NSDate new]];
    
    [[HUDWAYProjectManager sharedManager ] getRomVersion:^(NSDictionary * dict) {
        NSLog(@"romversion:%@",dict);
    }];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_times) {
        [_times invalidate];
        _times = nil;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    self.navigationController.navigationBarHidden=YES;
}

- (void)startScreen:(UIButton *)bt
{
    // customView: width:480 height:240
    [[HUDWAYProjectManager sharedManager] start:self.showView];
}

-(void)startScreenData:(UIButton *)bt
{
    UIView *view = self.view;
    UIImage *img = [self snapshot:view];
    NSData *data =UIImageJPEGRepresentation(img,0.5);
  
    [[HUDWAYProjectManager sharedManager] start:data];
    
    // or  [[LejiaProjectManager sharedManager] mappingScreenData:data];
}
- (UIImage *)snapshot:(UIView *)view
{
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 1);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [view.layer renderInContext:context];
        UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshot;
    }
}

-(void)closeScreen:(UIButton *)bt
{
    [[HUDWAYProjectManager sharedManager] stop];
}



- (void)dealloc
{
    [[HUDWAYProjectManager sharedManager] releaseData];
    NSLog(@"%s",__func__);
}

@end
