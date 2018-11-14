//
//  QHVCITSUserModel.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

//用户数据定义

#import <Foundation/Foundation.h>
#import "QHVCITSConfig.h"

@interface QHVCITSUserModel : NSObject

@property (nonatomic, strong, nullable) NSString* userId;
@property (nonatomic, strong, nullable) NSString* nickName;
@property (nonatomic, strong, nullable) NSString* portraint;//肖像
@property (nonatomic, assign) NSInteger gender;//0女性，1男性
@property (nonatomic, strong, nullable) NSDictionary* imContext;

@property (nonatomic, assign) QHVCITSIdentity identity;//角色身份

@end
