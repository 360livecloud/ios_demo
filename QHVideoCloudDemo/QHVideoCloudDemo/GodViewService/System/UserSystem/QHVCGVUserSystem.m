//
//  QHVCITSUserSystem.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVUserSystem.h"
#import "QHVCGVConfig.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
@interface QHVCGVUserSystem()


@end

@implementation QHVCGVUserSystem

+ (nonnull instancetype)sharedInstance
{
    static QHVCGVUserSystem * s_instance = NULL;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        s_instance = [QHVCGVUserSystem new];
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
    QHVCGlobalConfig* globalConfig = [QHVCGlobalConfig sharedInstance];
    NSString* appId = [globalConfig appId];
    NSString* talkId = [self userInfo].talkId;
    NSString* roomId = [_roomInfo roomId];
    NSString* appSecret = [globalConfig appSecret];
    if([QHVCToolUtils isNullString:talkId] || [QHVCToolUtils isNullString:roomId] || [QHVCToolUtils isNullString:appId] || [QHVCToolUtils isNullString:appSecret]) {
        return nil;
    }
    NSString* temp = [NSString stringWithFormat:@"sname__%@room_id__%@uid__%@%@",appId,roomId,talkId,appSecret];
    NSString* md5 = [QHVCToolUtils getMD5String:temp];
    return md5;
}

@end
