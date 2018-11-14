//
//  QHVCEditPrefs.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditPrefs.h"

#define kColorHigh @"77C5FF"
#define kColorNormal @"8C8B91"

static QHVCEditPrefs *_sharedInstance = nil;

@implementation QHVCEditPrefs

+ (QHVCEditPrefs *)sharedPrefs
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _renderMode = QHVCEditPlayerPreviewFillMode_AspectFit;
        _renderColor = @"FF4B4B4B";
        _editSpeed = 1.0;
        _qualitys = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < 29; i++)
        {
            [_qualitys addObject:@(0)];
        }
        _filterIndex = 0;
        _originAudioVolume = 100;
        _audioTimestamp = [NSMutableArray array];
        _colorIndex = -1;
        _outputSize = CGSizeMake(kOutputVideoWidth, kOutputVideoHeight);
        
        _subtitleTimestamp = [NSMutableArray array];
        _matrixItems = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

+ (NSString *)timeFormatMs:(NSTimeInterval)ms
{
    NSTimeInterval seconds = floor(ms/1000.0);
    NSInteger minutesNum = seconds/60;
    NSInteger secondsNum = (NSInteger)seconds%60;
    NSString* minutesStr = (minutesNum<10) ? [NSString stringWithFormat:@"0%ld", (long)minutesNum]:[NSString stringWithFormat:@"%ld", (long)minutesNum];
    NSString* secondsStr = (secondsNum<10) ? [NSString stringWithFormat:@"0%ld", (long)secondsNum]:[NSString stringWithFormat:@"%ld", (long)secondsNum];
    NSString* time = [NSString stringWithFormat:@"%@:%@", minutesStr, secondsStr];
    return time;
}

+ (UIColor *)colorHighlight
{
    return [QHVCEditPrefs colorHex:kColorHigh];
}

+ (UIColor *)colorNormal
{
    return [QHVCEditPrefs colorHex:kColorNormal];
}

+ (UIColor *)colorHex:(NSString *)hex
{
    unsigned int colorInt;
    [[NSScanner scannerWithString:hex] scanHexInt:&colorInt];
    return UIColorFromHex(colorInt);
}

+ (UIColor *)colorARGBHex:(NSString *)hexColor
{
    // String should be 8 or 9 characters if it includes '#'
    if ([hexColor length]  < 8)
        return nil;
    
    // strip # if it appears
    if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];
    
    // if the value isn't 6 characters at this point return
    // the color black
    if ([hexColor length] != 8)
        return nil;
    
    // Separate into a, r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *aString = [hexColor substringWithRange:range];
    
    range.location = 2;
    NSString *rString = [hexColor substringWithRange:range];
    
    range.location = 4;
    NSString *gString = [hexColor substringWithRange:range];
    
    range.location = 6;
    NSString *bString = [hexColor substringWithRange:range];
    
    // Scan values
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}

+ (int)randomNum:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

+ (UIImage *)convertViewToImage:(UIView *)v
{
    CGSize s = v.bounds.size;    
    UIGraphicsBeginImageContextWithOptions(s, NO,[UIScreen mainScreen].scale);
    [v drawViewHierarchyInRect:v.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *)hexStringFromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = 1;
    CGFloat g = 1;
    CGFloat b = 1;
    CGFloat a = 1;
    if (components)
    {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }

    return [NSString stringWithFormat:@"%02lX%02lX%02lX%02lX",
            lroundf(a * 255),
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
