//
//  QHVCGVLunarFormatterObject.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/10/9.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVLunarFormatterObject.h"

@interface QHVCGVLunarFormatterObject ()

@property (strong, nonatomic) NSCalendar *chineseCalendar;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSArray<NSString *> *lunarDays;
@property (strong, nonatomic) NSArray<NSString *> *lunarMonths;

@end


@implementation QHVCGVLunarFormatterObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.chineseCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
        self.formatter = [[NSDateFormatter alloc] init];
        self.formatter.calendar = self.chineseCalendar;
        self.formatter.dateFormat = @"M";
        self.lunarDays = @[@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"二一",@"二二",@"二三",@"二四",@"二五",@"二六",@"二七",@"二八",@"二九",@"三十"];
        self.lunarMonths = @[@"正月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月",@"八月",@"九月",@"十月",@"冬月",@"腊月"];
    }
    return self;
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSInteger day = [self.chineseCalendar component:NSCalendarUnitDay fromDate:date];
    if (day != 1) {
        return self.lunarDays[day-2];
    }
    // First day of month
    NSString *monthString = [self.formatter stringFromDate:date];
    if ([self.chineseCalendar.veryShortMonthSymbols containsObject:monthString]) {
        return self.lunarMonths[monthString.integerValue-1];
    }
    // Leap month
    NSInteger month = [self.chineseCalendar component:NSCalendarUnitMonth fromDate:date];
    monthString = [NSString stringWithFormat:@"闰%@", self.lunarMonths[month-1]];
    return monthString;
}

@end
