//
//  QHVCITSRoomModel.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

//房间数据定义

#import <Foundation/Foundation.h>
#import "QHVCITSConfig.h"
#import <QHVCInteractiveKit/QHVCInteractiveKit.h>

@interface QHVCITSRoomModel : NSObject

@property (nonatomic, strong, nullable) NSString* roomId;
@property (nonatomic, strong, nullable) NSString* roomName;
@property (nonatomic, assign) QHVCITSRoomType roomType;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, assign) NSInteger maxNum;
@property (nonatomic, strong, nullable) NSString* bindRoleId;
@property (nonatomic, strong, nullable) NSDate* createTime;
@property (nonatomic, assign) QHVCITSTalkType talkType;
@property (nonatomic, assign) QHVCITSRoomLifeCycle roomLifeType;

- (void)parseServerData:(NSDictionary *_Nullable)dict;

@end
