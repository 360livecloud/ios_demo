//
//  QHVCLocalServerPlayerView.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/18.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerPlayerView.h"
#import "QHVCHUDManager.h"
#import "QHVCSlider.h"
#import <QHVCPlayerKit/QHVCPlayerKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <QHVCLocalServerKit/QHVCLocalServerKit.h>

@interface QHVCLocalServerPlayerView ()<QHVCSliderDelegate>
{
    CGSize _size;
    
    UIImageView *defaultImageView;
    UIView *dividingLine;
    
    UIView *topView;
    UIButton *backButton;
    UILabel *title;
    UIButton *playCount;
    
    UIView *bottomView;
    UIButton *frontButton;
    UILabel *currentTimeLabel;
    QHVCSlider *playerSlider;
    UILabel *totalTimeLabel;
    UIButton *fullScreenButton;
    
    UIButton *playPauseButton;
    UILabel *totalTimeSingleLabel;
    UIButton *downloadSingleButton;
    QHVCSlider *slider;
    UIButton *downloadButton;
    
    CAGradientLayer *topGradientLayer;
    CAGradientLayer *bottomGradientLayer;
    
    BOOL isReady;
    BOOL isSliderGliding;
    NSTimer *_hideTopBottomTimer;
    NSTimer *_downloadProgressTimer;
    
    QHVCHUDManager *hudManager;
    NSDictionary *currentItem;
    
    long long fileTotalSize;
}

@end

@implementation QHVCLocalServerPlayerView

- (instancetype)initWithSize:(CGSize)size
{
    if (self == [super init])
    {
        self.backgroundColor = [UIColor blackColor];
        _size = size;
        [self initSubViewsWithSize:size];
        [self addTapGesture];
    }
    
    return self;
}

- (void)setItemDetail:(NSDictionary *)item
{
    currentItem = item;
    [title setText:[item valueForKey:@"title"]];
    [defaultImageView sd_setImageWithURL:[NSURL URLWithString:[item valueForKey:@"imageUrl"]]];
    [playCount setTitle:[item valueForKey:@"playCount"] forState:UIControlStateNormal];
    [totalTimeSingleLabel setText:[item valueForKey:@"totalTime"]];
    [totalTimeLabel setText:[item valueForKey:@"totalTime"]];
}

- (void)removeDefaultImage
{
    if (_player)
    {
        defaultImageView.hidden = YES;
    }
}

- (void)currentStyle
{
    fileTotalSize = 0;
    defaultImageView.hidden = YES;
    
    isReady = YES;
    topView.hidden = NO;
    bottomView.hidden = NO;
    slider.hidden = YES;
    playCount.hidden = YES;
    totalTimeSingleLabel.hidden = YES;
    downloadSingleButton.hidden = YES;
    
    backButton.hidden = !_isFullScreen;
    frontButton.hidden = !_isFullScreen;
    fullScreenButton.hidden = _isFullScreen;
    playPauseButton.hidden = _isFullScreen;
    [hudManager hideHud];
    
    if ([_player playerStatus] == QHVCPlayerStatusPlaying)
    {
        [self startHideTopBottomTimer];
        [self startDownloadProgressTimer];
    }
    
    if ([_player playerStatus] == QHVCPlayerStatusPlaying)
    {
        playPauseButton.selected = YES;
        frontButton.selected = YES;
    }
    else
    {
        playPauseButton.selected = NO;
        frontButton.selected = NO;
    }
    [currentTimeLabel setText:[self formatedTime:[_player getCurrentPosition]]];
    [totalTimeLabel setText:[self formatedTime:[_player getDuration]]];
    
    [self layoutDividingLine];
}

- (void)unCurrentStyle
{
    fileTotalSize = 0;
    defaultImageView.hidden = NO;
    
    isReady = NO;
    bottomView.hidden = YES;
    topView.hidden = NO;
    slider.hidden = YES;
    
    playCount.hidden = NO;
    totalTimeSingleLabel.hidden = NO;
    downloadSingleButton.hidden = NO;
    playPauseButton.selected = NO;
    frontButton.selected = NO;
    
    backButton.hidden = !_isFullScreen;
    frontButton.hidden = !_isFullScreen;
    fullScreenButton.hidden = _isFullScreen;
    playPauseButton.hidden = _isFullScreen;
    [hudManager hideHud];
    
    [_lspGLView removeFromSuperview];
    _lspGLView = nil;
    [self killHideTimer];
    [self killProgressTimer];
    
    [self layoutDividingLine];
}

- (void)play
{
    [self playPauseButtonAction:playPauseButton];
}

- (void)setPlayStatus:(NSString *)playing
{
    if ([playing isEqualToString:@"play"])
    {
        playPauseButton.selected = YES;
        frontButton.selected = YES;
    }
    else if ([playing isEqualToString:@"pause"])
    {
        playPauseButton.selected = NO;
        frontButton.selected = NO;
    }
}

- (void)stop
{
    
}

- (void)finish
{
    [_player seekTo:0];
    [_player pause];
    [playerSlider setValue:0];
    [currentTimeLabel setText:@"00:00"];
    playPauseButton.selected = NO;
    if (topView.hidden)
    {
        [self hideTopBottomView:NO];
    }
    [self killHideTimer];
    [self killProgressTimer];
}

- (void)beginBuffing
{
    if (_player)
    {
        [totalTimeLabel setText:[self formatedTime:[_player getDuration]]];
        [hudManager showLoadingProgressOnView:self message:@"loading..."];
    }
}

- (void)bufferingUpdate :(int)progress
{

}

- (void)bufferingComplete
{
    [hudManager hideHud];
}

- (void)buffingSeekComplete
{
    
}

- (void)updateplayProgress:(CGFloat)progress
{
    if (!isSliderGliding)
    {
        [playerSlider setValue:progress];
        [slider setValue:progress];
        [currentTimeLabel setText:[self formatedTime:[_player getCurrentPosition]]];
    }
}

- (void)showNoNetwork
{
    [hudManager hideHud];
    [hudManager showTextOnlyAlertViewOnView:self message:@"没有网络" hideFlag:YES];
}

- (NSString *)formatedTime:(NSTimeInterval)timeDuration
{
    NSString *formatedString = nil;
    if (isnan(timeDuration))
        return nil;
    if (timeDuration <= 0)
        return @"00:00";
    
    NSInteger minute = timeDuration / 60;
    NSString *minStr = [NSString stringWithFormat:@"%ld", (long)minute];
    if (minute < 10)
    {
        minStr = [NSString stringWithFormat:@"0%ld", (long)minute];
    }
    int second = (int)timeDuration % 60;
    formatedString = [NSString stringWithFormat:@"%@:%02d",minStr,second];
    
    return formatedString;
}

#pragma mark SliderDelegate
- (void)beiginSliderScrubbing
{
    isSliderGliding = YES;
    [self killHideTimer];
}

- (void)endSliderScrubbing
{
    CGFloat value = playerSlider.value;
    if (value < 0)
    {
        value = 0;
    }
    else if (value > 1)
    {
        value = 1;
    }
    BOOL seekSucceed = [_player seekTo:value * [_player getDuration]];
    NSLog(@"seekSucceed = %i", seekSucceed);
    isSliderGliding = NO;
    [self startHideTopBottomTimer];
}

- (void)sliderScrubbing
{
    CGFloat value = playerSlider.value;
    if (value < 0)
    {
        value = 0;
    }
    else if (value > 1)
    {
        value = 1;
    }
    [currentTimeLabel setText:[self formatedTime:value * [_player getDuration]]];
}

#pragma mark PlayerViewControl
- (void)startDownloadProgressTimer
{
    [self killProgressTimer];
    _downloadProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                              target:self
                                                            selector:@selector(loadProgressTimerFire:)
                                                            userInfo:nil
                                                             repeats:YES];
}

- (void)loadProgressTimerFire:(id)userinfo
{
    if (fileTotalSize == 0)
    {
        [[QHVCLocalServerKit sharedInstance] getFileCachedSize:[currentItem valueForKey:@"rid"] url:[currentItem valueForKey:@"playUrl"] callback:^(unsigned long long cachedSize, unsigned long long totalSize) {
            fileTotalSize = totalSize;
        }];
    }
    double download = [_player getDownloadProgress];
    NSString *rid = [currentItem valueForKey:@"rid"];
    NSString *url = [currentItem valueForKey:@"playUrl"];
    long long pro = [[QHVCLocalServerKit sharedInstance] getFileAvailedSize:rid url:url  offset:[_player getCurrentPosition] * fileTotalSize/[_player getDuration]];
    if (pro != 0)
    {
        download = (double)(pro * [_player getDuration]/fileTotalSize) ;
    }
    double current = [_player getCurrentPosition];
    double total = [_player getDuration];
    if (download < 0 || total <= 0)
        return;
    
    double value = download + current;
    if (value > total)
    {
        value = total;
    }
    playerSlider.trackValue = value/total;
    slider.trackValue = value/total;
}

- (void)startHideTopBottomTimer
{
    [self killHideTimer];
    _hideTopBottomTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                           target:self
                                                         selector:@selector(hideTimerFire:)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)hideTimerFire:(id)userinfo
{
    if (topView.hidden == NO)
    {
        [self hideTopBottomView:YES];
    }
}

- (void)killHideTimer
{
    if (_hideTopBottomTimer != nil)
    {
        [_hideTopBottomTimer invalidate];
        _hideTopBottomTimer = nil;
    }
}

- (void)killProgressTimer
{
    if (_downloadProgressTimer != nil)
    {
        [_downloadProgressTimer invalidate];
        _downloadProgressTimer = nil;
    }
}

- (void)hideTopBottomView:(BOOL)hidden
{
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [topView.layer addAnimation:animation forKey:nil];
    [bottomView.layer addAnimation:animation forKey:nil];
    
    topView.hidden = hidden;
    bottomView.hidden = hidden;
    if (_isFullScreen)
    {
        playPauseButton.hidden = YES;
    }
    else
    {
        playPauseButton.hidden = hidden;
    }
    slider.hidden = !hidden;
}

- (void)addTapGesture
{
    UITapGestureRecognizer *playerTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureHandle:)];
    [self addGestureRecognizer:playerTapGesture];
    
    UISwipeGestureRecognizer *playerUpGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(behindAction:)];
    [playerUpGesture setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self addGestureRecognizer:playerUpGesture];
    
    UISwipeGestureRecognizer *playerDownGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(frontAction:)];
    [playerDownGesture setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self addGestureRecognizer:playerDownGesture];
}

- (void)tapGestureHandle:(UITapGestureRecognizer *)tap
{
    if (!isReady)
    {
        [self playPauseButtonAction:playPauseButton];
        return;
    }
    if (topView.hidden)
    {
        [self hideTopBottomView:NO];
        if ([_player playerStatus] != QHVCPlayerStatusPaused)
        {
            [self startHideTopBottomTimer];
        }
        else
        {
            [self killHideTimer];
        }
    }
    else
    {
        [self hideTopBottomView:YES];
        [self killHideTimer];
    }
}

- (void)backButtonAction:(UIButton *)button
{
    backButton.hidden = YES;
    playCount.hidden = NO;
    frontButton.hidden = YES;
    fullScreenButton.hidden = NO;
    playPauseButton.hidden = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(back)])
    {
        [_delegate back];
    }
}

- (void)playPauseButtonAction:(UIButton *)button
{
    isReady = YES;
    
    if (button.selected == YES)
    {
        [self startHideTopBottomTimer];
        [self startDownloadProgressTimer];
    }
    else
    {
        [self killHideTimer];
        [self killProgressTimer];
    }
    
    topView.hidden = NO;
    bottomView.hidden = NO;
    
    slider.hidden = YES;
    playCount.hidden = YES;
    totalTimeSingleLabel.hidden = YES;
    downloadSingleButton.hidden = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(playPause:)])
    {
        [_delegate playPause:self];
    }
}

- (void)fullScreenButtonAction:(UIButton *)button
{
    backButton.hidden = NO;
    playCount.hidden = YES;
    frontButton.hidden = NO;
    fullScreenButton.hidden = YES;
    playPauseButton.hidden = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(fullScreen)])
    {
        [_delegate fullScreen];
    }
}

- (void)downloadButtonAction:(UIButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(download:)])
    {
        [_delegate download:_index];
    }
}

- (void)frontAction:(UIButton *)button
{
    if (!_isFullScreen)
        return;
    
    if (_delegate && [_delegate respondsToSelector:@selector(next)])
    {
        [_delegate previous];
    }
}

- (void)behindAction:(UIButton *)button
{
    if (!_isFullScreen)
        return;
    
    if (_delegate && [_delegate respondsToSelector:@selector(previous)])
    {
        [_delegate next];
    }
}

- (void)layoutSubviews
{
    bottomGradientLayer.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 60);
    topGradientLayer.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 60);
    
    if (fileTotalSize == 0)
    {
        [[QHVCLocalServerKit sharedInstance] getFileCachedSize:[currentItem valueForKey:@"rid"] url:[currentItem valueForKey:@"playUrl"] callback:^(unsigned long long cachedSize, unsigned long long totalSize) {
            fileTotalSize = totalSize;
        }];
    }
    double download = [_player getDownloadProgress];
    if (fileTotalSize != 0)
    {
        NSString *rid = [currentItem valueForKey:@"rid"];
        NSString *url = [currentItem valueForKey:@"playUrl"];
        long long offset = 0;
        if (_player)
        {
            offset = [_player getCurrentPosition] * fileTotalSize/[_player getDuration];
        }
        long long pro = [[QHVCLocalServerKit sharedInstance] getFileAvailedSize:rid url:url  offset:offset];
        if (pro != 0)
        {
            download = (double)(pro * [_player getDuration]/fileTotalSize) ;
        }
    }
    
    double current = [_player getCurrentPosition];
    double total = [_player getDuration];
    if (download < 0)
    {
        download = 0;
    }
    if (total <= 0)
    {
        total = 1;
    }
    
    double currentValue = download + current;
    if (currentValue > total)
    {
        currentValue = total;
    }
    
    CGFloat trackValue = currentValue/total;
    CGFloat value = current/total;
    
    UIView *view = playerSlider.superview;
    [playerSlider removeFromSuperview];
    playerSlider = nil;
    
    
    UIView *sliderSuper = slider.superview;
    [slider removeFromSuperview];
    slider = nil;
    
    if (_isFullScreen == YES)
    {
        playerSlider = [[QHVCSlider alloc] initWithFrame:CGRectMake(60, 0, SCREEN_SIZE.width - 60 - 60, 60)];
        playerSlider.trackImage = [UIImage imageNamed:@"progressBar"];
        playerSlider.delegate = self;
        [view addSubview:playerSlider];
        [playerSlider setTrackValue:trackValue];
        [playerSlider setValue:value];
        
        slider = [[QHVCSlider alloc] initWithFrame:CGRectMake(-20, SCREEN_SIZE.height - 3, SCREEN_SIZE.width + 40, 5) trackImageLength:40 sliderHeight:2];
        slider.hidden = YES;
        [sliderSuper addSubview:slider];
        [slider setTrackValue:trackValue];
        [slider setValue:value];
        
        [title mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@40);
            make.height.equalTo(@20);
            make.width.equalTo(@400);
            make.top.equalTo(@30);
        }];
        
        [currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(frontButton.mas_right);
            make.top.bottom.equalTo(bottomView);
        }];
        
        [totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(fullScreenButton.mas_left);
            make.top.bottom.equalTo(bottomView);
        }];
        
        [downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(bottomView);
            make.width.equalTo(@40);
        }];
    }
    else
    {
        playerSlider = [[QHVCSlider alloc] initWithFrame:CGRectMake(40, 0, SCREEN_SIZE.width - 40 - 40 - 40 - 15, 60)];
        playerSlider.trackImage = [UIImage imageNamed:@"progressBar"];
        playerSlider.delegate = self;
        [view addSubview:playerSlider];
        [playerSlider setTrackValue:trackValue];
        [playerSlider setValue:value];
        
        slider = [[QHVCSlider alloc] initWithFrame:CGRectMake(-20, _size.height - 3, _size.width + 40, 5) trackImageLength:40 sliderHeight:2];
        slider.hidden = YES;
        [sliderSuper addSubview:slider];
        [slider setTrackValue:trackValue];
        [slider setValue:value];
        
        [title mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.height.equalTo(@20);
            make.width.equalTo(@260);
            make.top.equalTo(@10);
        }];
        
        [currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16);
            make.top.bottom.equalTo(bottomView);
        }];
        
        [totalTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(downloadButton.mas_left);
            make.top.bottom.equalTo(bottomView);
        }];
        
        [downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(fullScreenButton.mas_left).offset(10);
            make.top.bottom.equalTo(bottomView);
            make.width.equalTo(@40);
        }];
    }

}

- (void)layoutDividingLine
{
    if (_isFullScreen == YES || _index == 0)
    {
        dividingLine.hidden = YES;
        [defaultImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@60);
        }];
    }
    else
    {
        dividingLine.hidden = NO;
        [defaultImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@10);
            make.left.bottom.right.equalTo(self);
        }];
        [topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(@10);
            make.height.equalTo(@60);
        }];
    }
}

- (void)initSubViewsWithSize:(CGSize)size
{
    defaultImageView = [UIImageView new];
    defaultImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:defaultImageView];
    [defaultImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.equalTo(@10);
    }];
    
    dividingLine = [UIView new];
    dividingLine.backgroundColor = QHVC_COLOR_VIEW_WHITE;
    [self addSubview:dividingLine];
    [dividingLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.equalTo(@10);
    }];
    
    hudManager = [QHVCHUDManager new];
    
    topView = [UIView new];
    [self addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(@10);
        make.height.equalTo(@60);
    }];
    topGradientLayer = [CAGradientLayer layer];
    topGradientLayer.opacity = 0.8;
    topGradientLayer.frame = CGRectMake(0, 0, size.width, 60);
    [topView.layer addSublayer:topGradientLayer];
    topGradientLayer.startPoint = CGPointMake(0, 0);
    topGradientLayer.endPoint = CGPointMake(0, 1);
    topGradientLayer.colors = @[(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor clearColor].CGColor];
    topGradientLayer.locations = @[@(0.0f), @(1.0f)];
    
    backButton = [UIButton new];
    backButton.hidden = YES;
    [backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@30);
        make.left.equalTo(topView);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    playPauseButton = [UIButton new];
    playPauseButton = [UIButton new];
    [playPauseButton setImage:[UIImage imageNamed:@"localServerPlay"] forState:UIControlStateNormal];
    [playPauseButton setImage:[UIImage imageNamed:@"localServerPause"] forState:UIControlStateSelected];
    [playPauseButton addTarget:self action:@selector(playPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playPauseButton];
    [playPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self);
        make.width.height.equalTo(@40);
    }];
    
    bottomView = [UIView new];
    bottomView.hidden = YES;
    [self addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@60);
    }];
    bottomGradientLayer = [CAGradientLayer layer];
    bottomGradientLayer.opacity = 0.8;
    bottomGradientLayer.frame = CGRectMake(0, 0, size.width, 60);
    [bottomView.layer addSublayer:bottomGradientLayer];
    bottomGradientLayer.startPoint = CGPointMake(0, 0);
    bottomGradientLayer.endPoint = CGPointMake(0, 1);
    bottomGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor blackColor].CGColor];
    bottomGradientLayer.locations = @[@(0.0f), @(1.0f)];
    
    frontButton = [UIButton new];
    [frontButton setImage:[UIImage imageNamed:@"fullScreenPlay"] forState:UIControlStateNormal];
    [frontButton setImage:[UIImage imageNamed:@"fullScreenPause"] forState:UIControlStateSelected];
    frontButton.hidden = YES;
    [frontButton addTarget:self action:@selector(playPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:frontButton];
    [frontButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(bottomView);
        make.width.equalTo(@40);
    }];
    
    currentTimeLabel = [UILabel new];
    currentTimeLabel.textColor = [UIColor whiteColor];
    currentTimeLabel.font = [UIFont systemFontOfSize:12];
    currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    currentTimeLabel.text = @"00:00";
    [bottomView addSubview:currentTimeLabel];
    [currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.top.bottom.equalTo(bottomView);
    }];
    
    fullScreenButton = [UIButton new];
    [fullScreenButton setImage:[UIImage imageNamed:@"localServerFullScreen"] forState:UIControlStateNormal];
    [fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:fullScreenButton];
    [fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(bottomView);
        make.width.equalTo(@40);
    }];
    
    downloadButton = [UIButton new];
    [downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:downloadButton];
    [downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(bottomView);
        make.width.equalTo(@40);
    }];
    
    totalTimeLabel = [UILabel new];
    totalTimeLabel.textColor = [UIColor whiteColor];
    totalTimeLabel.font = [UIFont systemFontOfSize:12];
    totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:totalTimeLabel];
    [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(fullScreenButton.mas_left);
        make.top.bottom.equalTo(bottomView);
    }];
    
    playCount = [UIButton new];
    [playCount setImage:[UIImage imageNamed:@"playCount"] forState:UIControlStateNormal];
    [playCount setTitle:@"2.3万" forState:UIControlStateNormal];
    [playCount.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [playCount setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    playCount.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:playCount];
    [playCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-20);
        make.height.equalTo(@20);
        make.width.equalTo(@60);
    }];
    
    totalTimeSingleLabel = [UILabel new];
    totalTimeSingleLabel.layer.cornerRadius = 12.0;
    totalTimeSingleLabel.font = [UIFont systemFontOfSize:12.0];
    [totalTimeSingleLabel adjustsFontSizeToFitWidth];
    totalTimeSingleLabel.textAlignment = NSTextAlignmentCenter;
    totalTimeSingleLabel.clipsToBounds = YES;
    totalTimeSingleLabel.backgroundColor = [UIColor clearColor];
    totalTimeSingleLabel.textColor = [UIColor whiteColor];
    [self addSubview:totalTimeSingleLabel];
    [totalTimeSingleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-20);
        make.right.equalTo(self).offset(-35);
        make.height.equalTo(@20);
        make.width.equalTo(@40);
    }];
    
    downloadSingleButton = [UIButton new];
    [downloadSingleButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [downloadSingleButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:downloadSingleButton];
    [downloadSingleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-20);
        make.right.equalTo(self);
        make.height.equalTo(@20);
        make.width.equalTo(@40);
    }];
    
    playerSlider = [[QHVCSlider alloc] initWithFrame:CGRectMake(40, 0, SCREEN_SIZE.width - 80 - 20, 60)];
    playerSlider.trackImage = [UIImage imageNamed:@"progressBar"];
    playerSlider.delegate = self;
    [bottomView addSubview:playerSlider];
    
    slider = [[QHVCSlider alloc] initWithFrame:CGRectMake(-20, size.height - 3, size.width + 40, 4) trackImageLength:40 sliderHeight:2];
    slider.hidden = YES;
    [slider setTrackValue:0.8];
    [slider setValue:0.5];
    [self addSubview:slider];
    
    title = [UILabel new];
    title.text = @"杨幂霸气出场加入跑男一员";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:18];
    title.textAlignment = NSTextAlignmentLeft;
    [topView addSubview:title];
    [title mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.height.equalTo(@20);
        make.width.equalTo(@260);
        make.top.equalTo(@10);
    }];
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
}

- (void)dealloc
{
    [hudManager hideHud];
}

@end
