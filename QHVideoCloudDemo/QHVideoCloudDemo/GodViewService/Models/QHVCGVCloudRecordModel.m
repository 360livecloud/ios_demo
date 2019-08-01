//
//  QHVCGVCloudRecordModel.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVCloudRecordModel.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@implementation QHVCGVCloudRecordModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.uid = [QHVCToolUtils getIntFromDictionary:dict key:@"uid" defaultValue:0];
        self.recordId = [QHVCToolUtils getIntFromDictionary:dict key:@"id" defaultValue:0];
        self.streamId = [QHVCToolUtils getStringFromDictionary:dict key:@"stream_id" defaultValue:nil];
        self.url = [QHVCToolUtils getStringFromDictionary:dict key:@"url" defaultValue:nil];
        self.thumbnail = [QHVCToolUtils getStringFromDictionary:dict key:@"image" defaultValue:nil];
        self.duration = [QHVCToolUtils getStringFromDictionary:dict key:@"duration" defaultValue:nil];
        self.encryptKey = [QHVCToolUtils getStringFromDictionary:dict key:@"encrypt_key" defaultValue:nil];        
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n%@ : {\nuid:%zd,\nrecordId:%zd,\nstreamId:%@,\nurl:%@,\nthumbnail:%@,\nduration:%@,\nencryptKey:%@\n}",NSStringFromClass([self class]),_uid,_recordId,_streamId,_url,_thumbnail,_duration,_encryptKey];
}

@end
