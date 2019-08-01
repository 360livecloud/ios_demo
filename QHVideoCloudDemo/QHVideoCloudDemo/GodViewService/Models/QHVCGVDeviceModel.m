//
//  QHVCGVDeviceModel.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVDeviceModel.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@implementation QHVCGVDeviceModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.bindedSN = [QHVCToolUtils getStringFromDictionary:dict key:@"binded_sn" defaultValue:nil];
        self.talkId = [QHVCToolUtils getStringFromDictionary:dict key:@"talk_id" defaultValue:nil];
        self.streamId = [QHVCToolUtils getStringFromDictionary:dict key:@"stream_id" defaultValue:nil];
        self.name = [QHVCToolUtils getStringFromDictionary:dict key:@"name" defaultValue:nil];
        self.bindTime = [QHVCToolUtils getStringFromDictionary:dict key:@"bind_time" defaultValue:nil];
        self.role = [QHVCToolUtils getIntFromDictionary:dict key:@"role" defaultValue:0];
        self.isPublic = [QHVCToolUtils getIntFromDictionary:dict key:@"is_public" defaultValue:0];
        self.txt = [QHVCToolUtils getStringFromDictionary:dict key:@"txt" defaultValue:nil];
        self.converImg = [QHVCToolUtils getStringFromDictionary:dict key:@"cover_img" defaultValue:nil];
        
        id pwdObj = [QHVCToolUtils getObjectFromDictionary:dict key:@"pwd" defaultValue:nil];
        self.pwdFetchInterval = [QHVCToolUtils getIntFromDictionary:pwdObj key:@"interval" defaultValue:600];
        id pwds = [QHVCToolUtils getObjectFromDictionary:pwdObj key:@"pwds" defaultValue:nil];
        if ([pwds isKindOfClass:[NSArray class]]) {
            self.pwds = pwds;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n###QHVCGVDeviceModel {\nbindedSN:%@,\nuid:%@,\nsteramId:%@,\nname:%@,\nbindTime:%@\nrole:%zd,\nisPublic:%zd,\txt:%@,\npwdFetchInterval:%zd,\npwds:%@\n}",_bindedSN,_talkId,_streamId,_name,_bindTime,_role,_isPublic,_txt,_pwdFetchInterval,_pwds];
}

@end
