//
//  QHVCEditReverseManager.h
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/7/31.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QHVCEditCommandAddFileSegment;

typedef void (^HandleStart)();
typedef void (^HandleComplete)(NSInteger fileIndex, NSString *reverseFilePath);
typedef void (^Handling)(float progress);

@interface QHVCEditReverseManager : NSObject

@property (nonatomic, copy) HandleStart handleStart;
@property (nonatomic, copy) Handling handling;
@property (nonatomic, copy) HandleComplete handleComplete;

+ (instancetype)sharedInstance;

- (void)handle:(QHVCEditCommandAddFileSegment *)segment;
- (void)freeManager;

@end
