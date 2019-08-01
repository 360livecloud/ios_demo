//
//  QHVCRecordSegmentInfo.h
//  QHVCRecordKit
//
//  Created by deng on 2018/12/20.
//  Copyright © 2018年 qihoo.QHVC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecordSegmentInfo : NSObject

@property (nonatomic, assign) int segId;
@property (nonatomic, assign) int64_t duration;//ms
@property (nonatomic, assign) BOOL isValid;//标识该段是否整段被回删掉
@property (nonatomic, assign) float speed;
@property (nonatomic, strong) NSString *path;

@end

NS_ASSUME_NONNULL_END
