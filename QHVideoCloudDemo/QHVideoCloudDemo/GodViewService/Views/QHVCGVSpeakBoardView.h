//
//  QHVCGVSpeakBoardView.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,QHVCGVSpeakRTCStatus) {
    QHVCGVSpeakRTCStatusReady,          // 就绪状态
    QHVCGVSpeakRTCStatusReadyToStart,   // 准备开启对讲
    QHVCGVSpeakRTCStatusStarting,       // 正在对讲
    QHVCGVSpeakRTCStatusReadyToStop,    // 准备结束对讲
};


@class QHVCGVSpeakBoardView;
@protocol QHVCGVSpeakBoardViewDelegate <NSObject>
@required
// 开始讲话回调（对讲按钮按下）
- (void)speakBoardViewWillSpeakStart;
// 结束讲话回调（对讲按钮松开）
- (void)speakBoardViewWillSpeakStop;
// 对讲面板将要关闭
- (void)speakBoardViewWillClose;
@end


@interface QHVCGVSpeakBoardView : UIView
@property(nonatomic,weak) id<QHVCGVSpeakBoardViewDelegate>delegate;
/// 对讲状态
@property(nonatomic,assign,readonly) QHVCGVSpeakRTCStatus rtcStatus;

- (void)setupUI;
- (void)showWithAnimation;
- (void)startSpeak;
- (void)stopSpeak;

#pragma mark - 状态同步
/**
 * 准备启动rtc
 */
- (void)readyStartRTC;
/**
 * 已经启动rtc
 */
- (void)didStartRTC;
/**
 * 准备结束rtc
 */
- (void)readyStopRTC;
/**
 * 已经结束rtc
 */
- (void)didStopRTC;

@end

NS_ASSUME_NONNULL_END
