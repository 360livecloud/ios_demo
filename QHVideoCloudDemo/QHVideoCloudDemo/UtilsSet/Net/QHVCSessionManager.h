//
//  QHVCSessionManager.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/17.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@interface QHVCSessionManager : AFHTTPSessionManager

+ (instancetype)sharedInstance;

@end
