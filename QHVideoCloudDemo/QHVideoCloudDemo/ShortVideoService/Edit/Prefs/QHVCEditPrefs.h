//
//  QHVCEditPrefs.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCGlobalConfig.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import "QHVCShortVideoMacroDefs.h"

//颜色
#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:1.0]
#define UIColorFromARGBHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16 )) / 255.0 green:((( s & 0xFF00 ) >> 8 )) / 255.0 blue:(( s & 0xFF )) / 255.0 alpha:(((s & 0xFF000000) >> 32 ) / 255.0)]

//通知
#define QHVCEDIT_DEFINE_NOTIFY_SHOW_OVERLAY_FUNCTION  @"ShowOverlayFunction"
#define QHVCEDIT_DEFINE_NOTIFY_SHOW_STICKER_FUNCTION  @"ShowStickerFunction"
#define QHVCEDIT_DEFINE_NOTIFY_SHOW_SUBTITLE_FUNCTION @"ShowSubtitleFunction"
#define QHVCEDIT_DEFINE_NOTIFY_CLEAR_PLAYER_CONTENT   @"ClearPlayerContent"

//other
#define kColorHigh @"77C5FF"
#define kColorNormal @"8C8B91"
#define kDefaultOverlayWidth   200.0
#define kDefaultOverlayHeight  200.0
#define kDefaultStickerWidth   100.0
#define kDefaultStickerHeight  100.0
#define kDefaultSubtitleWidth  100.0
#define kDefaultSubtitleHeight 100.0
#define kDefaultMosaicWidth    100.0
#define kDefaultMosaicHeight   100.0

typedef NS_ENUM(NSUInteger, QHVCEditFunctionViewType)
{
    QHVCEditFunctionViewTypeFunctionBase,
    QHVCEditFunctionViewTypeOverlay,
};

@interface QHVCEditPrefs : NSObject

+ (QHVCEditPrefs *)sharedPrefs;

+ (NSString *)timeFormatMs:(NSInteger)ms;
+ (UIColor *)colorHighlight;
+ (UIColor *)colorNormal;
+ (UIColor *)colorHex:(NSString *)hex;
+ (UIColor *)colorARGBHex:(NSString *)hex;
+ (int)randomNum:(int)from to:(int)to;
+ (UIImage *)convertViewToImage:(UIView *)view;
+ (NSString *)hexStringFromColor:(UIColor *)color; //UIColor转ARGB
+ (CGRect)createRandomRect:(NSInteger)targetWidth
              targetHeight:(NSInteger)targetHeight
               sourceWidth:(NSInteger)sourceWidth
              sourceHeight:(NSInteger)sourceHeight
               contentSize:(CGSize)contentSize;
+ (QHVCEffectRect)rectFormatter:(CGRect)rect;

- (NSString *)videoTempDir;
- (NSArray *)editFunctions;

@end
