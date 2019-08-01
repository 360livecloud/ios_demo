//
//  QHVCITSRoomModel.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVRoomModel.h"
#import "QHVCGVDefine.h"
#import "QHVCGVConfig.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@implementation QHVCGVRoomModel

- (void)parseServerData:(NSDictionary *_Nullable)dict
{
    _roomId = [QHVCToolUtils getStringFromDictionary:dict key:QHVCGV_KEY_ROOM_ID defaultValue:_roomId];
    _roomName = [QHVCToolUtils getStringFromDictionary:dict key:QHVCGV_KEY_ROOM_NAME defaultValue:_roomName];
}

@end
