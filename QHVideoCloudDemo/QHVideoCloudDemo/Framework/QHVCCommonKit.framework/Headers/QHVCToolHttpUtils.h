//
//  QHVCToolHttpUtils.h
//  QHVCToolKit
//
//  Created by yangkui on 17/1/13.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCToolUtils.h"

@interface QHVCToolUtils(QHVCToolHttpUtils)

/**
 流量格式化
 
 @param bytes 流量字节数
 @return B、KB、MB、GB
 */
+ (NSString *)rateOfFlowFormat:(int)bytes;

/**
 解析网络格式数据，转换为字典数据格式,例如:'a=b&c=d'
 
 @param string 网络返回的数据
 @param firstSeparator 第一个分隔符,比如'&'
 @param secondSeparator 第二个分隔符，比如'='
 @return 返回字典数据
 */
+ (NSDictionary*) stringConversionDictionaryByNetData:(NSString *)string firstSeparator:(NSString *)firstSeparator secondSeparator:(NSString *)secondSeparator;


/**
 把字典数据转换为网络格式的字符串数据
 
 @param dict 待转换的字典数据
 @param firstSeparator 第一个分隔符,比如'&'
 @param secondSeparator 第二个分隔符，比如'='
 @return 返回字符串数据
 */
+ (NSString*) dictionaryConversionStringByNetData:(NSDictionary *)dict firstSeparator:(NSString *)firstSeparator secondSeparator:(NSString *)secondSeparator;


/**
 对指定字符串进行编码转换
 转换字符串格式为网络传输格式

 @param urlString 待转换的字符串
 @return 返回转换的结果
 */
+ (NSString *)urlEncode:(NSString *)urlString;


/**
 对指定字符串进行编码转换
 转换字符串格式为网络传输格式

 @param urlString 待转换的字符串
 @return 返回转换的结果
 */
+ (NSString *)urlDecode:(NSString *)urlString;


/**
 字典转换为json格式数据

 @param dictionary 待转换的字典
 @return 返回json格式数据
 */
+ (NSData *)createJsonDataWithDictionary:(NSDictionary *)dictionary;


/**
 json格式转换为字典数据格式

 @param jsonData 待转换的json
 @return 返回转换后的字典数据
 */
+ (NSDictionary *)resolveJsonDataToDictionary:(NSData *)jsonData;


/**
 根据域名获取IP地址

 @param hostName 域名
 @return 转换后的IP地址
 */
+ (NSString *)getIPAddressByHostName:(NSString*)hostName;


/**
 根据url获取IP地址

 @param url 地址链接
 @return 转换后的IP域名
 */
+ (NSString *)getIPAddressByUrl:(NSString*)url;


/**
 获取Sha1签名

 @param data 待签名的数据
 @return 签名结果
 */
+ (NSString *)sha1:(NSData *)data;

@end
