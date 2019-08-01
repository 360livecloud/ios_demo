//
//  QHVCGVWatchRecordDatePenel.m
//  QHVideoCloudToolSetDebug
//
//  Created by jiangbingbing on 2018/10/29.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVWatchRecordDatePenel.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGlobalConfig.h"

// "前一天"按钮
#define QHVCGVWatchRecordDatePenel_LastDayBtn_W                 (30.0f * kQHVCScreenScaleTo6)
#define QHVCGVWatchRecordDatePenel_LastDayBtn_H                 (30.0f * kQHVCScreenScaleTo6)
#define QHVCGVWatchRecordDatePenel_LastDayBtn_MarginLeft        (42.0f * kQHVCScreenScaleTo6)
// 日期小图标
#define QHVCGVWatchRecordDatePenel_DateIcon_W                   (17.0f * kQHVCScreenScaleTo6)
#define QHVCGVWatchRecordDatePenel_DateIcon_H                   (17.0f * kQHVCScreenScaleTo6)
#define QHVCGVWatchRecordDatePenel_DateIcon_MarginLeft          (17.0f * kQHVCScreenScaleTo6)
// 日期
#define QHVCGVWatchRecordDatePenel_DateBtn_W                    (190.0f * kQHVCScreenScaleTo6)
#define QHVCGVWatchRecordDatePenel_DateBtn_H                    (23.0f * kQHVCScreenScaleTo6)
#define QHVCGVWatchRecordDatePenel_DateBtn_MarginLeft           (3.5f * kQHVCScreenScaleTo6)

@interface QHVCGVWatchRecordDatePenel ()
@property (nonatomic,strong) UIButton *lastDayBtn;
@property (nonatomic,strong) UIButton *dateBtn;
@property (nonatomic,strong) UIButton *nextDayBtn;
@end

@implementation QHVCGVWatchRecordDatePenel

- (void)setupUI {
    // "前一天"按钮
    self.lastDayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lastDayBtn setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_lastday") forState:UIControlStateNormal];
    [_lastDayBtn addTarget:self action:@selector(lastDayBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_lastDayBtn];
    [_lastDayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(QHVCGVWatchRecordDatePenel_LastDayBtn_MarginLeft);
        make.top.equalTo(self);
        make.width.equalTo(@(QHVCGVWatchRecordDatePenel_LastDayBtn_W));
        make.height.equalTo(@(QHVCGVWatchRecordDatePenel_LastDayBtn_H));
    }];
    
    // 日期小图标
    UIImageView *dateIcon = [UIImageView new];
    dateIcon.image = kQHVCGetImageWithName(@"godview_icon_calendar");
    [self addSubview:dateIcon];
    [dateIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(QHVCGVWatchRecordDatePenel_DateIcon_W));
        make.height.equalTo(@(QHVCGVWatchRecordDatePenel_DateIcon_H));
        make.centerY.equalTo(_lastDayBtn);
        make.leading.equalTo(_lastDayBtn.mas_trailing).offset(QHVCGVWatchRecordDatePenel_DateIcon_MarginLeft);
    }];
    
    // 日期
    self.dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _dateBtn.backgroundColor = [UIColor clearColor];
    [_dateBtn setTitle:@"" forState:UIControlStateNormal];
    _dateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _dateBtn.titleLabel.font = kQHVCFontPingFangSCMedium(16);
    [_dateBtn setTitleColor:[QHVCToolUtils colorWithHexString:@"666666"] forState:UIControlStateNormal];
    [_dateBtn addTarget:self action:@selector(dateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_dateBtn];
    [_dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_lastDayBtn);
        make.width.equalTo(@(QHVCGVWatchRecordDatePenel_DateBtn_W));
        make.height.equalTo(@(QHVCGVWatchRecordDatePenel_DateBtn_H));
        make.leading.equalTo(dateIcon.mas_trailing).offset(QHVCGVWatchRecordDatePenel_DateBtn_MarginLeft);
    }];
    
    // "后一天"按钮
    self.nextDayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextDayBtn setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_nextday") forState:UIControlStateNormal];
    [_nextDayBtn addTarget:self action:@selector(nextDayBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nextDayBtn];
    [_nextDayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-QHVCGVWatchRecordDatePenel_LastDayBtn_MarginLeft);
        make.top.width.height.equalTo(_lastDayBtn);
    }];

}

- (void)setLastDayBtnEnable:(BOOL)enabled {
    self.lastDayBtn.enabled = enabled;
}

- (void)setNextDayBtnEnable:(BOOL)enabled {
    self.nextDayBtn.enabled = enabled;
}

- (void)dateBtnClicked {
    if ([self.delegate respondsToSelector:@selector(watchRecordDatePenelDidClickDate)]) {
        [self.delegate watchRecordDatePenelDidClickDate];
    }
}

- (void)lastDayBtnClicked {
    if ([self.delegate respondsToSelector:@selector(watchRecordDatePenelDidClickLastDay)]) {
        [self.delegate watchRecordDatePenelDidClickLastDay];
    }
}
- (void)nextDayBtnClicked {
    if ([self.delegate respondsToSelector:@selector(watchRecordDatePenelDidClickNextDay)]) {
        [self.delegate watchRecordDatePenelDidClickNextDay];
    }
}

- (void)updateTitle:(NSString *)title {
    [_dateBtn setTitle:title forState:UIControlStateNormal];
}

@end
