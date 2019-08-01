//
//  QHVCTool.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/27.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCTool.h"

@implementation QHVCTool

+ (NSDate *)getCurrentTimeZoneDate
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];
    return localDate;
}

+ (NSString *)getTimeStringBySecond:(NSUInteger)timeSecond format:(NSString *)format
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:timeSecond];
    NSString * timeString = [formatter stringFromDate:date];
    return timeString;
}

+ (NSString *)getTimeStringByDate:(NSDate *)date format:(NSString *)format
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString * timeString = [formatter stringFromDate:date];
    return timeString;
}

+ (NSDate *)getDateByString:(NSString *)stringDate format:(NSString *)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:stringDate];
    return date;
}

/**
 * 将utc时间戳进行截取，得到当天从00:00:00后的秒数
 */
+ (NSTimeInterval)surplusIntervalThatDayFromUTCInterval:(NSTimeInterval)utcTimestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:utcTimestamp / 1000];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *dayString = [df stringFromDate:date];
    NSDate *date2 = [df dateFromString:dayString];
    NSTimeInterval interval = [date timeIntervalSinceDate:date2];
    return interval;
}

//设置状态栏颜色
+ (void)setStatusBarBackgroundColor:(UIColor *)color
{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
    {
        statusBar.backgroundColor = color;
    }
}

@end

