//
//  QHVCTool.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/27.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCTool : NSObject

+ (NSDate *)getCurrentTimeZoneDate;

+ (NSString *)getTimeStringBySecond:(NSUInteger)timeSecond format:(NSString *)format;

+ (NSString *)getTimeStringByDate:(NSDate *)date format:(NSString *)format;

+ (NSDate *)getDateByString:(NSString *)stringDate format:(NSString *)format;

/**
 * 将utc时间戳进行截取，得到当天从00:00:00后的秒数
 */
+ (NSTimeInterval)surplusIntervalThatDayFromUTCInterval:(NSTimeInterval)utcTimestamp;

/**
 设置状态栏颜色

 @param color 状态栏颜色
 */
+ (void)setStatusBarBackgroundColor:(UIColor *)color;
@end
