//
//  QHVCIMTextMessage.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/7.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import "QHVCIMMessageContent.h"

/*!
 文本消息类
 
 @discussion 文本消息类，此消息会进行存储并计入未读消息数。
 */

@interface QHVCIMTextContent : QHVCIMMessageContent

/*!
 文本消息的内容
 */
@property(nonatomic, strong) NSString *content;

/*!
 文本消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

@end
