//
//  QHVCGVStreamSecureOperation.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/13.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCGVStreamSecureOperation.h"
#import "QHVCGodViewHttpBusiness.h"
#import "QHVCLogger.h"

typedef NS_ENUM(NSInteger, ConcurrentOperationState) {
    QHVCGVStreamSecureOperationReadyState = 1,
    QHVCGVStreamSecureOperationExecutingState,
    QHVCGVStreamSecureOperationFinishedState
};

@interface QHVCGVStreamSecureOperation ()
@property (nonatomic, assign) ConcurrentOperationState state;
@end

@implementation QHVCGVStreamSecureOperation

- (BOOL)isReady {
    self.state = QHVCGVStreamSecureOperationReadyState;
    return self.state == QHVCGVStreamSecureOperationReadyState;
}
- (BOOL)isExecuting{
    return self.state == QHVCGVStreamSecureOperationExecutingState;
}
- (BOOL)isFinished{
    return self.state == QHVCGVStreamSecureOperationFinishedState;
}

- (void)start {
    if ([QHVCToolUtils isNullString:_deviceSN]) {
        [self willChangeValueForKey:@"isFinished"];
        self.state = QHVCGVStreamSecureOperationFinishedState;
        [self didChangeValueForKey:@"isFinished"];
        if (self.callback) {
            self.callback(NO, nil);
        }
    }
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"流加密 - 开始获取密码:%@",self.deviceSN]];
    [self willChangeValueForKey:@"isExecuting"];
    self.state = QHVCGVStreamSecureOperationExecutingState;
    [self didChangeValueForKey:@"isExecuting"];
    
    [QHVCGodViewHttpBusiness getStreamPwdWithParams:[@{@"binded_sn":_deviceSN} mutableCopy] complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        if (self.callback) {
            self.callback(success, responseDict);
        }
        [self willChangeValueForKey:@"isFinished"];
        self.state = QHVCGVStreamSecureOperationFinishedState;
        [self didChangeValueForKey:@"isFinished"];
    }];
}

-(void)dealloc{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"dealloc called %@",self.name]];
}

@end
