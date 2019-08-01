//
//  QHVCGVCloudRecordViewModel.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVCloudRecordViewModel.h"
#import "QHVCGVCloudRecordModel.h"
#import "QHVCGodViewHttpBusiness.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGVDefine.h"
#import "QHVCToast.h"

@implementation QHVCGVCloudRecordViewModel
- (void)refreshCloudRecordListWithSerialNumber:(NSString *)serialNumber completion:(void(^)(NSArray<QHVCGVCloudRecordModel *> *lists))completion
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [QHVCToolUtils setStringToDictionary:params key:@"binded_sn" value:serialNumber];
    
    [QHVCGodViewHttpBusiness getCloudRecordList:params complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        if (success)
        {
            NSDictionary *dataDict = [QHVCToolUtils getObjectFromDictionary:responseDict key:QHVCGV_KEY_DATA defaultValue:nil];
            NSArray *list = [QHVCToolUtils getObjectFromDictionary:dataDict key:@"list" defaultValue:nil];
            NSMutableArray *deviceLists = [NSMutableArray new];
            for (NSDictionary * dict in list)
            {
                if (![QHVCToolUtils dictionaryIsNull:dict])
                {
                    QHVCGVCloudRecordModel *deviceModel = [[QHVCGVCloudRecordModel alloc] initWithDict:dict];
                    [deviceLists addObject:deviceModel];
                }
            }
            if (completion)
            {
                completion(deviceLists.reverseObjectEnumerator.allObjects);
//                completion([self getTestData]);
            }
        }
        else
        {
            if (completion)
            {
                completion(nil);
            }
            NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
            NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
            [QHVCToast makeToast:[NSString stringWithFormat:@"获取云录列表失败 errno:%zd errmsg:%@",errNo,errmsg]];
        }
    }];
}

- (void)deleteCloudRecordWithSerialNumber:(NSString *)serialNumber recordId:(NSInteger)recordId completion:(void(^)(BOOL isSuccess))completion
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [QHVCToolUtils setStringToDictionary:params key:@"binded_sn" value:serialNumber];
    [QHVCToolUtils setIntToDictionary:params key:@"id" value:(int)recordId];
    
    [QHVCGodViewHttpBusiness deleteCloudRecord:params complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        if (success)
        {
            NSDictionary *dataDict = [QHVCToolUtils getObjectFromDictionary:responseDict key:QHVCGV_KEY_DATA defaultValue:nil];
            int ret = [QHVCToolUtils getIntFromDictionary:dataDict key:@"ret" defaultValue:0];
            if (completion) {
                completion(ret == 1);
            }
        }
        else
        {
            if (completion)
            {
                completion(NO);
            }
            NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
            NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
            [QHVCToast makeToast:[NSString stringWithFormat:@"删除云录失败 errno:%zd errmsg:%@",errNo,errmsg]];
        }

    }];
}

- (NSArray *)getTestData
{
    NSMutableArray *records = [NSMutableArray new];
    for (NSUInteger idx = 0; idx < 20; idx++)
    {
        QHVCGVCloudRecordModel *model = [QHVCGVCloudRecordModel new];
        model.thumbnail = @"godview_record_thumbnail_tmp";
        model.recordDate = [NSDate date];
//        model.url = @"http://vod.che.360.cn/vod-car-bj/112470524_2-1523501461-dfd4df59-831e-4634.mp4";
        model.url = @"http://yunxianchang.live.ujne7.com/vod-system-bj/360H0700078_01_1547608605.m3u8";
        model.encryptKey = @"127&1547605145766af65f!bba4@7f60$";
        [records addObject:model];
    }
    return [records copy];
}

@end
