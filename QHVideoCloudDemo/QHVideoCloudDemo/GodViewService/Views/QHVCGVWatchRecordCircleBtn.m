//
//  QHVCGVWatchRecordCircleBtn.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVWatchRecordCircleBtn.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGlobalConfig.h"

#define kQHVCGVWatchRecordCircleBtn_LabText_H               (16.5 * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordCircleBtn_Icon_MarginBottom       (5.5 * kQHVCScreenScaleTo6)

@implementation QHVCGVWatchRecordCircleBtn
{
    /// 功能文本
    UILabel *labFunc;
    /// 圈内文本
    UILabel *labCircle;
}
/**
 * @param circleText 圆圈内的文字
 * @param funcText   描述功能的文字
 */
- (void)setupWithCircleText:(NSString *)circleText
               functionText:(NSString *)funcText {
    // 文本说明
    labFunc = [UILabel new];
    labFunc.text = funcText;
    labFunc.font = kQHVCFontPingFangHKRegular(12);
    labFunc.textColor = [QHVCToolUtils colorWithHexString:@"666666"];
    labFunc.textAlignment = NSTextAlignmentCenter;
    [self addSubview:labFunc];
    [labFunc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(self);
        make.height.equalTo(@(kQHVCGVWatchRecordCircleBtn_LabText_H));
    }];
    
    // icon
    UIImage *iconImage = kQHVCGetImageWithName(@"godview_watchrecord_circle");
    UIImageView *ivIcon = [UIImageView new];
    ivIcon.image = iconImage;
    [self addSubview:ivIcon];
    CGSize sizeIcon = iconImage.size;
    [ivIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(sizeIcon.width));
        make.height.equalTo(@(sizeIcon.height));
        make.centerX.equalTo(self);
        make.bottom.equalTo(labFunc.mas_top).offset(-kQHVCGVWatchRecordCircleBtn_Icon_MarginBottom);
    }];
    
    // 圈内文本
    labCircle = [UILabel new];
    labCircle.text = circleText;
    labCircle.font = kQHVCFontPingFangHKRegular(12);
    labCircle.textColor = [QHVCToolUtils colorWithHexString:@"666666"];
    labCircle.textAlignment = NSTextAlignmentCenter;
    [ivIcon addSubview:labCircle];
    [labCircle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(ivIcon);
    }];

}

- (void)updateCircleText:(NSString *)circleText {
    labCircle.text = circleText;
}

- (void)updateFunctionText:(NSString *)funcText {
    labFunc.text = funcText;
}
- (void)updateCircleText:(NSString *)circleText
            functionText:(NSString *)funcText {
    labFunc.text = funcText;
    labCircle.text = circleText;
}

@end
