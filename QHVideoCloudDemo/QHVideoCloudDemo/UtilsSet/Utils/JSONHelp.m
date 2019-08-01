//
//  JSONHelp.m
//  living
//
//  Created by HJSDK on 15/12/23.
//  Copyright © 2015年 MJHF. All rights reserved.
//

#import "JSONHelp.h"

@implementation JSONHelp

//json data转dictionary
+(id)data2NSDictionary:(NSData *)data
{
    __autoreleasing NSError* error = nil;
    if (!data) { //如果data是nil，调用NSJSONSerialization JSONObjectWithData会导致crash
        return nil;
    }
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

+(id)string2NSObject:(NSString *)dataStr
{
    if (dataStr.length == 0)
    {
        return nil;
    }
    
    NSData* data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) { //如果data是nil，调用NSJSONSerialization JSONObjectWithData会导致crash
        return nil;
    }
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

+(id)nsdictionary2NSString:(NSObject *)data
{
    if ([NSJSONSerialization isValidJSONObject:data])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"json data:%@",json);
        
        return json;
    }
    return nil;
}

+ (NSString *)nsarray2NSString:(NSArray *)array
{
    if ([NSJSONSerialization isValidJSONObject:array])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json data:%@",json);
        
        return json;
    }
    return @"";
}

+(NSData *)objectToJsonData:(id)obj{
    if ([NSJSONSerialization isValidJSONObject:obj])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
        return jsonData;
    }
    return nil;
}

@end
