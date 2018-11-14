//
//  QHVCIMChatroomInfo.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/6.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCIMStatusDefine.h"
#import "QHVCIMChatroomMemberInfo.h"

@interface QHVCIMChatroomInfo : NSObject

@property(nonatomic, strong) NSString *roomId;//聊天室ID
@property(nonatomic, assign) QHVCMemberOrder memberOrder;

/*
 * 聊天室中的部分成员信息QHVCIMChatroomMemberInfo列表
 
 * @discussion
 * 如果成员类型为QHVCMemberOrderedAscending，则为最早加入的成员列表，按成员加入时间升序排列；
 * 如果成员类型为QHVCMemberOrderedDescending，则为最晚加入的成员列表，按成员加入时间升序排列。
 */
@property(nonatomic, strong) NSArray<QHVCIMChatroomMemberInfo *> *memberInfoArray;
@property(nonatomic, assign) int totalMemberCount;//当前聊天室的成员总数

@end
