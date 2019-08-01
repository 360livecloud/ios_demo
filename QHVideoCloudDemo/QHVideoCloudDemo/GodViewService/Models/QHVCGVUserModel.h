//
//  QHVCITSUserModel.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

//用户数据定义

#import <Foundation/Foundation.h>

@interface QHVCGVUserModel : NSObject
/// 用户唯一标识
@property (nonatomic, copy) NSString* userId;
/// 用于信令、rtc通话的id
@property (nonatomic, copy) NSString *talkId;
/// 昵称
@property (nonatomic, copy) NSString* nickName;
/// 业务认证token
@property (nonatomic, copy) NSString *token;
///肖像
@property (nonatomic, copy) NSString* portraint;
//0女性，1男性
@property (nonatomic, assign) NSInteger gender;

@end
