//
//  QHVCToolStringUtils.h
//  QHVCToolKit
//
//  Created by yangkui on 16/12/1.
//  Copyright © 2016年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCToolUtils.h"

@class UIColor;
@interface QHVCToolUtils(QHVCToolStringUtils)


/**
 判断字符串是否为空

 @param string 字符串参数
 @return YES 代表为空，NO代表为非空
 */
+ (BOOL)isNullString:(NSString *)string;


/**
 去掉字符串首尾空格

 @param string 字符串参数
 @return 去掉空格后的结果
 */
+ (NSString *)trimWithString:(NSString *)string;


/**
 目标对象转换为String对象

 @param value 字符串或者NSNumber对象
 @return 返回字符串或者原对象
 */
+ (id)valueToString:(id)value;


/**
 获取字符串MD5值

 @param string 需要计算的字符串对象
 @return MD5后的返回值
 */
+ (NSString *)getMD5String:(NSString *)string;


/**
 获取RC4字符串
 
 @param aInput 待编码的字符串
 @param aKey 加／解秘的key
 @return 转换的字符串
 */
+ (NSString *) getRC4String:(NSData *)aInput key:(NSString*)aKey;


/**
 获取RC4 NSData

 @param aInput 待编码的字符串
 @param aKey 加／解秘的key
 @return 转换的NSData
 */
+ (NSData *) getRC4Data:(NSData *)aInput key:(NSString*)aKey;


/**
 UIColor转换为字符串对象

 @param color 待转换的颜色
 @return 转换后的字符串值
 */
+ (NSString *)hexStringFromColor:(UIColor *)color;


/**
 字符串转换为UIColor对象

 @param hexString 待转换的字符串
 @return 转换后的UIColor对象
 */
+ (UIColor *) colorWithHexString: (NSString *) hexString;

@end
