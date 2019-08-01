//
//  QHVCGVAlertView.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/13.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCGVAlertView.h"
#import "QHVCGlobalConfig.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

#define kQHVCGVAlertView_Button_W                       (100 * kQHVCScreenScaleTo6)
#define kQHVCGVAlertView_Button_H                       (30 * kQHVCScreenScaleTo6)
#define kQHVCGVAlertView_Button_MarginLeft              (25 * kQHVCScreenScaleTo6)
#define kQHVCGVAlertView_Button_MarginTop               (37 * kQHVCScreenScaleTo6)
/// 白色背景
#define kQHVCGVAlertView_ContentView_MarginLeft         (45 * kQHVCScreenScaleTo6)
#define kQHVCGVAlertView_ContentView_PaddingVertical    (18 * kQHVCScreenScaleTo6)
/// message
#define kQHVCGVAlertView_LabMsg_MarginLeft              (25 * kQHVCScreenScaleTo6)
#define kQHVCGVAlertView_LabMsg_MarginTop               (16 * kQHVCScreenScaleTo6)

typedef void (^QHVCGVAlertViewHandler)(NSInteger index);

@interface QHVCGVAlertView()
@property (nonatomic,strong) UIImageView *ivIcon;
@property (nonatomic,strong) UILabel *labMsg;
@property (nonatomic,strong) UIImage *imgIcon;
@property (nonatomic,copy) NSString *msg;
@property (nonatomic,copy) QHVCGVAlertViewHandler handler;

@end

@implementation QHVCGVAlertView
{
    UIView *contentView;
}

+ (instancetype)alertWithMsg:(NSString *)msg icon:(UIImage *)icon clickHandler:(void(^)(NSInteger index))handler {
    QHVCGVAlertView *alertView = [[QHVCGVAlertView alloc] initWithMsg:msg icon:icon clickHandler:handler];
    return alertView;
}

- (instancetype)initWithMsg:(NSString *)msg icon:(UIImage *)icon clickHandler:(void(^)(NSInteger index))handler {
    if (self = [super init]) {
        self.msg = msg;
        self.imgIcon = icon;
        self.handler = handler;
    }
    return self;
}

- (void)setupUI {
    // MaskView
    UIView *maskView = [UIView new];
    [self addSubview:maskView];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 白色背景
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    contentView.layer.cornerRadius = 2;
    
    // icon
    self.ivIcon = [UIImageView new];
    _ivIcon.image = _imgIcon;
    [contentView addSubview:_ivIcon];
    [_ivIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(_imgIcon.size.width));
        make.height.equalTo(@(_imgIcon.size.height));
        make.top.equalTo(contentView).offset(kQHVCGVAlertView_ContentView_PaddingVertical);
        make.centerX.equalTo(contentView);
    }];
    
    // msg
    self.labMsg = [UILabel new];
    _labMsg.text = _msg;
    _labMsg.font = kQHVCFontPingFangHKRegular(16);
    _labMsg.textColor = [QHVCToolUtils colorWithHexString:@"4D4D4D"];
    _labMsg.textAlignment = NSTextAlignmentCenter;
    _labMsg.lineBreakMode = 10;
    [contentView addSubview:_labMsg];
    CGSize size = [self sizeOfText:_msg];
    [_labMsg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(contentView).offset(kQHVCGVAlertView_LabMsg_MarginLeft);
        make.trailing.equalTo(contentView).offset(-kQHVCGVAlertView_LabMsg_MarginLeft);
        make.height.equalTo(@(size.height));
        make.centerX.equalTo(contentView);
        make.top.equalTo(_ivIcon.mas_bottom).offset(kQHVCGVAlertView_LabMsg_MarginTop);
    }];
    
    // 确定按钮
    UIButton *btnConfirm = [self buttonWithTitle:@"确定"];
    [btnConfirm addTarget:self action:@selector(btnConfirmClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btnConfirm];
    [btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVAlertView_Button_W));
        make.height.equalTo(@(kQHVCGVAlertView_Button_H));
        make.leading.equalTo(contentView).offset(kQHVCGVAlertView_Button_MarginLeft);
        make.top.equalTo(_labMsg.mas_bottom).offset(kQHVCGVAlertView_Button_MarginTop);
    }];
    
    UIButton *btnCancel = [self buttonWithTitle:@"取消"];
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btnCancel];
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVAlertView_Button_W));
        make.height.equalTo(@(kQHVCGVAlertView_Button_H));
        make.trailing.equalTo(contentView).offset(-kQHVCGVAlertView_Button_MarginLeft);
        make.bottom.equalTo(btnConfirm);
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(kQHVCGVAlertView_ContentView_MarginLeft);
        make.trailing.equalTo(self).offset(-kQHVCGVAlertView_ContentView_MarginLeft);
        make.center.equalTo(self);
        make.top.equalTo(_ivIcon).offset(-kQHVCGVAlertView_ContentView_PaddingVertical);
        make.bottom.equalTo(btnConfirm).offset(kQHVCGVAlertView_ContentView_PaddingVertical);
    }];
    
}

- (UIButton *)buttonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundImage:kQHVCGetImageWithName(@"godview_alert_btn_nor") forState:UIControlStateNormal];
    [btn setBackgroundImage:kQHVCGetImageWithName(@"godview_alert_btn_sel") forState:UIControlStateHighlighted];
    [btn setTitleColor:[QHVCToolUtils colorWithHexString:@"999999"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    btn.titleLabel.font = kQHVCFontPingFangSCMedium(13);
    return btn;
}

- (CGSize)sizeOfText:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(kQHVCScreenWidth - kQHVCGVAlertView_ContentView_MarginLeft * 2 - kQHVCGVAlertView_LabMsg_MarginLeft * 2, 200) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : _labMsg.font} context:nil].size;
    return CGSizeMake(ceilf(size.width) + 20, ceilf(size.height));
}

- (void)showInView:(UIView *)parentView {
    for (UIView *subView in parentView.subviews) {
        if ([subView isKindOfClass:[self class]]) {
            [subView removeFromSuperview];
        }
    }
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    [self setupUI];
    
    self.alpha = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        }];
    });
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)btnConfirmClick {
    if (self.handler) {
        self.handler(0);
    }
    [self hide];
}

- (void)btnCancelClick {
    if (self.handler) {
        self.handler(1);
    }
    [self hide];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
