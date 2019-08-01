//
//  QHVCToolTimeUtils.h
//  QHVCToolKit
//
//  Created by yangkui on 17/1/16.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import "QHVCToolUtils.h"

@interface QHVCToolUtils(QHVCToolTimeUtils)

+ (NSDate *)getCurrentDate;

+ (NSTimeInterval)getCurrentDateByTimeInterval;

+ (long long)getCurrentDateBySecond;

+ (long long)getCurrentDateByMilliscond;

+ (NSDateComponents *)getCurrentDateByComponents;

+ (NSString *)getDateByStringFormat:(NSDate *)date format:(NSString *)format;

+ (NSString *)getCurrentDateByFormat:(NSString *)format;

+ (NSDate *)getStringDateByDateFormat:(NSString *)time format:(NSString *)format;

@end
