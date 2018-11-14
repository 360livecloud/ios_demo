//
//  QHVCITSUserSystem.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCITSUserModel.h"
#import "QHVCITSRoomModel.h"

@interface QHVCITSUserSystem : NSObject

@property (nonatomic, strong, nonnull) QHVCITSUserModel* userInfo;//用户数据对象
@property (nonatomic, strong, nullable) QHVCITSRoomModel* roomInfo;//用户所在的房间信息

+ (nonnull instancetype)sharedInstance;

- (NSString *_Nullable) getUserSign;

@end
