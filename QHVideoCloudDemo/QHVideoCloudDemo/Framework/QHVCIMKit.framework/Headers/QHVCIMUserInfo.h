//
//  QHVCIMUserInfo.h
//  QHVCIMKit
//
//  Created by deng on 2018/3/9.
//  Copyright © 2018年 qihoo.QHVCIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCIMUserInfo : NSObject

/*!
 用户ID
 */
@property(nonatomic, strong) NSString *userId;

/*!
 用户名称
 */
@property(nonatomic, strong) NSString *name;

/*!
 用户头像的URL
 */
@property(nonatomic, strong) NSString *portraitUri;

@end
