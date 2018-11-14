//
//  QHVCInterfaceRequest.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/17.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCHTTPSession.h"

static const long successCode = 10000;
static const long failCode = 20000;

typedef void(^successBlock)( NSDictionary *_Nullable object,NSError * _Nullable error);
typedef void(^failBlock)(NSError * _Nullable error);

@interface QHVCInterfaceRequest : NSObject


/**
 直播列表
 */
+ (void)snListRequestWithsuccess:(nonnull successBlock)success fail:(nonnull failBlock)fail;

/**
 短视频列表
 */
+ (void)shortVideoListRequestWithParameter:(NSDictionary *_Nullable)para success:(nonnull successBlock)success fail:(nonnull failBlock)fail;

@end
