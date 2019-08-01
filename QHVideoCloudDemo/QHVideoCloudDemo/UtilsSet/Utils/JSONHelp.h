//
//  JSONHelp.h
//  living
//
//  Created by HJSDK on 15/12/23.
//  Copyright © 2015年 MJHF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONHelp : NSObject

//json data转dictionary
+(id)data2NSDictionary:(NSData *)data;

//json string转dictionary
+(id)string2NSObject:(NSString *)dataStr;

//dictionary转nsstring
+(id)nsdictionary2NSString:(NSObject *)data;

//nsarray转nsstring json
+ (NSString *)nsarray2NSString:(NSArray *)array;

+(NSData *)objectToJsonData:(id)obj;

@end
