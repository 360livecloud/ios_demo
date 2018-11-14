//
//  QHVCIMChatroomMemberInfo.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/7.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * 聊天室成员信息类
 */

@interface QHVCIMChatroomMemberInfo : NSObject

@property(nonatomic, strong) NSString *userId;//用户ID
@property(nonatomic, assign) long long joinTimeMs;//加入时间（Unix时间戳，毫秒）

@end
