//
//  QHVCEditMainEditVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/27.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditMainEditVC.h"
#import "QHVCEditMainNavView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditFunctionBaseView.h"
#import "QHVCEditProducerVC.h"
#import "QHVCEditTailorMainView.h"
#import "QHVCEditMediaEditor.h"
#import "UIViewAdditions.h"
#import "QHVCEditSelectPhotoAlbumVC.h"
#import "QHVCEditMainContentView.h"
#import "QHVCEditOverlayFunctionsView.h"
#import <QHVCEditKit/QHVCEditKit.h>

@interface QHVCEditMainEditVC ()<UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *curTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet QHVCEditMainContentView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewWidthConstraint;

@property (nonatomic, strong) NSArray<NSArray*>* functions;
@property (nonatomic, strong) QHVCEditMainNavView* navView;
@property (nonatomic, strong) NSTimer* playerTimer;
@property (nonatomic, assign) BOOL isPlayComplete;

@end

@implementation QHVCEditMainEditVC

#pragma mark - Life Circle Methods

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"编辑"];
    [self setNextBtnTitle:@"合成"];
    [self.topConstraint setConstant:[self topBarHeight]];
    _functions = [[QHVCEditPrefs sharedPrefs] editFunctions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupt:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)audioSessionInterrupt:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    AVAudioSessionInterruptionType type = [[info objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan)
    {
        [self pauseAction];
    }
}

- (void)prepareSubviews
{
    [super prepareSubviews];
    
    //创建导航条
    [self createNavView];
    
    //初始化播放器及相关参数
    [self createPlayerAndParams];
    
    //初始化contentView 及相关参数
    [self createContentViewAndParams];
}

- (void)nextAction:(UIButton *)btn
{
    [self pauseAction];
    QHVCEditProducerVC* vc = [[QHVCEditProducerVC alloc] initWithNibName:@"QHVCEditProducerVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)backAction:(UIButton *)btn
{
    [super backAction:btn];
    [self.navView removeFromSuperview];
    self.navView = nil;
    
    [self.contentView clear];
    [self.contentView removeFromSuperview];
    
    [self stop];
    [self freePlayer];
}

#pragma mark - Player Methods

- (void)createPlayerAndParams
{
    [self createPlayerWithPreview:self.preview];
    [self.curTimeLabel setText:@"00:00"];
    [self updatePlayerDuration];
    
    //播放器preview高度适配
    CGFloat maxHeight = kScreenHeight - 180 - [self topBarHeight];
    CGFloat maxWidth = kScreenWidth;
    CGFloat height = 0;
    CGFloat width = 0;
    CGFloat outputWidth = [[QHVCEditMediaEditorConfig sharedInstance] outputSize].width;
    CGFloat outputHeight = [[QHVCEditMediaEditorConfig sharedInstance] outputSize].height;
    if (outputWidth > outputHeight)
    {
        width = maxWidth;
        height = width * outputHeight / outputWidth;
    }
    else
    {
        height = maxHeight;
        width = height * outputWidth / outputHeight;
    }
    [self.previewWidthConstraint setConstant:width];
    [self.previewHeightConstraint setConstant:height];
    [self.contentViewWidthConstraint setConstant:width];
    [self.contentViewHeightConstraint setConstant:height];
}

- (IBAction)clickPlayBtn:(UIButton *)sender
{
    if (self.isPlayComplete)
    {
        //播放完成
        [self playFromZeroAction];
    }
    else
    {
        self.isPlayComplete = NO;
        if ([self isPlaying])
        {
            //暂停
            [self pauseAction];
        }
        else
        {
            //播放
            [self playAction];
        }
    }
}

- (void)playFromZeroAction
{
    WEAK_SELF
    [self seekTo:0 complete:^{
        STRONG_SELF
        self.isPlayComplete = NO;
        [self play];
        [self.playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
        [self startPlayerTimer];
    }];
}

- (void)playAction
{
    [self play];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
    [self startPlayerTimer];
}

- (void)pauseAction
{
    [self stop];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
    [self stopPlayerTimer];
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    if ([self isPlaying])
    {
        [self clickPlayBtn:nil];
    }
    
    [self seekTo:sender.value forceRequest:NO];
    [self.curTimeLabel setText:[QHVCEditPrefs timeFormatMs:sender.value]];
}

- (IBAction)sliderTouchUpInside:(UISlider *)sender
{
    [self seekTo:sender.value forceRequest:YES];
}

- (void)playerComplete
{
    self.isPlayComplete = YES;
    [self stopPlayerTimer];
    [self.slider setValue:[self playerDuration]];
    [self.curTimeLabel setText:[QHVCEditPrefs timeFormatMs:[self playerDuration]]];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
}

- (void)startPlayerTimer
{
    if (!self.playerTimer)
    {
        self.playerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updatePlayerTime) userInfo:nil repeats:YES];
    }
}

- (void)stopPlayerTimer
{
    if (self.playerTimer)
    {
        [self.playerTimer invalidate];
        self.playerTimer = nil;
    }
}

- (void)updatePlayerTime
{
    NSInteger timestamp = [self curPlayerTime];
    [self.curTimeLabel setText:[QHVCEditPrefs timeFormatMs:timestamp]];
    [self.slider setValue:timestamp];
}

- (void)updatePlayerDuration
{
    if ([self curPlayerTime] > [self playerDuration])
    {
        [self seekTo:0];
    }
    
    [self.slider setMaximumValue:[self playerDuration]];
    [self.durationLabel setText:[QHVCEditPrefs timeFormatMs:[self playerDuration]]];
}

#pragma mark - Do Some Test

- (IBAction)onTestButtonClicked:(id)sender
{
//    UIImage* timelineImage = [self.player getCurrentFrame];
//    NSDictionary* track1 = [self.player getCurrentFrameOfTrackIds:@[@(1)]];
//    UIImage* excludeImage = [self.player getCurrentFrameOfTrackId:-1 excludeEffectCommandIds:@[@(1)]];
//    NSString* path1 = [[NSBundle mainBundle] pathForResource:@"lut_14.png" ofType:nil];
//    NSString* path2 = [[NSBundle mainBundle] pathForResource:@"lut_15.png" ofType:nil];
//    NSArray* info = @[
//                      @{
//                          @"path":path1,
//                          @"image":@"",
//                          @"intensity":@1.0,
//                          @"dimension":@(64)},
//                      @{
//                          @"path":path2,
//                          @"image":@"",
//                          @"intensity":@1.0,
//                          @"dimension":@(64)},
//                      ];
//
//    [QHVCEditTools generateLUTFilterThumbnails:timelineImage
//                                  lutImageInfo:info
//                                        toSize:CGSizeMake(100, 100)
//                                      callback:^(UIImage *thumbnails, NSString *lutImagePaths)
//    {
//        NSLog(@"");
//    }];
//    [self.player setMuteState:YES];
}

#pragma mark - ContentView Methods

- (void)createContentViewAndParams
{
    [self.contentView setFrame:self.preview.frame];
    [self.contentView setBasePlayerVC:self];
    
    WEAK_SELF
    [self.contentView setResetPlayerAction:^{
        STRONG_SELF
        [self resetPlayerOfCurrentTime];
    }];
    
    [self.contentView setRefreshPlayerAction:^(BOOL isEnd)
     {
         STRONG_SELF
         [self refreshPlayer:isEnd];
     }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOverlayNotification:) name:QHVCEDIT_DEFINE_NOTIFY_SHOW_OVERLAY_FUNCTION object:nil];
    
    [self.contentView setRefreshPlayerForBasicParamAction:^{
        STRONG_SELF
        [self refreshPlayerForEffectBasicParams];
    }];
}

#pragma mark - Nav Methods

- (void)createNavView
{
    if (!_navView)
    {
        _navView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditMainNavView class] description] owner:self options:nil][0];
        _navView.frame = CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100);
        [_navView updateView:_functions];
        
        WEAK_SELF
        _navView.selectedCompletion = ^(NSInteger index)
        {
            STRONG_SELF
            QHVCEditFunctionViewType viewType = [self.functions[index][3] integerValue];
            if (viewType == QHVCEditFunctionViewTypeFunctionBase)
            {
                [self navToFunctionWithBaseType:index];
            }
            else
            {
                [self navToFunctionWithOtherType:index];
            }
        };
        [self.view addSubview:_navView];
    }
}

- (void)navToFunctionWithOtherType:(NSInteger)index
{
    //画中画
    QHVCEditSelectPhotoAlbumVC* vc = [[QHVCEditSelectPhotoAlbumVC alloc] init];
    NSInteger maxCount = 8 - [[[QHVCEditMediaEditorConfig sharedInstance] overlayItemArray] count];
    [vc setMaxCount:maxCount];
    WEAK_SELF
    [vc setCompletion:^(NSArray<QHVCPhotoItem *> *items)
    {
        STRONG_SELF
        if ([items count] > 0)
        {
            [self.contentView addOverlays:items complete:^{
                STRONG_SELF
                [self updatePlayerDuration];
            }];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)navToFunctionWithBaseType:(NSInteger)index
{
    NSString* className = _functions[index][2];
    QHVCEditFunctionBaseView* view = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil][0];
    
    if (view)
    {
        [self registFunctionBlocks:view];
        
        BOOL hideSlider = YES;
        int offsetY = [_functions[index][4] intValue];
        int viewHeight = CGRectGetHeight(view.frame);
        
        [view setPlayerContentView:self.contentView];
        [view setHeight:viewHeight+offsetY];
        [view setWidth:CGRectGetWidth(self.functionView.frame)];
        [view setPlayerBaseVC:self];
        [self.funcViewHeightConstraint setConstant:viewHeight+offsetY];
        [self.functionView addSubview:view];
        [self showFunction:offsetY hideSlider:hideSlider];
    }
}

- (void)registFunctionBlocks:(QHVCEditFunctionBaseView *)view
{
    if (view)
    {
        WEAK_SELF
        [view setConfirmBlock:^(UIView *functionView)
         {
             STRONG_SELF
             [functionView removeFromSuperview];
             [self hideFunction];
         }];
        
        [view setCancelBlock:^(UIView *functionView)
        {
            STRONG_SELF
            [functionView removeFromSuperview];
            [self hideFunction];
        }];
        
        [view setRefreshPlayerBlock:^(BOOL forceRefresh)
         {
             STRONG_SELF
             [self refreshPlayer:forceRefresh];
         }];
        
        [view setRefreshForEffectBasicParamsBlock:^{
            STRONG_SELF
            [self refreshPlayerForEffectBasicParams];
        }];
        
        [view setResetPlayerBlock:^{
            STRONG_SELF
            [self resetPlayer:[self curPlayerTime]];
        }];
        
        [view setUpdatePlayerDuraionBlock:^{
            STRONG_SELF
            [self updatePlayerDuration];
        }];
        
        [view setHidePlayButtonBolck:^(BOOL hidden)
        {
            STRONG_SELF
            [self.playBtn setHidden:hidden];
        }];
        
        [view setPlayPlayerBlock:^{
            STRONG_SELF
            [self playAction];
        }];
        
        [view setPausePlayerBlock:^{
            STRONG_SELF
            [self pauseAction];
        }];
        
        [view setSeekPlayerBlock:^(BOOL forceRefresh, NSInteger seekToTime)
         {
             STRONG_SELF
             [self seekTo:seekToTime forceRequest:forceRefresh];
             [self.curTimeLabel setText:[QHVCEditPrefs timeFormatMs:seekToTime]];
             [self.slider setValue:seekToTime];
         }];
    }
}

- (void)showFunction:(CGFloat)offsetY hideSlider:(BOOL)hideSlider
{
    [self.view layoutIfNeeded];
    WEAK_SELF
    [UIView animateWithDuration:0.2 animations:^{
        STRONG_SELF
        [self.topConstraint setConstant:[self topBarHeight] - offsetY];
        [self.bottomConstraint setConstant:self.bottomConstraint.constant + offsetY];
        [self hideTopNav];
        [self.functionView setHidden:NO];
        [self.navView setHidden:YES];
        [self.sliderView setHidden:hideSlider];
        [self.view layoutIfNeeded];
    }];
}

- (void)hideFunction
{
    [self.view layoutIfNeeded];
    WEAK_SELF
    [UIView animateWithDuration:0.1 animations:^{
        STRONG_SELF
        [self.topConstraint setConstant:[self topBarHeight]];
        [self.bottomConstraint setConstant:100];
        [self showTopNav];
        [self.functionView setHidden:YES];
        [self.navView setHidden:NO];
        [self.sliderView setHidden:NO];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Overlay Methods

- (void)onOverlayNotification:(NSNotification *)notification
{
    QHVCEditOverlayItemView* item = notification.object;
    [self showOverlayFunctionsView:item];
}

- (void)showOverlayFunctionsView:(QHVCEditOverlayItemView *)item
{
    __block NSString* nibName = @"";
    [_functions enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         NSString* name = obj[0];
         if ([name isEqualToString:@"画中画"])
         {
             nibName = obj[2];
             *stop = YES;
         }
     }];
    
    QHVCEditOverlayFunctionsView* view = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
    int viewHeight = CGRectGetHeight(view.frame);
    [self.funcViewHeightConstraint setConstant:viewHeight];
    [view setWidth:CGRectGetWidth(self.functionView.frame)];
    [view setClipItemView:item];
    [view setPlayerBaseVC:self];
    [self.functionView addSubview:view];
    [self showFunction:0 hideSlider:YES];
    [self registFunctionBlocks:view];
}


@end
