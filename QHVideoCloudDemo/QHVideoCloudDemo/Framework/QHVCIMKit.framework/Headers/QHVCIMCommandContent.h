//
//  QHVCIMCommandMessage.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/7.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import "QHVCIMMessageContent.h"

/*!
 命令消息类
 
 @discussion 命令消息类，此消息不存储不计入未读消息数。
 与RCCommandNotificationMessage的区别是，此消息不存储，也不会在界面上显示。
 */

@interface QHVCIMCommandContent : QHVCIMMessageContent

/*!
 命令的名称
 */
@property(nonatomic, strong) NSString *name;

/*!
 命令的扩展数据
 
 @discussion 命令的扩展数据，可以为任意字符串，如存放您定义的json数据。
 */
@property(nonatomic, strong) NSString *data;

@end
