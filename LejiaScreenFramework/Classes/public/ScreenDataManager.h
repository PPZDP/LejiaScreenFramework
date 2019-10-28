//
//  ScreenDataManager.h
//  CocoaAsyncSocket
//
//  Created by sos1a2a3a on 2019/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//FPS : 5   warning: smaller values may cause frame dropping
static int Frame = 2 ;
// compressionQuality warning:The higher the image quality, the more memory calculation and the slower the hardware transmission
static CGFloat compressionQuality =  0.5 ;

@interface ScreenDataManager : NSObject

@property(nonatomic,strong,nullable)UIView *screenView;

+ (ScreenDataManager *)sharedManager;
+ (void)attemptDealloc;

- (void)startScreenData;
- (void)removeScreenView;
- (void)stopTime;
@end

NS_ASSUME_NONNULL_END
