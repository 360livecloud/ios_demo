//
//  QHVCGVWatchRecordDatePenel.h
//  QHVideoCloudToolSetDebug
//
//  Created by jiangbingbing on 2018/10/29.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QHVCGVWatchRecordDatePenelDelegate <NSObject>
@optional
// 点击日期按钮
- (void)watchRecordDatePenelDidClickDate;
// 点击前一天箭头
- (void)watchRecordDatePenelDidClickLastDay;
// 点击后一天箭头
- (void)watchRecordDatePenelDidClickNextDay;
@end

@interface QHVCGVWatchRecordDatePenel : UIView
@property(nonatomic,weak) id<QHVCGVWatchRecordDatePenelDelegate>delegate;
- (void)setupUI;
- (void)setLastDayBtnEnable:(BOOL)enabled;
- (void)setNextDayBtnEnable:(BOOL)enabled;
- (void)updateTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
