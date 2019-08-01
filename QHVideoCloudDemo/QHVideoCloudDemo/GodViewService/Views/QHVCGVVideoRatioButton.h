//
//  QHVCGVVideoRatioButton.h
//  QHVideoCloudToolSetDebug
//
//  Created by jiangbingbing on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCGVWatchRecordCircleBtn.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^QHVCGVVideoRatioButtonSelectedCallback) (NSString *videoRatio);

@protocol QHVCGVVideoRatioButtonDelegate <NSObject>
// 选择的倍率  "1","1.5",.....
- (void)videoRatioButtonDidSelectVideoRatio:(NSString *)videoRatio;
@end

@interface QHVCGVVideoRatioButton : QHVCGVWatchRecordCircleBtn
@property(nonatomic,weak) id<QHVCGVVideoRatioButtonDelegate>delegate;
/**
 * 设置可选择的倍率
 * @param videoRatios 倍率数组 如：@[@"1",@"1.5",@"2"...]
 */
- (void)setupWithVideoRatios:(NSArray<NSString *> *)videoRatios;

@end

NS_ASSUME_NONNULL_END
