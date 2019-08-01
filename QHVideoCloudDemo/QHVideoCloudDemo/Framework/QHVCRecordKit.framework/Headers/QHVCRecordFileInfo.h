//
//  QHVCRecordFileInfo.h
//  QHVCRecordKit
//
//  Created by deng on 2019/6/6.
//  Copyright © 2019 qihoo.QHVC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecordFileInfo : NSObject

@property (nonatomic, assign) int64_t duration;//ms
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) int64_t audioDuration;//ms

@end

NS_ASSUME_NONNULL_END
