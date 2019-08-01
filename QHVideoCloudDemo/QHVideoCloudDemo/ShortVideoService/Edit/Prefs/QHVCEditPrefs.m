//
//  QHVCEditPrefs.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditPrefs.h"

@interface QHVCEditPrefs ()
@property (nonatomic, retain) NSMutableArray* editFunctionsArray;

@end

@implementation QHVCEditPrefs

+ (QHVCEditPrefs *)sharedPrefs
{
    static QHVCEditPrefs *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initParams];
    }
    return self;
}

- (void)initParams
{
    self.editFunctionsArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"QHVCEditFunctionList" ofType:@"plist"];
    NSArray* array = [NSArray arrayWithContentsOfFile:path];
    if ([array count] > 0)
    {
        [self.editFunctionsArray addObjectsFromArray:array];
    }
    
#ifdef QHVCADVANCED
    NSString* advancedPath = [[NSBundle mainBundle] pathForResource:@"QHVCEditFunctionList+Advanced"
                                                             ofType:@"plist"];
    NSArray* advancedArray = [NSArray arrayWithContentsOfFile:advancedPath];
    if ([advancedArray count] > 0)
    {
        [self.editFunctionsArray addObjectsFromArray:advancedArray];
    }
#endif
}

+ (NSString *)timeFormatMs:(NSInteger)ms
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
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
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

+ (QHVCEffectRect)rectFormatter:(CGRect)rect
{
    QHVCEffectRect newRect = QHVCEffectRectMake(rect.origin.x,
                                                rect.origin.y,
                                                rect.size.width,
                                                rect.size.height);
    return newRect;
}

- (NSString *)videoTempDir
{
    NSString *videoFilePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"video"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoFilePath isDirectory:nil])
    {
        BOOL isSucess = [[NSFileManager defaultManager] createDirectoryAtPath:videoFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSucess) {
            return nil;
        }
    }
    return videoFilePath;
}

- (NSArray *)editFunctions
{
    return self.editFunctionsArray;
}

+ (CGRect)createRandomRect:(NSInteger)targetWidth
              targetHeight:(NSInteger)targetHeight
               sourceWidth:(NSInteger)sourceWidth
              sourceHeight:(NSInteger)sourceHeight
               contentSize:(CGSize)contentSize
{
    CGRect rect = CGRectZero;
    CGFloat x = [self randomNum:0 to:fabs((contentSize.width - targetWidth))];
    CGFloat y = [self randomNum:0 to:fabs((contentSize.height - targetHeight))];
    CGFloat scaleW = (CGFloat)targetWidth/sourceWidth;
    CGFloat scaleH = (CGFloat)targetHeight/sourceHeight;
    CGFloat scale = MIN(scaleW, scaleH);
    int w = sourceWidth*scale;
    int h = sourceHeight*scale;
    rect.origin.x = x;
    rect.origin.y = y;
    rect.size.width = w;
    rect.size.height = h;
    return rect;
}

@end
