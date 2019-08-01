//
//  QHVCGVDeviceListEmptyView.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/13.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCGVDeviceListEmptyView.h"
#import "QHVCGlobalConfig.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@implementation QHVCGVDeviceListEmptyView

+ (instancetype)showInView:(UIView *)parentView; {
    QHVCGVDeviceListEmptyView *emptyView = [QHVCGVDeviceListEmptyView new];
    [emptyView setupUIWithParentView:parentView];
    return emptyView;
}
- (void)setupUIWithParentView:(UIView *)parentView {
    if (parentView == nil) return;
    
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = kQHVCGetImageWithName(@"godview_devicelist_empty");
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(174);
        make.centerX.equalTo(self);
        make.width.equalTo(@(150));
        make.height.equalTo(@(80));
    }];
    
    UILabel *labText = [UILabel new];
    labText.font = kQHVCFontPingFangSCMedium(12);
    labText.textColor = [QHVCToolUtils colorWithHexString:@"999999"];
    labText.textAlignment = NSTextAlignmentCenter;
    labText.text = @"点击右上角添加第一台设备吧";
    [self addSubview:labText];
    [labText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(50);
        make.trailing.equalTo(self).offset(-50);
        make.height.equalTo(@(17));
        make.top.equalTo(imageView.mas_bottom).offset(16);
    }];
    
}

@end
