//
//  QHVCITSRoomModel.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSRoomModel.h"
#import "QHVCITSDefine.h"
#import "QHVCITSConfig.h"

@implementation QHVCITSRoomModel

- (void)parseServerData:(NSDictionary *_Nullable)dict
{
    _roomId = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_ROOM_ID defaultValue:_roomId];
    _roomName = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_ROOM_NAME defaultValue:_roomName];
    _roomType = [QHVCToolUtils getIntFromDictionary:dict key:QHVCITS_KEY_ROOM_TYPE defaultValue:_roomType];
    _num = [QHVCToolUtils getLongFromDictionary:dict key:QHVCITS_KEY_NUM defaultValue:_num];
    _maxNum = [QHVCToolUtils getLongFromDictionary:dict key:QHVCITS_KEY_MAX_NUMBER defaultValue:_maxNum];
    _bindRoleId = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_BIND_ROLE_ID defaultValue:_bindRoleId];
    _talkType = (QHVCITSTalkType)[QHVCToolUtils getIntFromDictionary:dict key:QHVCITS_KEY_TALK_TYPE defaultValue:_talkType];
    _roomLifeType = (QHVCITSRoomLifeCycle)[QHVCToolUtils getIntFromDictionary:dict key:QHVCITS_KEY_ROOM_LIFE_TYPE defaultValue:_roomLifeType];
    NSString* tmpCreateTime = [QHVCToolUtils getStringFromDictionary:dict key:QHVCITS_KEY_CREATE_TIME defaultValue:@"1970-01-01 00:00:00"];
    _createTime = [QHVCToolUtils getStringDateByDateFormat:tmpCreateTime format:@"yyyy-MM-dd HH:mm:ss"];
}

@end
