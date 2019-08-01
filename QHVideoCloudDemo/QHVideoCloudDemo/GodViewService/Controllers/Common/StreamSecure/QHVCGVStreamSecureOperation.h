//
//  QHVCGVStreamSecureOperation.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/13.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCCommonKit/QHVCCommonKit.h>

typedef void(^QHVCGVStreamSecureOperationBlock) (BOOL isSuccess, NSDictionary *responseDict);

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVStreamSecureOperation : NSOperation
@property (nonatomic,copy) NSString *deviceSN;
@property (nonatomic,copy) QHVCGVStreamSecureOperationBlock callback;

@end

NS_ASSUME_NONNULL_END
