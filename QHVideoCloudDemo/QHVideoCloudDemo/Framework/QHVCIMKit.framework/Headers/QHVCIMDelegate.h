//
//  QHVCIMDelegate.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/9.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#ifndef QHVCIMDelegate_h
#define QHVCIMDelegate_h

@class QHVCIMMessage;

@protocol QHVCIMMessageDelegate <NSObject>
@optional
//消息相关
- (void)didRecieveNewMessage:(QHVCIMMessage *)message left:(int)left;

@end

#endif /* QHVCIMDelegate_h */

