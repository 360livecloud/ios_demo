//
//  QHVCToolDictionaryUtils.h
//  QHVCToolKit
//
//  Created by yangkui on 16/12/23.
//  Copyright © 2016年 qihoo 360. All rights reserved.
//

#import "QHVCToolUtils.h"

@interface QHVCToolUtils(QHVCToolDictionaryUtils)

+ (BOOL)dictionaryIsNull:(NSDictionary *)dict;
+ (BOOL)mutableDictionaryIsNull:(NSMutableDictionary *)dict;
+ (NSString *) dictionaryConversionToString:(NSDictionary *)dict;


+ (void)setBooleanToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(BOOL)value;
+ (void)setIntToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(int)value;
+ (void)setLongToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(NSInteger)value;
+ (void)setUnsignedLongToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(NSUInteger)value;
+ (void)setDoubleToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(double)value;
+ (void)setStringToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(NSString *)value;
+ (void)setNumberToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(NSNumber *)value;
+ (void)setObjectToDictionary:(NSMutableDictionary *)dict key:(NSString *)key value:(id)value;

+ (BOOL)getBooleanFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(BOOL)defaultValue;
+ (int)getIntFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(int)defaultValue;
+ (NSInteger)getLongFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(NSInteger)defaultValue;
+ (NSUInteger)getUnsignedLongFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(NSUInteger)defaultValue;
+ (double)getDoubleFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(double)defaultValue;
+ (NSString *)getStringFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(NSString *)defaultValue;
+ (NSNumber *)getNumberFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(NSNumber *)defaultValue;
+ (id)getObjectFromDictionary:(NSDictionary *)dict key:(NSString *)key defaultValue:(id)defaultValue;

@end
