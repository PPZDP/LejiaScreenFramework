//
//  ScreenDataManager.m
//  CocoaAsyncSocket
//
//  Created by sos1a2a3a on 2019/10/25.
//

#import "ScreenDataManager.h"
#import "HUDWAYProjectManager.h"


@interface ScreenDataManager ()<HUDWAYProjectDelegate>
@property(nonatomic,strong)dispatch_source_t times;
@end
static id sharedManagerInstance;
static dispatch_once_t onceToken;
@implementation ScreenDataManager

+ (ScreenDataManager *)sharedManager
{
    dispatch_once(&onceToken, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}
+ (void)attemptDealloc{
    [self sharedManager].screenView = nil;
    sharedManagerInstance = nil;
    onceToken=0l;
}

- (void)removeScreenView
{
    self.screenView = nil;
}

- (dispatch_source_t )times
{
    if (!_times) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _times = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_times, dispatch_walltime(NULL, 0), Frame * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_times, ^{
            [self sendData];
            
        });
        dispatch_resume(_times);
    }
    return _times;
}

- (void)stopTime
{
    if ( _times) {
        dispatch_source_cancel(_times);
        _times = nil;
    }
}

- (void)sendData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *data =  [self getScreenData];
           if (data==nil) {
               return;
           }
        [[HUDWAYProjectManager sharedManager] sendHUDData:data];
    });
}

- (void)startScreenData
{
    NSData *data =  [self getScreenData];
    if (data==nil) {
        return;
    }
    [HUDWAYProjectManager sharedManager].delegate = self;
    [[HUDWAYProjectManager sharedManager] start:data];
}

- (NSData *)getScreenData
{
    if (self.screenView==nil) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        self.screenView = window;
    }
    UIView *view = self.screenView;
    UIImage *img = [self snapshot:view];
    NSData *data =UIImageJPEGRepresentation(img,compressionQuality);
    return data;
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

#pragma mark HUDWAYProjectDelegate
- (void)connectSuccess
{
    NSLog(@"connectSuccess");
    [self times];
}
- (void)connectFail
{
    [self stopTime];
    NSLog(@"connectFail");
}

- (void)dealloc
{
    
}
@end
