//
//  QHVCEditPlayerMainViewController.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditPlayerViewController.h"

typedef NS_ENUM(NSInteger, QHVCEditPlayerStatus) {
    QHVCEditPlayerStatusNone = 1,
    QHVCEditPlayerStatusRefresh,
    QHVCEditPlayerStatusReset
};

typedef NS_ENUM(NSInteger, QHVCEditPlayStatus) {
    QHVCEditPlayStatusStop = 0,
    QHVCEditPlayStatusPlay = 1,
};

typedef void(^ConfirmAction)(QHVCEditPlayerStatus status);

@interface QHVCEditPlayerMainViewController : QHVCEditPlayerViewController
{
    __weak IBOutlet UILabel *_currentPoint;
    __weak IBOutlet UILabel *_durationLabel;
    __weak IBOutlet UISlider *_seek;
    __weak IBOutlet UIButton *_playBtn;
    __weak IBOutlet UIView *_preview;
    __weak IBOutlet UIView *_sliderContainerView;
    __weak IBOutlet NSLayoutConstraint *_sliderViewBottom;
    NSTimer *_timer;
}
@property(nonatomic, assign) NSTimeInterval durationMs;
@property(nonatomic, copy) ConfirmAction confirmCompletion;

- (void)stopPlayerTimer;
- (void)releasePlayerVC;
- (void)freshDurationView;
- (void)setPlayerStatus:(QHVCEditPlayStatus)status;
- (void)playBtnCallback:(QHVCEditPlayStatus)status;

@end
