//
//  QHVCITSUserSystem.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSUserSystem.h"
#import "QHVCITSConfig.h"

@interface QHVCITSUserSystem()


@end

@implementation QHVCITSUserSystem

+ (nonnull instancetype)sharedInstance
{
    static QHVCITSUserSystem * s_instance = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [QHVCITSUserSystem new];
    });
    return s_instance;
}

- (id)init
{
    self = [super init];
 
    return self;
}

- (NSString *) getUserSign
{
    NSString* channelId = [[QHVCITSConfig sharedInstance] channelId];
    NSString* userId = [self userInfo].userId;
    NSString* roomId = [_roomInfo roomId];
    NSString* appSecret = [[QHVCITSConfig sharedInstance] appSecret];
    if([QHVCToolUtils isNullString:userId] || [QHVCToolUtils isNullString:roomId] || [QHVCToolUtils isNullString:channelId] || [QHVCToolUtils isNullString:appSecret])
    {
        return nil;
    }
    NSString* temp = [NSString stringWithFormat:@"app_name__%@room_id__%@uid__%@%@",channelId,roomId,userId,appSecret];
    NSString* md5 = [QHVCToolUtils getMD5String:temp];
    return md5;
}

@end
