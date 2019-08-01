//
//  QHVCGVCloudRecordViewModel.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class QHVCGVCloudRecordModel;
@interface QHVCGVCloudRecordViewModel : NSObject
- (void)refreshCloudRecordListWithSerialNumber:(NSString *)serialNumber
                                    completion:(void(^)(NSArray<QHVCGVCloudRecordModel *> *lists))completion;

- (void)deleteCloudRecordWithSerialNumber:(NSString *)serialNumber
                                 recordId:(NSInteger)recordId
                               completion:(void(^)(BOOL isSuccess))completion;
@end

NS_ASSUME_NONNULL_END
