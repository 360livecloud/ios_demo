//
//  QHVCGVSpeakBoardView.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVSpeakBoardView.h"
#import "QHVCGlobalConfig.h"

// 提示文本
#define kQHVCGVSpeakBoardView_LabPrompt_W               (111.0f * kQHVCScreenScaleTo6)
#define kQHVCGVSpeakBoardView_LabPrompt_H               (28.0f * kQHVCScreenScaleTo6)
#define kQHVCGVSpeakBoardView_LabPrompt_MarginBottom    (41.0f * kQHVCScreenScaleTo6)
// 对讲按钮
#define kQHVCGVSpeakBoardView_SpeakBtn_W                (81.0f)
#define kQHVCGVSpeakBoardView_SpeakBtn_H                (81.0f)
#define kQHVCGVSpeakBoardView_SpeakBtn_MarginBottom     (30.0f * kQHVCScreenScaleTo6 + kQHVCPhoneFringeHeight)
// 隐藏按钮
#define kQHVCGVSpeakBoardView_CloseBtn_W                 (24.0f * kQHVCScreenScaleTo6)
#define kQHVCGVSpeakBoardView_CloseBtn_H                 (24.0f * kQHVCScreenScaleTo6)
#define kQHVCGVSpeakBoardView_CloseBtn_MarginRight       (30.0f * kQHVCScreenScaleTo6)
#define kQHVCGVSpeakBoardView_CloseBtn_MarginBottom      (30.0f * kQHVCScreenScaleTo6 + kQHVCPhoneFringeHeight)

// 文案
#define kQHVCGVSpeakBoardViewSpeakBtnTextReay           @"点击开始对讲"
#define kQHVCGVSpeakBoardViewSpeakBtnTextReadyToStart   @"正在启动对讲..."
#define kQHVCGVSpeakBoardViewSpeakBtnTextStarting       @"正在对讲，点击结束对讲"
#define kQHVCGVSpeakBoardViewSpeakBtnTextReayToStop     @"正在结束对讲..."

@interface QHVCGVSpeakBoardView ()
/// 提示文本
@property (nonatomic,strong) UILabel *labPrompt;
/// 对讲按钮
@property (nonatomic,strong) UIButton *btnSpeak;
/// 隐藏按钮
@property (nonatomic,strong) UIButton *closeBtn;
@end

@implementation QHVCGVSpeakBoardView

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    
    // 对讲按钮
    self.btnSpeak = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSpeak setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_speak_start") forState:UIControlStateNormal];
    [_btnSpeak setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_speak_stop") forState:UIControlStateSelected];
    [_btnSpeak addTarget:self action:@selector(speakButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnSpeak];
    [_btnSpeak mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVSpeakBoardView_SpeakBtn_W));
        make.height.equalTo(@kQHVCGVSpeakBoardView_SpeakBtn_H);
        make.top.equalTo(self.mas_bottom).offset(kQHVCGVSpeakBoardView_SpeakBtn_MarginBottom);
        make.centerX.equalTo(self);
    }];
    
    // 提示文本
    self.labPrompt = [UILabel new];
    _labPrompt.textAlignment = NSTextAlignmentCenter;
    _labPrompt.textColor = [UIColor whiteColor];
    _labPrompt.backgroundColor = [UIColor blackColor];
    _labPrompt.font = kQHVCFontPingFangHKRegular(14);
    _labPrompt.text = kQHVCGVSpeakBoardViewSpeakBtnTextReay;
    _labPrompt.layer.cornerRadius = 4;
    _labPrompt.layer.masksToBounds = YES;
    [self addSubview:_labPrompt];
    [_labPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVSpeakBoardView_LabPrompt_W));
        make.height.equalTo(@(kQHVCGVSpeakBoardView_LabPrompt_H));
        make.bottom.equalTo(_btnSpeak.mas_top).offset(-kQHVCGVSpeakBoardView_LabPrompt_MarginBottom);
        make.centerX.equalTo(self);
    }];
    
    // 关闭按钮
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setBackgroundImage:kQHVCGetImageWithName(@"godview_speakboard_hide") forState:UIControlStateNormal];
    [self addSubview:_closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVSpeakBoardView_CloseBtn_W));
        make.height.equalTo(@(kQHVCGVSpeakBoardView_CloseBtn_H));
        make.trailing.equalTo(self).offset(-kQHVCGVSpeakBoardView_CloseBtn_MarginRight);
        make.bottom.equalTo(self).offset(-kQHVCGVSpeakBoardView_CloseBtn_MarginBottom);
    }];
    [_closeBtn addTarget:self action:@selector(closeSpeakBoard) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - Show && close
- (void)showWithAnimation {
    self.alpha = 0;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1;
        [_btnSpeak mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kQHVCGVSpeakBoardView_SpeakBtn_W));
            make.height.equalTo(@kQHVCGVSpeakBoardView_SpeakBtn_H);
            make.bottom.equalTo(self).offset(-kQHVCGVSpeakBoardView_SpeakBtn_MarginBottom);
            make.centerX.equalTo(self);
        }];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)closeSpeakBoard {
    if ([self.delegate respondsToSelector:@selector(speakBoardViewWillClose)]) {
        // 立即关闭
        [self.delegate speakBoardViewWillClose];
    }
    // 重置状态
    self.rtcStatus = QHVCGVSpeakRTCStatusReady;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
        [_btnSpeak mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kQHVCGVSpeakBoardView_SpeakBtn_W));
            make.height.equalTo(@kQHVCGVSpeakBoardView_SpeakBtn_H);
            make.top.equalTo(self.mas_bottom).offset(kQHVCGVSpeakBoardView_SpeakBtn_MarginBottom);
            make.centerX.equalTo(self);
        }];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Events
- (void)speakButtonClick:(UIButton *)btn {
    if (self.rtcStatus == QHVCGVSpeakRTCStatusReadyToStart
        || self.rtcStatus == QHVCGVSpeakRTCStatusReadyToStop) {
        return;
    }
    if (self.rtcStatus == QHVCGVSpeakRTCStatusReady) {
        [self startSpeak];
    }
    else if (self.rtcStatus == QHVCGVSpeakRTCStatusStarting) {
        [self stopSpeak];
    }
}

- (void)startSpeak {
    self.rtcStatus = QHVCGVSpeakRTCStatusReadyToStart;
    if ([self.delegate respondsToSelector:@selector(speakBoardViewWillSpeakStart)]) {
        [self.delegate speakBoardViewWillSpeakStart];
    }
}

- (void)stopSpeak {
    self.rtcStatus = QHVCGVSpeakRTCStatusReadyToStop;
    if ([self.delegate respondsToSelector:@selector(speakBoardViewWillSpeakStop)]) {
        [self.delegate speakBoardViewWillSpeakStop];
    }
}

- (void)stopSpeakImmediately  {
    self.rtcStatus = QHVCGVSpeakRTCStatusReady;
    if ([self.delegate respondsToSelector:@selector(speakBoardViewWillClose)]) {
        [self.delegate speakBoardViewWillClose];
    }
}

- (void)setRtcStatus:(QHVCGVSpeakRTCStatus)rtcStatus {
    if (rtcStatus == QHVCGVSpeakRTCStatusReady) {
        _btnSpeak.enabled = YES;
        _btnSpeak.selected = NO;
        _closeBtn.enabled = YES;
        _labPrompt.text = kQHVCGVSpeakBoardViewSpeakBtnTextReay;
        [_btnSpeak setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_speak_start") forState:UIControlStateNormal];
    }
    else if (rtcStatus == QHVCGVSpeakRTCStatusReadyToStart) {
        _btnSpeak.enabled = NO;
        _btnSpeak.selected = NO;
        _closeBtn.enabled = NO;
        _labPrompt.text = kQHVCGVSpeakBoardViewSpeakBtnTextReadyToStart;
    }
    else if (rtcStatus == QHVCGVSpeakRTCStatusStarting) {
        _btnSpeak.enabled = YES;
        _btnSpeak.selected = YES;
        _closeBtn.enabled = YES;
        _labPrompt.text = kQHVCGVSpeakBoardViewSpeakBtnTextStarting;
        [_btnSpeak setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_speak_stop") forState:UIControlStateNormal];
    }
    else if (rtcStatus == QHVCGVSpeakRTCStatusReadyToStop) {
        _btnSpeak.enabled = NO;
        _btnSpeak.selected = YES;
        _closeBtn.enabled = NO;
        _labPrompt.text = kQHVCGVSpeakBoardViewSpeakBtnTextReayToStop;
    }
    [self remakePromptText];
    _rtcStatus = rtcStatus;
}

- (void)remakePromptText {
    CGSize size = [self sizeOfText:_labPrompt.text];
    [_labPrompt mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(size.width));
        make.height.equalTo(@(kQHVCGVSpeakBoardView_LabPrompt_H));
        make.bottom.equalTo(_btnSpeak.mas_top).offset(-kQHVCGVSpeakBoardView_LabPrompt_MarginBottom);
        make.centerX.equalTo(self);
    }];
}

#pragma mark - 状态同步
/**
 * 准备启动rtc
 */
- (void)readyStartRTC {
    self.rtcStatus = QHVCGVSpeakRTCStatusReadyToStart;
}
/**
 * 已经启动rtc
 */
- (void)didStartRTC {
    self.rtcStatus = QHVCGVSpeakRTCStatusStarting;
}
/**
 * 准备结束rtc
 */
- (void)readyStopRTC {
    self.rtcStatus = QHVCGVSpeakRTCStatusReadyToStop;
}
/**
 * 已经结束rtc
 */
- (void)didStopRTC {
    self.rtcStatus = QHVCGVSpeakRTCStatusReady;
}

- (CGSize)sizeOfText:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(kQHVCScreenWidth - 20, kQHVCGVSpeakBoardView_LabPrompt_H) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : _labPrompt.font} context:nil].size;
    return CGSizeMake(ceilf(size.width) + 20, ceilf(size.height));
}

@end
