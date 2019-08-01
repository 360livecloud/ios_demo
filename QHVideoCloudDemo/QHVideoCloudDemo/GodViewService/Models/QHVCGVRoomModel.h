//
//  QHVCITSRoomModel.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

//房间数据定义

#import <Foundation/Foundation.h>
#import "QHVCGVConfig.h"

@interface QHVCGVRoomModel : NSObject

@property (nonatomic, strong) NSString* roomId;
@property (nonatomic, strong) NSString* roomName;
@property (nonatomic, strong) NSString *deviceTalkId;

- (void)parseServerData:(NSDictionary *_Nullable)dict;

@end
