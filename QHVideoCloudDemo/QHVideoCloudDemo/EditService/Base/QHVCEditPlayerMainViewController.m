//
//  QHVCEditPlayerMainViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditPlayerMainViewController.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditPlayerMainViewController ()
{
    QHVCEditPlayStatus _currentPlayerStatus;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewRightConstraint;

@end

@implementation QHVCEditPlayerMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPlayer:_preview];
    [self fetchPlayerDuration];
    _currentPoint.text = @"00:00";
    _seek.minimumValue = 0.0;
    _seek.value = 0.0;
    _currentPlayerStatus = QHVCEditPlayStatusStop;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat maxHeight = [[UIScreen mainScreen] bounds].size.height - 100 - 60 - 10;
    CGFloat scale = [[QHVCEditPrefs sharedPrefs] outputSize].height/[[QHVCEditPrefs sharedPrefs] outputSize].width;
    if (CGRectGetHeight(_preview.frame) > maxHeight)
    {
        CGFloat offsetX = ([[UIScreen mainScreen] bounds].size.width - maxHeight / scale) / 2.0;
        [self.previewHeightConstraint setConstant:maxHeight];
        [self.previewLeftConstraint setConstant:offsetX];
        [self.previewRightConstraint setConstant:offsetX];
    }
    else
    {
        [self.previewHeightConstraint setConstant:CGRectGetWidth(_preview.frame)*scale];
    }
    
    [self resetPlayer:[self playerTime]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_player.isPlayerPlaying)
    {
        [self playAction:_playBtn];
    }
}

- (void)fetchPlayerDuration
{
    if (_durationMs > 0) {
        [self freshDurationView];
        return;
    }
    [self freshPlayerDuration];
}

- (IBAction)playAction:(UIButton *)sender
{
    [self playBtnCallback:sender.tag == QHVCEditPlayStatusPlay?QHVCEditPlayStatusStop:QHVCEditPlayStatusPlay];
}

- (void)playBtnCallback:(QHVCEditPlayStatus)status
{
    [self setPlayerStatus:status];
}

- (IBAction)seek:(UISlider *)sender
{
    _currentPoint.text = [QHVCEditPrefs timeFormatMs:sender.value];
    [self seekTo:sender.value];
}

- (void)startPlayerTimer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progressTimer) userInfo:nil repeats:YES];
    }
}

- (void)progressTimer
{
    NSTimeInterval timestamp = [_player getCurrentTimestamp];
    _currentPoint.text = [QHVCEditPrefs timeFormatMs:timestamp];
    _seek.value = timestamp;
}

- (void)playerComplete
{
    [self playAction:_playBtn];
    _seek.value = 0.0;
    [self seek:_seek];
}

#pragma mark Public
- (void)stopPlayerTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)releasePlayerVC
{
    [self stopPlayerTimer];
    [self freePlayer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setPlayerStatus:(QHVCEditPlayStatus)status
{
    if (_currentPlayerStatus == status) {
        return;
    }
    _currentPlayerStatus = status;
    if (status == QHVCEditPlayStatusPlay) {
        [self play];
        _playBtn.tag = QHVCEditPlayStatusPlay;
        [_playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
        [self startPlayerTimer];
    }
    else if (status == QHVCEditPlayStatusStop)
    {
        [self stop];
        _playBtn.tag = QHVCEditPlayStatusStop;
        [_playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
        [self stopPlayerTimer];
    }
}

- (void)freshPlayerDuration
{
    __weak typeof(self) weakSelf = self;
    [[QHVCEditCommandManager manager] fetchSegmentInfo:^(NSArray<QHVCEditSegmentInfo *> *segments, NSInteger totalDurationMs) {
        [weakSelf updateDuration:totalDurationMs];
        [weakSelf freshDurationView];
    }];
}

- (void)updateDuration:(NSInteger)totalDurationMs
{
    _durationMs = totalDurationMs;
}

- (void)freshDurationView
{
    _durationLabel.text = [QHVCEditPrefs timeFormatMs:_durationMs];
    _seek.maximumValue = _durationMs;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

