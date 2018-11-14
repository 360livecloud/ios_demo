//
//  QHVCToolNumberUtils.h
//  QHVCToolKit
//
//  Created by yangkui on 16/12/23.
//  Copyright © 2016年 qihoo 360. All rights reserved.
//

#import "QHVCCommonTool.h"

@interface QHVCToolUtils(QHVCToolNumberUtils)

/**
 数字对象Number对象

 @param value 带转换的对象
 @return 转换后的结果
 */
+ (id)valueToNumber:(id)value;


/**
 获取随机数

 @return 随机数
 */
+ (int)getRandomNumber;


/**
 获取指定区间的随机数

 @param start 启始值
 @param end 结束值
 @return 随机数
 */
+ (int)getRandomNumber:(int)start end:(int)end;


/**
 判断是否为整形数

 @param string 参数
 @return YES/NO
 */
+ (BOOL)isPureInt:(NSString*)string;


/**
 判断是否为浮点形

 @param string 参数
 @return YES/NO
 */
+ (BOOL)isPureFloat:(NSString*)string;
@end
