//
//  QHVCGVDeviceModel.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVDeviceModel : NSObject
/// 绑定设备的sn
@property (nonatomic,copy) NSString *bindedSN;
/// 设备uid
@property (nonatomic,copy) NSString *talkId;
/// 数据流id
@property (nonatomic,copy) NSString *streamId;
/// 设备名
@property (nonatomic,copy) NSString *name;
/// 绑定时间
@property (nonatomic,copy) NSString *bindTime;
/// 扩展字段
@property (nonatomic,copy) NSString *txt;
/// 缩略图地址
@property (nonatomic,copy) NSString *converImg;
/// 用户角色 0所有者  1其他
@property (nonatomic,assign) NSInteger role;
/// 是否为IPC 0表示IPC 1表示NVR
@property (nonatomic,assign) NSInteger isPublic;
/// 此设备秘钥刷新间隔
@property(nonatomic,assign) NSUInteger pwdFetchInterval;
/// 流秘钥
@property (nonatomic,strong) NSArray<NSDictionary *> *pwds;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
