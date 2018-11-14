//
//  QHVCEditPrefs.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCEditKit/QHVCEditKit.h>

#import "QHVCEditAudioItem.h"
#import "QHVCEditMatrixItem.h"
#import "QHVCConfig.h"

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
#define UIColorFromARGBHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:(((s & 0xFF000000) >> 32 ) / 255.0)]

#define SAFE_BLOCK(block, ...) if((block)) { block(__VA_ARGS__); }

#define SAFE_BLOCK_IN_MAIN_QUEUE(block, ...) if((block)) {\
if ([NSThread isMainThread]) {\
block(__VA_ARGS__);\
}\
else {\
dispatch_async(dispatch_get_main_queue(), ^{\
block(__VA_ARGS__);\
});\
}\
}

#define WEAK_SELF    __weak __typeof(&*self) weakSelf = self;
#define STRONG_SELF  __strong __typeof(&*self) self = weakSelf;

#define kImageFileDurationMS 3000.0

#define kOutputVideoWidth 720
#define kOutputVideoHeight 1280

#define kMainTrackId 0

@class QHVCEditPhotoItem;

@interface QHVCEditPrefs : NSObject

@property (nonatomic, strong) NSMutableArray<QHVCEditPhotoItem *> *photosList;

@property (nonatomic, assign) BOOL isEnableWatermsk;
@property (nonatomic, assign) double editSpeed;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *qualitys;
@property (nonatomic, assign) NSInteger filterIndex;
@property (nonatomic, assign) NSInteger overlayBgColorIndex;
@property (nonatomic, assign) NSInteger overlayTemplateIndex;

@property (nonatomic, assign) CGSize outputSize;
@property (nonatomic, assign) NSInteger fillIndex;
@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, retain) NSMutableArray<QHVCEditMatrixItem *>* matrixItems;

@property (nonatomic, assign) float originAudioVolume;
@property (nonatomic, assign) float musicAudioVolume;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *audioTimestamp;

@property (nonatomic, assign) NSInteger renderMode;
@property (nonatomic, strong) NSString *renderColor;

@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *subtitleTimestamp;
@property (nonatomic, retain) QHVCEditCommandImageFilter* watermaskFilter;

@property (nonatomic, assign) BOOL isEnableDynamicSubtitle;

+ (QHVCEditPrefs *)sharedPrefs;

+ (NSString *)timeFormatMs:(NSTimeInterval)ms;
+ (UIColor *)colorHighlight;
+ (UIColor *)colorNormal;
+ (UIColor *)colorHex:(NSString *)hex;
+ (UIColor *)colorARGBHex:(NSString *)hex;
+ (int)randomNum:(int)from to:(int)to;

+ (UIImage *)convertViewToImage:(UIView *)v;

+ (NSString *)hexStringFromColor:(UIColor *)color; //UIColor转ARGB

@end
