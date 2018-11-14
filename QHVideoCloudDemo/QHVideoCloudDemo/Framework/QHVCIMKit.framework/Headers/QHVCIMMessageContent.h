//
//  QHVCIMMessageContent.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/7.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCIMUserInfo.h"

@interface QHVCIMMessageContent : NSObject

/*!
 消息内容中携带的发送者的用户信息
 */
@property(nonatomic, strong) QHVCIMUserInfo *senderUserInfo;

@end
