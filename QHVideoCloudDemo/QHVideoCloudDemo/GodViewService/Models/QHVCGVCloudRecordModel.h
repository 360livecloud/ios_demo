//
//  QHVCGVCloudRecordModel.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVCloudRecordModel : NSObject

@property (nonatomic,strong) NSDate *recordDate;
/// 用户id
@property (nonatomic,assign) NSInteger uid;
/// 云存id
@property (nonatomic,assign) NSInteger recordId;
/// 流id
@property (nonatomic,strong) NSString *streamId;
/// 播放地址
@property (nonatomic,strong) NSString *url;
/// 缩略图
@property (nonatomic,strong) NSString *thumbnail;
/// 持续时长
@property (nonatomic,strong) NSString *duration;
/// 加密key
@property (nonatomic,strong) NSString *encryptKey;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
