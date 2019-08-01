//
//  QHVCGVWatchRecordViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVWatchRecordViewController.h"
#import "LZDividingRulerView.h"
#import <QHVCNetKit/QHVCNetKit.h>
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGodViewLocalManager.h"
#import <QHVCPlayerKit/QHVCPlayerKit.h>
#import "QHVCGVConfig.h"
#import "QHVCGVDefine.h"
#import "QHVCToast.h"
#import "QHVCTool.h"
#import "QHVCGVWatchRecordCalendarViewController.h"
#import "QHVCGVSignallingManager.h"
#import "QHVCGVVideoRatioButton.h"
#import "QHVCGVDeviceModel.h"
#import "QHVCGVRulerTimeConfigFactory.h"
#import "QHVCGVWatchRecordDatePenel.h"
#import "QHVCGVFunctionBtn.h"
#import "QHVCGVWatchRecordCircleBtn.h"
#import "QHVCGVWatchRecordFileManager.h"
#import "UIView+QHVCGVGodViewCustom.h"
#import "QHVCToast.h"
#import "QHVCGVUserSystem.h"
#import "UIView+Toast.h"
#import "QHVCGlobalConfig.h"
#import "QHVCLogger.h"

/// seekTime检索方向（从timeline中查找相关方向最近的seektime)
typedef NS_ENUM(NSInteger,QHVCGVSeekTimeSearchDirection) {
    QHVCGVSeekTimeSearchDirectionLeft,   // 向左检索
    QHVCGVSeekTimeSearchDirectionRight,  // 向右检索
    QHVCGVSeekTimeSearchDirectionBoth    // 双向检索
};


// 播放视频的画布
#define kQHVCGVWatchRecordVC_PlayView_H                     (220.0f * kQHVCScreenScaleTo6)
// 视频加载的loading
#define kQHVCGVWatchRecordVC_Loading_W                      (37.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_Loading_H                      (37.0f * kQHVCScreenScaleTo6)
// 指标日志面板
#define kQHVCGVWatchRecordVC_PerformanceLog_W               (160.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_PerformanceLog_H               (150.0f * kQHVCScreenScaleTo6)
// 全屏按钮
#define kQHVCGVWatchRecordVC_BtnFullScreen_W                (28.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_BtnFullScreen_H                (28.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_BtnFullScreen_MarginRight      (15.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_BtnFullScreen_MarginBottom     (9.0f * kQHVCScreenScaleTo6)
// 日期时间
#define kQHVCGVWatchRecordVC_DateDisplayView_H              (30.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_DateDisplayView_MarginTop      (21.0f * kQHVCScreenScaleTo6 + kQHVCGVWatchRecordVC_PlayView_H)
// 播放按钮
#define kQHVCGVWatchRecordVC_PlayBtn_W                      (60.0f)
#define kQHVCGVWatchRecordVC_PlayBtn_H                      (60.0f)
#define kQHVCGVWatchRecordVC_PlayBtn_MarginBottom           (46.0f * kQHVCScreenScaleTo6 + kQHVCPhoneFringeHeight)
// 卡尺
#define kQHVCGVWatchRecordVC_RulerView_H                    (120.0f * kQHVCScreenScaleTo6)
// 控制缩放的拖动条
#define kQHVCGVWatchRecordVC_Slider_W                       (308.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_Slider_H                       (20.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_Slider_MarginTop               (CGRectGetWidth([UIScreen mainScreen].bounds) == 320 ? 8.0f : 47.0f)
// 功能按钮-倒退
#define kQHVCGVWatchRecordVC_BackwardBtn_W                  (55.0f)
#define kQHVCGVWatchRecordVC_BackwardBtn_H                  (55.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_BackwardBtn_MarginRight        (16.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_BackwardBtn_MarginBottom       (34.0f * kQHVCScreenScaleTo6 + kQHVCPhoneFringeHeight)
// 功能按钮-截图
#define kQHVCGVWatchRecordVC_Screenshot_W                   (30.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_Screenshot_Right               (9.0f * kQHVCScreenScaleTo6)
// 功能按钮-倍速播放
#define kQHVCGVWatchRecordVC_VideoRatio_W                   (55.0f)
#define kQHVCGVWatchRecordVC_VideoRatio_MarginLeft          (16.0f * kQHVCScreenScaleTo6)
// 功能按钮-录制
#define kQHVCGVWatchRecordVC_RecordBtn_W                    (30.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordVC_RecordBtn_MarginLeft           (9.0f * kQHVCScreenScaleTo6)
// 功能按钮字体颜色
#define kQHVCGVWatchRecordVC_FunctionBtn_TextColor          [QHVCToolUtils colorWithHexString:@"#666666"]

// 文案
/// 倒退的秒数，在圆圈下面显示的功能描述文本
#define kQHVCGVWatchRecordVC_Backward_Func_Text            [NSString stringWithFormat:@"倒退%@秒",kQHVCGVWatchRecordVC_Backward_Seconds]
/// 倒退的秒数，在圆圈内显示的文本
#define kQHVCGVWatchRecordVC_Backward_Circle_Text          [NSString stringWithFormat:@"%@秒",kQHVCGVWatchRecordVC_Backward_Seconds]
static NSString * const kQHVCGVWatchRecordVC_Screenshot_Text    = @"截图";
/// 倒退的秒数：如“倒退10秒"
static NSString * const kQHVCGVWatchRecordVC_Backward_Seconds   = @"10";

static NSString * const kQHVCGVWatchRecordVC_VideoRatio_Text                        = @"倍速播放";
static NSString * const kQHVCGVWatchRecordVC_Record_Text                            = @"录制";
static NSString * const kQHVCGVWatchRecordVC_Screenshot_Success_text                = @"已保存到系统相册";
static NSString * const kQHVCGVWatchRecordVC_Screenshot_Failure_text                = @"保存失败，请重新操作";



@interface QHVCGVWatchRecordViewController ()<QHVCGodViewLocalManagerDelegate, QHVCPlayerDelegate, QHVCPlayerAdvanceDelegate,LZDividingRulerViewDelegate,QHVCGVWatchRecordDatePenelDelegate,QHVCGVVideoRatioButtonDelegate>
{
    QHVCPlayer *_player;
    NSString* _sessionId;
    NSString* _playerUrl;
    
    NSDictionary<NSString*, NSArray<QHVCNetGodSeesRecordTimeline *> *>* _currentSelectDayDataDict;
}

@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong)  LZDividingRulerView *recordRulerView;

@property (nonatomic,strong) UIView *playerView;
@property (nonatomic,strong) QHVCGVWatchRecordDatePenel *dateDisplayView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingActivityIndicator;
/// 倍率按钮
@property (nonatomic,strong) QHVCGVVideoRatioButton *videoRatioButton;
/// 录制按钮
@property (nonatomic,strong) QHVCGVFunctionBtn *recordBtn;
/// 倒退n秒按钮
@property (nonatomic,strong) QHVCGVWatchRecordCircleBtn *backwardBtn;
@property (nonatomic,strong) UISlider *rulerSlider;
/// 控制卡尺伸缩的拖动条正在拖动
@property(nonatomic,assign) BOOL     isSliderEditing;
/// 卡尺正在滚动
@property(nonatomic,assign) BOOL     isRulerViewScrolling;
/// 正在录制的视频路径
@property (nonatomic,strong) NSString *recordingFilePath;
@property (nonatomic,assign) BOOL isPlayerBuffering;
@property (nonatomic,strong) UIButton *btnFullScreen;
@property (nonatomic,assign) BOOL isFullScreen;
/// 暂停后 拖动卡尺或选择日期时间后，在执行恢复操作后 还需要seek
@property (nonatomic,assign) BOOL isNeedSeek;
@property (nonatomic,assign) BOOL didClickPlay;

// ----------------- 指标测试用的时间 start-------------
/// 进入界面
@property (nonatomic,strong) NSDate *testDateViewDidLoad;
/// 取到卡录时间
@property (nonatomic,strong) NSDate *testDateGetRecordTime;
/// buffer第一次缓冲完成
@property (nonatomic,strong) NSDate *testDateBufferFirstComplete;
/// 是否播放过 用于统计第一次缓冲完成的回调
@property (nonatomic,assign) BOOL testIsPlayed;
/// 开始缓冲的时间
@property (nonatomic,strong) NSDate *testDateBufferingBegin;
/// 展示性能指标
@property (nonatomic,strong) UITextView *tvPerformanceInfo;
/// 码率
@property (nonatomic,strong) UITextView *tvBPS;
/// 采样率
@property (nonatomic,assign) int testSampleRate;
/// ----------------- 指标测试用的时间 end --------------

@end
/**
 1、请求卡录数据信息
 2、根据卡录数据信息选择一个时间点
 3、点击播放进行播放
 4、启动播放器
 5、seek操作
 6、退出操作
 */

@implementation QHVCGVWatchRecordViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupBackBarButton];
}

- (void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    self.testDateViewDidLoad = [NSDate date];
    [self prepareCardRecord];
    [self initPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)initViews {
    self.navigationItem.title = self.deviceModel.name;
    
    // 播放视频的画布
    self.playerView = [UIView new];
    _playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playerView];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.width.equalTo(self.view);
        make.height.equalTo(@(kQHVCGVWatchRecordVC_PlayView_H));
    }];
    
    // 视频加载loading
    self.loadingActivityIndicator = [UIActivityIndicatorView new];
    [self.view addSubview:_loadingActivityIndicator];
    [_loadingActivityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_playerView);
        make.width.height.equalTo(@(kQHVCGVWatchRecordVC_Loading_W));
    }];
    
    // 全屏按钮
    self.btnFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnFullScreen addTarget:self action:@selector(btnFullScreenClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnFullScreen setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_fullscreen") forState:UIControlStateNormal];
    [self.view addSubview:_btnFullScreen];
    [_btnFullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchRecordVC_BtnFullScreen_W));
        make.height.equalTo(@(kQHVCGVWatchRecordVC_BtnFullScreen_H));
        make.trailing.equalTo(self.view).offset(-kQHVCGVWatchRecordVC_BtnFullScreen_MarginRight);
        make.bottom.equalTo(_playerView).offset(-kQHVCGVWatchRecordVC_BtnFullScreen_MarginBottom);
    }];
    
    // 日期选择
    self.dateDisplayView = [QHVCGVWatchRecordDatePenel new];
    _dateDisplayView.delegate = self;
    [self.view addSubview:_dateDisplayView];
    [_dateDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kQHVCGVWatchRecordVC_DateDisplayView_MarginTop);
        make.centerX.width.equalTo(self.view);
        make.height.equalTo(@(kQHVCGVWatchRecordVC_DateDisplayView_H));
    }];
    [_dateDisplayView setupUI];
    NSString* dataTime = [QHVCTool getTimeStringByDate:[NSDate dateWithTimeIntervalSince1970:0] format:@"yyyy-MM-dd HH:mm:ss"];
    [_dateDisplayView updateTitle:dataTime];
    _dateDisplayView.userInteractionEnabled = NO;
    
    // 播放按钮
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_play_sel") forState:UIControlStateNormal];
    [_playButton setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_pause_sel") forState:UIControlStateSelected];
    [_playButton addTarget:self action:@selector(clickedPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    _playButton.enabled = NO;
    [self.view addSubview:_playButton];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchRecordVC_PlayBtn_W));
        make.width.equalTo(@(kQHVCGVWatchRecordVC_PlayBtn_H));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kQHVCGVWatchRecordVC_PlayBtn_MarginBottom);
    }];
    
    // 倒退
    self.backwardBtn = [QHVCGVWatchRecordCircleBtn new];
    [_backwardBtn addTarget:self action:@selector(backwardBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backwardBtn];
    [_backwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchRecordVC_BackwardBtn_W));
        make.height.equalTo(@(kQHVCGVWatchRecordVC_BackwardBtn_H));
        make.trailing.equalTo(_playButton.mas_leading).offset(-kQHVCGVWatchRecordVC_BackwardBtn_MarginRight);
        make.bottom.equalTo(self.view).offset(-kQHVCGVWatchRecordVC_BackwardBtn_MarginBottom);
    }];
    [_backwardBtn setupWithCircleText:kQHVCGVWatchRecordVC_Backward_Circle_Text functionText:kQHVCGVWatchRecordVC_Backward_Func_Text];
    _backwardBtn.enabled = NO;
    
    // 截图
    QHVCGVFunctionBtn *screenshotBtn = [QHVCGVFunctionBtn new];
    [screenshotBtn addTarget:self action:@selector(screenshotBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:screenshotBtn];
    [screenshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchRecordVC_Screenshot_W));
        make.height.bottom.equalTo(_backwardBtn);
        make.trailing.equalTo(_backwardBtn.mas_leading).offset(-kQHVCGVWatchRecordVC_Screenshot_Right);
    }];
    [screenshotBtn setupWithIconImage:kQHVCGetImageWithName(@"godview_btn_screenshot")
                                 text:kQHVCGVWatchRecordVC_Screenshot_Text
                            textColor:kQHVCGVWatchRecordVC_FunctionBtn_TextColor];
    
    // 倍速播放
    self.videoRatioButton = [QHVCGVVideoRatioButton buttonWithType:UIButtonTypeCustom];
    _videoRatioButton.delegate = self;
    [self.view addSubview:_videoRatioButton];
    [_videoRatioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchRecordVC_VideoRatio_W));
        make.bottom.height.equalTo(_backwardBtn);
        make.leading.equalTo(_playButton.mas_trailing).offset(kQHVCGVWatchRecordVC_VideoRatio_MarginLeft);
    }];
    //    [_videoRatioButton setupWithVideoRatios:@[@"1",@"1.5",@"2",@"2.5",@"3",@"3.5",@"4"]];
    [_videoRatioButton setupWithVideoRatios:@[@"0.2",@"0.5",@"1",@"1.5",@"2",@"2.5",@"3",@"4",@"8"]];
    // 禁用，待播放器初始化后再开启点击
    _videoRatioButton.enabled = NO;
    
    // 录制
    self.recordBtn = [QHVCGVFunctionBtn new];
    _recordBtn.enabled = NO;
    [_recordBtn addTarget:self action:@selector(clickedRecordButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recordBtn];
    [_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchRecordVC_RecordBtn_W));
        make.height.bottom.equalTo(_backwardBtn);
        make.leading.equalTo(_videoRatioButton.mas_trailing).offset(kQHVCGVWatchRecordVC_RecordBtn_MarginLeft);
    }];
    [_recordBtn setupWithIconImage:kQHVCGetImageWithName(@"godview_btn_record_nor")
                     selectedImage:kQHVCGetImageWithName(@"godview_btn_record_sel")
                              text:kQHVCGVWatchRecordVC_Record_Text
                         textColor:kQHVCGVWatchRecordVC_FunctionBtn_TextColor
                              font:kQHVCFontPingFangHKRegular(12)];
    
    [self.loadingActivityIndicator setHidden:YES];
    [self.loadingActivityIndicator setHidesWhenStopped:YES];
    [_dateDisplayView setLastDayBtnEnable:NO];
    [_dateDisplayView setNextDayBtnEnable:NO];
    
    [self setupRecordRuler:nil];
    
    [self setupPerformanceInfoTextView];
    [self setupBPSTextView];
}


-  (void)setupPerformanceInfoTextView
{
    if ([QHVCGVConfig sharedInstance].shouldShowPerformanceInfo == NO)
    {
        return;
    }
    self.tvPerformanceInfo = [UITextView new];
    _tvPerformanceInfo.textColor = [UIColor whiteColor];
    _tvPerformanceInfo.layer.cornerRadius = 5;
    [self.view addSubview:_tvPerformanceInfo];
    _tvPerformanceInfo.editable = NO;
    [_tvPerformanceInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.equalTo(self.view);
        make.width.equalTo(@(kQHVCGVWatchRecordVC_PerformanceLog_W));
        make.height.equalTo(@(kQHVCGVWatchRecordVC_PerformanceLog_H));
    }];
    _tvPerformanceInfo.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}


- (void)setupBPSTextView {
    if ([QHVCGVConfig sharedInstance].shouldShowPerformanceInfo == NO)
    {
        return;
    }
    self.tvBPS = [UITextView new];
    _tvBPS.textColor = [UIColor whiteColor];
    _tvBPS.layer.cornerRadius = 5;
    [self.view addSubview:_tvBPS];
    _tvBPS.editable = NO;
    [_tvBPS mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-50);
        make.top.equalTo(_tvPerformanceInfo.mas_bottom).offset(5);
        make.width.equalTo(@(kQHVCGVWatchRecordVC_PerformanceLog_W));
        make.height.equalTo(@(60));
    }];
    _tvBPS.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

- (void)adjustPlayerViewToEnterFullScreen {
    UIView *keywindow = [UIApplication sharedApplication].keyWindow;
    //    [_btnFullScreen setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_exit_fullscreen") forState:UIControlStateNormal];
    
    UIView *contentView = [UIView new];
    [keywindow addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keywindow);
        make.height.equalTo(@(kQHVCGVWatchRecordVC_PlayView_H));
        make.top.equalTo(keywindow).offset(kQHVCStatusAndNaviBarHeight);
    }];
    [self.playerView removeFromSuperview];
    [contentView addSubview:_playerView];
    [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
    
    [_btnFullScreen removeFromSuperview];
    [contentView addSubview:_btnFullScreen];
    [_btnFullScreen mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchRecordVC_BtnFullScreen_W));
        make.height.equalTo(@(kQHVCGVWatchRecordVC_BtnFullScreen_H));
        make.trailing.equalTo(contentView).offset(-kQHVCGVWatchRecordVC_BtnFullScreen_MarginRight);
        make.bottom.equalTo(contentView).offset(-kQHVCGVWatchRecordVC_BtnFullScreen_MarginBottom);
    }];
    
    [_loadingActivityIndicator removeFromSuperview];
    [contentView addSubview:_loadingActivityIndicator];
    [_loadingActivityIndicator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_playerView);
        make.width.height.equalTo(@(kQHVCGVWatchRecordVC_Loading_W));
    }];
    
    [keywindow setNeedsLayout];
    [keywindow layoutIfNeeded];
    
    [contentView setNeedsLayout];
    [contentView layoutIfNeeded];
    
    [UIView animateWithDuration:0.5 animations:^{
        [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(keywindow);
            make.width.equalTo(@(kQHVCScreenHeight));
            make.height.equalTo(@(kQHVCScreenWidth));
        }];
        [keywindow setNeedsLayout];
        [keywindow layoutIfNeeded];
        [contentView setNeedsLayout];
        [contentView layoutIfNeeded];
        contentView.transform = CGAffineTransformRotate(contentView.transform, M_PI_2);
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)adjustPlayerViewToExitFullScreen {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_btnFullScreen setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_fullscreen") forState:UIControlStateNormal];
    
    UIView *contentView = _playerView.superview;
    UIView *keywindow = [UIApplication sharedApplication].keyWindow;
    [UIView animateWithDuration:0.5 animations:^{
        [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keywindow);
            make.height.equalTo(@(kQHVCGVWatchRecordVC_PlayView_H));
            make.top.equalTo(keywindow).offset(kQHVCStatusAndNaviBarHeight);
        }];
        contentView.transform = CGAffineTransformRotate(contentView.transform, -M_PI_2);
        [keywindow setNeedsLayout];
        [keywindow layoutIfNeeded];
        [contentView setNeedsLayout];
        [contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_playerView removeFromSuperview];
        [self.view addSubview:_playerView];
        [_playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.width.equalTo(self.view);
            make.height.equalTo(@(kQHVCGVWatchRecordVC_PlayView_H));
        }];
        
        [_btnFullScreen removeFromSuperview];
        [self.view addSubview:_btnFullScreen];
        [_btnFullScreen mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kQHVCGVWatchRecordVC_BtnFullScreen_W));
            make.height.equalTo(@(kQHVCGVWatchRecordVC_BtnFullScreen_H));
            make.trailing.equalTo(self.view).offset(-kQHVCGVWatchRecordVC_BtnFullScreen_MarginRight);
            make.bottom.equalTo(_playerView).offset(-kQHVCGVWatchRecordVC_BtnFullScreen_MarginBottom);
        }];
        
        [_loadingActivityIndicator removeFromSuperview];
        [self.view addSubview:_loadingActivityIndicator];
        [_loadingActivityIndicator mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_playerView);
            make.width.height.equalTo(@(kQHVCGVWatchRecordVC_Loading_W));
        }];
        
        [contentView removeFromSuperview];
        [self.view bringSubviewToFront:_tvPerformanceInfo];
        [self.view bringSubviewToFront:_tvBPS];
    }];
}

#pragma mark - 卡录数据流程准备 -
- (void) prepareCardRecord
{
    QHVCGlobalConfig* globalConfig = [QHVCGlobalConfig sharedInstance];
    QHVCGVConfig * config = [QHVCGVConfig sharedInstance];
    [[QHVCGodViewLocalManager sharedInstance] setDelegate:self];
    _sessionId = [NSString stringWithFormat:@"%@_%@_%lld",globalConfig.appId, config.userName, [QHVCToolUtils getCurrentDateByMilliscond]];
    [[QHVCGodViewLocalManager sharedInstance] enableGodSeesMonitorVideoState:config.shouldShowPerformanceInfo];
    [[QHVCGodViewLocalManager sharedInstance] setGodSeesNetworkConnectType:config.networkConnectType];
    NSString* businessSign = [QHVCGlobalConfig generateBusinessSubscriptionSignWithAppId:globalConfig.appId
                                                                      serialNumber:_deviceModel.bindedSN
                                                                          deviceId:globalConfig.deviceId
                                                                            appKey:globalConfig.appKey];
    [[QHVCGodViewLocalManager sharedInstance] createGodSeesSession:_sessionId
                                                          clientId:globalConfig.deviceId
                                                             appId:globalConfig.appId
                                                            userId:[[QHVCGVUserSystem sharedInstance] userInfo].userId
                                                      serialNumber:_deviceModel.bindedSN
                                               deviceChannelNumber:1
                                                      businessSign:businessSign
                                                       sessionType:QHVC_NET_GODSEES_SESSION_TYPE_RECORD
                                                           options:@{kQHVCNetGodSeesOptionsStreamTypeKey:@([config streamType]),kQHVCNetGodSeesOptionsPlayerReceiveDataModelKey:@([config playerReceiveDataModel])}];
    _playerUrl = [[QHVCGodViewLocalManager sharedInstance] getGodSeesPlayUrl:_sessionId];
    [[QHVCGodViewLocalManager sharedInstance] verifyGodSeesBusinessTokenToDevice:_sessionId token:[QHVCGVUserSystem sharedInstance].userInfo.token];
}

- (void) analysisCardRecordTimeline:(NSArray<QHVCNetGodSeesRecordTimeline *> *) data
{
    self.testDateGetRecordTime = [NSDate date];
    
    if (data.count == 0)
    {
        runOnMainQueueWithoutDeadlocking(^{
            [QHVCToast makeToast:@"暂无卡录数据"];
        });
        return;
    }
    if (_timelineArray == nil)
    {
        _timelineArray = [NSMutableArray array];
    }
    [_timelineArray removeAllObjects];
    _currentSeekTime = 0;
    _currentSelectDay = nil;
    _currentSelectDayDataDict = nil;
    //按天分析时间
    NSString* currentDate = nil;
    NSMutableArray<QHVCNetGodSeesRecordTimeline *>* currentArray = nil;
    for (int i = 0; i < data.count; i++)
    {
        QHVCNetGodSeesRecordTimeline* timeLine = data[i];
        NSString* tmpDay = [QHVCTool getTimeStringBySecond:timeLine.startMS/1000 format:@"yyyy-MM-dd"];
        if (currentDate == nil || ![tmpDay isEqualToString:currentDate])
        {
            currentDate = tmpDay;
            currentArray = [NSMutableArray array];
            NSDictionary<NSString*, NSArray<QHVCNetGodSeesRecordTimeline *> *>* tmpDict = @{currentDate:currentArray};
            [_timelineArray addObject:tmpDict];
        }
        [currentArray addObject:timeLine];
    }
    
    // 获取最后一天的数据 作为初始seek值
    NSDictionary *lastDayDict = [_timelineArray lastObject];
    QHVCNetGodSeesRecordTimeline *timeline = [[lastDayDict objectForKey:lastDayDict.allKeys.firstObject] lastObject];
    NSString *tmpDay = [QHVCTool getTimeStringBySecond:timeline.startMS/1000 format:@"yyyy-MM-dd"];
    NSDate *selectedDate = [QHVCTool getDateByString:tmpDay format:@"yyyy-MM-dd"];
    
    // 刚进入卡录界面 自动播放当前时间前1小时视频k
    // 获取当前时间往前1小时的时间戳(时间检索算法会在当天的时间戳内搜索最接近的值，所以减1小时候后即使超出当天的范围，也能保证正确性)
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    currentTimeInterval -= 1 * 60 * 60;
    NSUInteger originalSeekTime = (NSUInteger)currentTimeInterval * 1000;
    
    //初始化时间标尺，并指定初始位置
    [self analysisCardRecordTimelineByDate:selectedDate seekTime:originalSeekTime];
    runOnMainQueueWithoutDeadlocking(^{
        _dateDisplayView.userInteractionEnabled = YES;
        [_playButton setEnabled:YES];
    });
}

- (void) analysisCardRecordTimelineByDate:(NSDate *)currentDate seekTime:(NSUInteger)seekTime
{
    //判定是否有上一段、下一段数据
    NSString * currentDay = [QHVCTool getTimeStringByDate:currentDate format:@"yyyy-MM-dd"];//需要注意时间转换
    _currentSelectDay = currentDay;
    _currentSelectDayDataDict = nil;
    __block BOOL beforeDay = NO;
    __block BOOL afterDay = NO;
    [_timelineArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * key = obj.allKeys[0];
        NSComparisonResult result = [currentDay compare:key];
        if (result == NSOrderedAscending)
        {
            afterDay = YES;
        }else if (result == NSOrderedDescending)
        {
            beforeDay = YES;
        }else
        {
            _currentSelectDayDataDict = obj;
        }
    }];
    
    NSUInteger usefulSeekTime = [self searchClosestSeekTime:seekTime searchDirection:QHVCGVSeekTimeSearchDirectionBoth];
    
    WEAK_SELF_GODVIEW
    runOnMainQueueWithoutDeadlocking(^{
        STRONG_SELF_GODVIEW
        //如果有上一段数据
        [_dateDisplayView setNextDayBtnEnable:afterDay];
        //如果有下一段数据
        [_dateDisplayView setLastDayBtnEnable:beforeDay];
        
        //初始化当天时间标尺
        NSArray<QHVCNetGodSeesRecordTimeline *>* timeLineArray = _currentSelectDayDataDict[currentDay];
        if (timeLineArray.count > 0)
        {//若有数据
            _currentSeekTime = usefulSeekTime > 0 ? usefulSeekTime : timeLineArray[0].startMS;
            
            if (self.didClickPlay == YES)
            {
                // 已经播放过，非第一次执行卡录数据分析，则是seek操作，需要标记为seek
                self.isNeedSeek = YES;
            }
            [self clickedPlayButton:_playButton];
            
        }else
        {//若无数据
            _currentSeekTime = currentDate.timeIntervalSince1970;
            _currentSelectDay = [QHVCTool getTimeStringByDate:[NSDate dateWithTimeIntervalSince1970:0] format:@"yyyy-MM-dd"];
        }
        //设置日历时间
        NSString* dataTime = [QHVCTool getTimeStringBySecond:_currentSeekTime/1000 format:@"yyyy-MM-dd HH:mm:ss"];
        [_dateDisplayView updateTitle:dataTime];
        //初始化卡尺
        [self setupRecordRuler:timeLineArray];
    });
}


- (void)initPlayer
{
    if (_player != nil)
    {
        [_player stop];
        _player = nil;
    }
    [QHVCPlayer setLogLevel:(QHVCPlayerLogLevel)[QHVCLogger getLoggerLevel]];
    QHVCGVConfig * config = [QHVCGVConfig sharedInstance];
    QHVCGlobalConfig * globalConfig = [QHVCGlobalConfig sharedInstance];
    int inputStreamValue = [config playerReceiveDataModel] == QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_CALLBACK?1:0;
    _player = [[QHVCPlayer alloc] initWithURL:_playerUrl
                                    channelId:globalConfig.appId
                                       userId:config.userName
                                     playType:QHVCPlayTypeLive
                                      options:@{@"hardDecode":@([config isHardDecode]),@"playMode":@(QHVCPlayModeLowLatency),@"max_buffering_delay":@(600),@"inputStream":@(inputStreamValue)}];
    _player.playerDelegate = self;
    _player.playerAdvanceDelegate = self;
    
    [_player createPlayerView:_playerView];
    [_player setSystemVolumeCallback:YES];
    [_player setSystemVolumeViewHidden:NO];
    [_player prepare];
    if ([[QHVCGVConfig sharedInstance] shouldShowPerformanceInfo]) {
        [_player openNetStats:5];
    }
}

- (void) stopPlayer
{
    [_player stop];
    _player = nil;
    [[QHVCGodViewLocalManager sharedInstance] setDelegate:nil];
    [[QHVCGodViewLocalManager sharedInstance] destroyGodSeesSession:_sessionId];
}

#pragma mark - UI交互事件 -
/*
 * 导航栏返回
 */
- (void)onBack {
    [self stopPlayer];
    [super onBack];
}

/**
 * 截图
 */
- (void)screenshotBtnClick {
    UIImage *image = [_playerView takeScreenshot];
    [[QHVCGVWatchRecordFileManager sharedManager] saveImageToAlbum:image completion:^(BOOL isSuccess, NSError * _Nullable error) {
        [QHVCToast makeToast:isSuccess ? kQHVCGVWatchRecordVC_Screenshot_Success_text : kQHVCGVWatchRecordVC_Screenshot_Failure_text];
    }];
}

/**
 * 倒退n秒
 */
- (void)backwardBtnClick {
    self.currentSeekTime = [self backwardSeconds:[kQHVCGVWatchRecordVC_Backward_Seconds floatValue] fromTimestamp:_currentSeekTime];
    NSString* dataTime = [QHVCTool getTimeStringBySecond:_currentSeekTime/1000 format:@"yyyy-MM-dd HH:mm:ss"];
    [_dateDisplayView updateTitle:dataTime];
    _recordRulerView.currentValue = [QHVCTool surplusIntervalThatDayFromUTCInterval:_currentSeekTime] / _recordRulerView.timePrecision;
    if (self.didClickPlay) {
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordSeek:_sessionId timeStamp:self.currentSeekTime];
        if (self.playButton.isSelected == NO)
        {
            [self.playButton setSelected:YES];
        }
    }
}

/*
 * 录制
 */
- (void)clickedRecordButton:(UIButton *)button {
    if (button.isSelected) {
        [_player stopRecorder];
        // 提示上传
#pragma TODO 提示上传 等产品设计UI交互
    }
    else {
        NSString *fileName = [NSString stringWithFormat:@"godview_reocrd_%f.mp4",[[NSDate date] timeIntervalSince1970]];
        self.recordingFilePath = [[QHVCGVWatchRecordFileManager recordFileDirectory] stringByAppendingPathComponent:fileName];
        [_player startRecorder:self.recordingFilePath recorderFormat:QHVCRecordFormatDefault recordConfig:nil];
    }
    [button setSelected:!button.isSelected];
}

- (void)btnFullScreenClick:(UIButton *)btn {
    if (self.isFullScreen) {
        [self adjustPlayerViewToExitFullScreen];
    }
    else {
        [self adjustPlayerViewToEnterFullScreen];
    }
    self.isFullScreen = !_isFullScreen;
}


/*
 * 播放
 */
- (void)clickedPlayButton:(id)sender
{
    BOOL selectedPlay = self.playButton.isSelected;
    [self.playButton setSelected:!selectedPlay];
    if (!selectedPlay)
    {
        if (self.didClickPlay) {
            [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordResume:_sessionId];
            if (self.isNeedSeek) {
                self.isNeedSeek = NO;
                [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordSeek:_sessionId timeStamp:_currentSeekTime];
            }
            self.testDateBufferingBegin  = [NSDate date];
            [_player play];
        }
        else {
            [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordSeek:_sessionId timeStamp:_currentSeekTime];
            _videoRatioButton.enabled = YES;
            _recordBtn.enabled = YES;
            _backwardBtn.enabled = YES;
        }
    } else
    {
        [self.loadingActivityIndicator setHidden:YES];
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordPause:_sessionId];
    }
    self.didClickPlay = YES;
}

/**
 *  选择日期
 */
- (void) selectRecordTime:(NSString *)selectDay seekTime:(NSUInteger)seekTime
{
    self.isNeedSeek = YES;
    self.currentSelectDay = selectDay;
    self.currentSeekTime = seekTime;
    NSDate* date = [QHVCTool getDateByString:selectDay format:@"yyyy-MM-dd"];
    [self analysisCardRecordTimelineByDate:date seekTime:seekTime];
}

/**
 * 点击选择日期按钮
 */
- (void)watchRecordDatePenelDidClickDate {
    if (_player) {
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordPause:_sessionId];
    }
    [self.playButton setSelected:NO];
    
    QHVCGVWatchRecordCalendarViewController* calendarViewController = [[QHVCGVWatchRecordCalendarViewController alloc] initWithTimeline:self];
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

/**
 * 点击前一天箭头
 *
 * 算法：
 * 1. 从timeline中找到从currentSelectDay开始 往前存在数据的日期
 * 2. 将该日期拼接上当前seekTime的时分秒 作为目标seekTime 比如当前日期2018-10-30 11:20:00，往前找到28号有数据，
 那么目标seekTime就是2018-10-28 11:20:00，
 * 3. 将2中的日期及seekTime丢给analysisCardRecordTimelineByDate方法。
 analysisCardRecordTimelineByDate内部会寻找目标日期内距离目标seekTime最近的视频点，并设置前后按钮能否点击的操作
 */
- (void)watchRecordDatePenelDidClickLastDay {
    if (_player) {
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordPause:_sessionId];
    }
    [self.playButton setSelected:NO];
    // 往前  倒序遍历 找到第一个小于当前日期的天数
    __block NSDictionary *destDict = nil;
    QHVC_WEAK_SELF
    [_timelineArray.reverseObjectEnumerator.allObjects enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QHVC_STRONG_SELF
        NSString *key = obj.allKeys.firstObject;
        if ([key compare:self.currentSelectDay] == NSOrderedAscending) {
            *stop = YES;
            destDict = obj;
        }
    }];
    // 能点击前一天的按钮往前查找 说明理论上前面是有数据的，destDict不应该为nil，不过这里还是做个异常处理。
    if (destDict == nil) {
        return;
    }
    NSString *destDay = destDict.allKeys.firstObject;
    NSDate *date = [QHVCTool getDateByString:destDay format:@"yyyy-MM-dd"];
    NSInteger currentDaySeconds = [QHVCTool surplusIntervalThatDayFromUTCInterval:_currentSeekTime];
    NSDate *destDate = [date dateByAddingTimeInterval:currentDaySeconds];
    NSUInteger destSeekTime = [destDate timeIntervalSince1970] * 1000;
    [self analysisCardRecordTimelineByDate:destDate seekTime:destSeekTime];
}

/**
 * 点击后一天箭头
 *
 * 算法：（同点击前一天的处理一样）
 * 1. 从timeline中找到从currentSelectDay开始 往后存在数据的日期
 * 2. 将该日期拼接上当前seekTime的时分秒 作为目标seekTime 比如当前日期2018-10-28 11:20:00，往前找到31号有数据，
 那么目标seekTime就是2018-10-31 11:20:00，
 * 3. 将2中的日期及seekTime丢给analysisCardRecordTimelineByDate方法。
 analysisCardRecordTimelineByDate内部会寻找目标日期内距离目标seekTime最近的视频点，并设置前后按钮能否点击的操作
 */
- (void)watchRecordDatePenelDidClickNextDay {
    if (_player) {
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordPause:_sessionId];
    }
    [self.playButton setSelected:NO];
    // 往后  顺序遍历 找到第一个大于当前日期的天数
    __block NSDictionary *destDict = nil;
    QHVC_WEAK_SELF
    [_timelineArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        QHVC_STRONG_SELF
        NSString *key = obj.allKeys.firstObject;
        if ([self.currentSelectDay compare:key] == NSOrderedAscending) {
            *stop = YES;
            destDict = obj;
        }
    }];
    // 能点击后一天的按钮往前查找 说明理论上前面是有数据的，destDict不应该为nil，不过这里还是做个异常处理。
    if (destDict == nil) {
        return;
    }
    NSString *destDay = destDict.allKeys.firstObject;
    NSDate *date = [QHVCTool getDateByString:destDay format:@"yyyy-MM-dd"];
    NSInteger currentDaySeconds = [QHVCTool surplusIntervalThatDayFromUTCInterval:_currentSeekTime];
    NSDate *destDate = [date dateByAddingTimeInterval:currentDaySeconds];
    NSUInteger destSeekTime = [destDate timeIntervalSince1970] * 1000;
    [self analysisCardRecordTimelineByDate:destDate seekTime:destSeekTime];
}

/**
 * 选择倍率
 */
- (void)videoRatioButtonDidSelectVideoRatio:(NSString *)videoRatio {
    [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordPlayRate:_sessionId rate:videoRatio.doubleValue];
}

#pragma mark - QHVCGodViewLocalManagerDelegate相关实现 -

- (void) onGodSees:(NSString *)sessionId didReceiveFrameDataType:(QHVCNetGodSeesFrameDataType)frameDataType
         frameData:(const uint8_t *)frameData
      frameDataLen:(int)length
               pts:(uint64_t)pts
               dts:(uint64_t)dts
        isKeyFrame:(BOOL)isKeyFrame
{
    QHVC_PACKET_TYPE type = QHVC_PACKET_TYPE_NONE;
    if (frameDataType == QHVC_NET_GODSEES_FRAME_DATA_TYPE_H264)
    {
        type = QHVC_PACKET_TYPE_H264;
    }
    else if (frameDataType == QHVC_NET_GODSEES_FRAME_DATA_TYPE_H265)
    {
        type = QHVC_PACKET_TYPE_H265;
    }
    else if (frameDataType == QHVC_NET_GODSEES_FRAME_DATA_TYPE_AAC)
    {
        type = QHVC_PACKET_TYPE_AAC;
    }
    [_player inputStream:type data:frameData size:length pts:pts dts:dts isKey:isKeyFrame];
}

- (void) onGodSees:(NSString *)sessionId didMonitorNetworkInfo:(nonnull NSString *)info
{
    [self appendPerformanceTextIfNeed:info];
}

- (void) onGodSees:(NSString *)sessionId didError:(QHVCNetGodSeesErrorCode)errorCode
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"onGodsees didError: sessionId = %@, errorCode = %ld",sessionId,errorCode]];
    NSString *errMsg = @"";
    if (errorCode == QHVC_NET_GODSEES_ERROR_SESSION_ID_INVALID) {
        errMsg = kQHVC_NET_GODSEES_ERROR_SID_INVALID_TEXT;
    }
    else if (errorCode == QHVC_NET_GODSEES_ERROR_SERIAL_NUMBER_INVALID)  {
        errMsg = kQHVC_NET_GODSEES_ERROR_SN_INVALID_TEXT;
    }
    else if (errorCode == QHVC_NET_GODSEES_ERROR_TOKEN_INVALID) {
        errMsg = kQHVC_NET_GODSEES_ERROR_TOKEN_INVALID_TEXT;
    }
    else if (errorCode == QHVC_NET_GODSEES_ERROR_SESSION_DISCONNECT) {
        errMsg = kQHVC_NET_GODSEES_ERROR_SESSION_NET_BROKEN_TEXT;
    }
    else if(errorCode == QHVC_NET_GODSEES_ERROR_FRAME_DECRYPT_KEY_INVALID)  {
        errMsg = kQHVC_NET_GODSEES_ERROR_DECRYPT_KEY_INVALID_TEXT;
    }
    errMsg = [errMsg stringByAppendingFormat:@" 错误码:%zd",errorCode];
    runOnMainQueueWithoutDeadlocking(^{
        [QHVCToast makeToast:errMsg];
    });
}

- (void) onGodSees:(NSString *)sessionId didVerifyToken:(NSInteger)status info:(NSString *)info
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_TRACE content:[NSString stringWithFormat:@"didVerifyToken: sessionId = %@, status = %zd, info = %@",sessionId,status,info]];
    if ([_sessionId isEqual:sessionId])
    {
        if (status == QHVC_NET_GODSEES_ERROR_NO_ERROR)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[QHVCGodViewLocalManager sharedInstance] getGodSeesRecordTimeline:_sessionId];
            });
            return;
        }
        
        NSString *errMsg = @"";
        if (status == QHVC_NET_GODSEES_TOKEN_ERROR_TokenVerifyFail) {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_TokenVerifyFail_TEXT;
        }
        else if (status == QHVC_NET_GODSEES_TOKEN_ERROR_RelayConnectionOverLimit) {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_RelayConnectionOverLimit_TEXT;
        }
        else if (status == QHVC_NET_GODSEES_TOKEN_ERROR_RecordConnectionOverLimit) {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_RecordConnectionOverLimit_TEXT;
        }
        else if (status == QHVC_NET_GODSEES_TOKEN_ERROR_TotalConnectionOverLimit) {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_TotalConnectionOverLimit_TEXT;
        }
        errMsg = [errMsg stringByAppendingFormat:@" 错误码:%zd",status];
        runOnMainQueueWithoutDeadlocking(^{
            [QHVCToast makeToast:errMsg];
        });
    }
}

- (void) onGodSees:(NSString *)sessionId didRecordTimeline:(NSArray<QHVCNetGodSeesRecordTimeline *> *)data
{
    if ([_sessionId isEqual:sessionId])
    {
        [self analysisCardRecordTimeline:data];
    }
}

- (void) onGodSees:(NSString *)sessionId didRecordUpdateCurrentTimeStamp:(NSUInteger)timeStampByMS
{
    runOnMainQueueWithoutDeadlocking(^{
        if ([_sessionId isEqual:sessionId]
            && !self.isRulerViewScrolling
            && self.playButton.isSelected
            //            && !self.isPlayerBuffering
            )
        {
            _currentSeekTime = timeStampByMS;
            NSString* dataTime = [QHVCTool getTimeStringBySecond:_currentSeekTime/1000 format:@"yyyy-MM-dd HH:mm:ss"];
            [_dateDisplayView updateTitle:dataTime];
            _recordRulerView.currentValue = [QHVCTool surplusIntervalThatDayFromUTCInterval:_currentSeekTime] / _recordRulerView.timePrecision;
            
            NSString *currentPlayDay = [QHVCTool getTimeStringBySecond:_currentSeekTime/1000 format:@"yyyy-MM-dd"];
            // 卡录播放日期已跳转，同步卡尺数据
            if (![currentPlayDay isEqualToString:_currentSelectDay])
            {
                if (_player)
                {
                    [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordPause:_sessionId];
                }
                self.currentSelectDay = currentPlayDay;
                self.currentSeekTime = timeStampByMS;
                [self.playButton setSelected:NO];
                self.isNeedSeek = YES;
                NSDate* date = [QHVCTool getDateByString:currentPlayDay format:@"yyyy-MM-dd"];
                [self analysisCardRecordTimelineByDate:date seekTime:timeStampByMS];
            }
        }
    });
}

- (void) onGodSees:(NSString *)sessionId didRecordPlaybackRate:(double)rate {
    if ([_sessionId isEqual:sessionId] && _player)
    {
        [_player setPlaybackRate:(float)rate];
    }
}

- (void) onGodSeesRecordPlayComplete:(NSString *)sessionId
{
    if ([_sessionId isEqual:sessionId])
    {
        runOnMainQueueWithoutDeadlocking(^{
            [QHVCToast makeToast:kQHVC_NET_GODSEES_REOCRD_PLAY_COMPLETED_TEXT];
        });
    }
}

- (void) onGodSeesSignallingSendData:(NSString *)destId data:(NSString *)data {
    [[QHVCGVSignallingManager sharedInstance] sendMessage:data to:destId];
}

- (void) onGodSeesRecordSeekComplete:(NSString *)sessionId {
    
}

- (void) onGodSeesRecordPause:(NSString *)sessionId {
    
}

- (void) onGodSeesRecordResume:(NSString *)sessionId {
    
}

#pragma mark - QHVCPlayerDelegate相关实现 -

/**
 播放器首次加载缓冲准备完毕，在此回调中调用play开始播放
 */
- (void)onPlayerPrepared:(QHVCPlayer *_Nonnull)player
{
    [_player play];
}

/**
 播放器首屏渲染，可以显示第一帧画面
 */
- (void)onPlayerFirstFrameRender:(NSDictionary *_Nullable)mediaInfo player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 播放结束回调
 */
- (void)onPlayerFinish:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 * 视频大小变化通知
 *
 * @param width  视频宽度
 * @param height 视频高度
 */
- (void)onPlayerSizeChanged:(int)width height:(int)height player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 开始缓冲(buffer为空，触发loading)
 */
- (void)onPlayerBufferingBegin:(QHVCPlayer *_Nonnull)player
{
    [self.loadingActivityIndicator setHidden:NO];
    [self.loadingActivityIndicator startAnimating];
    self.isPlayerBuffering = YES;
    self.testDateBufferingBegin = [NSDate date];
}

/**
 * 缓冲进度(buffer loading进度)
 *
 * @param progress 缓冲进度，progress==0表示开始缓冲， progress==100表示缓冲结束
 */
- (void)onPlayerBufferingUpdate:(int)progress player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 缓冲完成(buffer loading完成，可以继续播放)
 */
- (void)onPlayerBufferingComplete:(QHVCPlayer *_Nonnull)player
{
    [self.loadingActivityIndicator setHidden:YES];
    [self.loadingActivityIndicator stopAnimating];
    self.isPlayerBuffering = NO;
    if (self.testIsPlayed == NO)
    {
        self.testIsPlayed = YES;
        self.testDateBufferFirstComplete = [NSDate date];
        [self calculateCostDate];
    }
    if (self.testDateBufferingBegin != nil) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - [self.testDateBufferingBegin timeIntervalSince1970];
        NSString *seekCostTimeText = [NSString stringWithFormat:@"缓冲耗时:%f",interval];
        [self appendPerformanceTextIfNeed:seekCostTimeText];
        self.testDateBufferingBegin = nil;
    }
}

/**
 播放进度回调
 
 @param progress 播放进度
 */
- (void)onPlayerPlayingProgress:(CGFloat)progress player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 测试用
 
 @param mediaInfo 视频详细参数
 */
- (void)onplayerPlayingUpdatingMediaInfo:(NSDictionary *_Nullable)mediaInfo player:(QHVCPlayer *_Nonnull)player
{
    if ([QHVCGVConfig sharedInstance].shouldShowPerformanceInfo) {
        self.testSampleRate = [QHVCToolUtils getIntFromDictionary:mediaInfo key:@"sample_rate" defaultValue:0];
    }

}

/**
 * 拖动操作缓冲完成
 */
- (void)onPlayerSeekComplete:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 * 播放器错误回调
 *
 * @param error       错误类型
 * @param extraInfo   额外的信息
 */
- (void)onPlayerError:(QHVCPlayerError) error extra:(QHVCPlayerErrorDetailedInfo)extraInfo player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 * 播放状态回调
 *
 * @param info  参见状态信息枚举
 * @param extraInfo 扩展信息
 */
- (void)onPlayerInfo:(QHVCPlayerStatus)info extra:(NSString * _Nullable)extraInfo player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 码率切换成功
 
 @param index 播放index
 */
- (void)onPlayerSwitchResolutionSuccess:(int)index player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 码率切换失败
 
 @param errorMsg errorMsg description
 */
- (void)onPlayerSwitchResolutionFailed:(NSString *_Nullable)errorMsg player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 主播切入后台
 */
- (void)onPlayerAnchorInBackground:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 系统音量回调
 
 @param volume 系统音量
 */
- (void)onPlayerSystemVolume:(float)volume
{
    
}

/**
 音频音高回调
 @param volume 大小
 */
- (void)audioPitch:(int)volume player:(QHVCPlayer *_Nonnull)player
{
    
}

/**
 接收自定义透传数据
 @param data 自定义数据
 */
- (void)onUserData:(NSData *_Nullable)data
{
    
}


#pragma mark - QHVCPlayerAdvanceDelegate相关实现 -

- (void)onPlayerNetStats:(long)dvbps dabps:(long)dabps dvfps:(long)dvfps dafps:(long)dafps fps:(long)fps bitrate:(long)bitrate player:(QHVCPlayer *)player
{
    NSString *text = [NSString stringWithFormat:@"dvbps:%ld    dabps:%ld   \ndvfps:%ld  sample_rate:%d   fps:%ld   \nbitrate:%ld",dvbps,dabps,dvfps,_testSampleRate,fps,bitrate];
    _tvBPS.text = text;
}

- (void)onPlayerPreviewFinished:(QHVCPlayer *)player
{
    
}

#pragma mark - 卡尺相关实现 -
-(void)setupRecordRuler:(NSArray<QHVCNetGodSeesRecordTimeline *> *)data
{
    if(_recordRulerView)
    {
        [_recordRulerView removeFromSuperview];
        _recordRulerView = nil;
    }
    // 变速区域
    _recordRulerView = [[LZDividingRulerView alloc] initWithFrame:CGRectMake(0, 0, kQHVCScreenWidth, kQHVCGVWatchRecordVC_RulerView_H)];
    _recordRulerView.backgroundColor = [QHVCToolUtils colorWithHexString:@"F0F0F0"];
    [self.view addSubview:_recordRulerView];
    [_recordRulerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dateDisplayView.mas_bottom).offset(27);
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(@120);
    }];
    
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfigFactory configWithType:QHVCGVRulerTimeConfigTenMinute];
    _recordRulerView.timePrecision = config.timePrecision;
    _recordRulerView.minValue = config.minValue;
    _recordRulerView.maxValue = config.maxValue;
    _recordRulerView.lineSpace = config.lineSpace;
    _recordRulerView.lineWidth = config.lineWidth;
    _recordRulerView.scalesCountBetweenScaleText = config.scalesCountBetweenScaleText;
    _recordRulerView.scalesCountBetweenLargeLine = config.scalesCountBetweenLargeLine;
    _recordRulerView.delegate = self;
    
    // 后续将rulerView里面的其他属性 剥离到Config中。 这部分原始代码后续重构
    _recordRulerView.isScrollEnable = YES;
    _recordRulerView.isShowBothEndsOfGradient = NO;
    //    rulerView.isShowCurrentValue = YES;
    _recordRulerView.isShowScaleText = YES;
    _recordRulerView.isShowIndicator = YES;
    _recordRulerView.isShouldAdsorption = NO;
    _recordRulerView.isShouldHighlightText = YES;
    _recordRulerView.isShowBottomLine = YES;
    
    _recordRulerView.unitValue = 1;
    _recordRulerView.defaultValue = [QHVCTool surplusIntervalThatDayFromUTCInterval:_currentSeekTime] / _recordRulerView.timePrecision;
    _recordRulerView.defaultScale = 15;
    _recordRulerView.largeLineHeight = 10;
    _recordRulerView.smallLineHeight = 6;
    _recordRulerView.scaleTextLargeLineSpace = 3;
    
    _recordRulerView.largeLineColor = [UIColor lightGrayColor];
    _recordRulerView.smallLineColor = [UIColor lightGrayColor];
    
    [_recordRulerView updateRuler];
    
    
    _recordRulerView.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        _recordRulerView.alpha = 1;
    }];
    
    NSMutableArray *array = [NSMutableArray new];
    for (QHVCNetGodSeesRecordTimeline *time in data) {
        NSTimeInterval startInterval = [QHVCTool surplusIntervalThatDayFromUTCInterval:time.startMS];
        NSDictionary *dict = @{@"start":@(startInterval),@"duration":@(time.durationMS/1000)};
        [array addObject:dict];
    }
    _recordRulerView.times = array;
    
    [self setupRulerPrecisionSlider];
}

- (void)setupRulerPrecisionSlider {
    if (self.rulerSlider != nil) {
        [self.rulerSlider removeFromSuperview];
    }
    self.rulerSlider = [UISlider new];
    _rulerSlider.minimumValue = 0;
    _rulerSlider.maximumValue = 100;
    _rulerSlider.value = 50;
    [_rulerSlider setMinimumTrackTintColor:[QHVCToolUtils colorWithHexString:@"48A3FD"]];
    [_rulerSlider setMaximumTrackTintColor:[QHVCToolUtils colorWithHexString:@"999999"]];
    [_rulerSlider setThumbImage:kQHVCGetImageWithName(@"godview_ruler_slider_dot") forState:UIControlStateNormal];
    [self.view addSubview:_rulerSlider];
    [_rulerSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_recordRulerView);
        make.width.equalTo(@(kQHVCGVWatchRecordVC_Slider_W));
        make.height.equalTo(@(kQHVCGVWatchRecordVC_Slider_H));
        make.top.equalTo(_recordRulerView.mas_bottom).offset(kQHVCGVWatchRecordVC_Slider_MarginTop);
    }];
    
    [_rulerSlider addTarget:self action:@selector(rulerPrecisionSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [_rulerSlider addTarget:self action:@selector(rulerPrecisionSliderEditBeign:) forControlEvents:UIControlEventTouchDown];
    [_rulerSlider addTarget:self action:@selector(rulerPrecisionSliderEditEnd:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)rulerPrecisionSliderEditBeign:(UISlider *)slider {
    self.isSliderEditing = YES;
}
- (void)rulerPrecisionSliderEditEnd:(UISlider *)slider {
    self.isSliderEditing = NO;
    
}

- (void)rulerPrecisionSliderValueChange:(UISlider *)slider {
    QHVCGVRulerTimeConfig *config = [QHVCGVRulerTimeConfigFactory configWithPrecisionPercent:slider.value];
    _recordRulerView.timePrecision = config.timePrecision;
    _recordRulerView.minValue = config.minValue;
    _recordRulerView.maxValue = config.maxValue;
    _recordRulerView.lineSpace = config.lineSpace;
    _recordRulerView.lineWidth = config.lineWidth;
    _recordRulerView.defaultValue = [QHVCTool surplusIntervalThatDayFromUTCInterval:_currentSeekTime] / _recordRulerView.timePrecision;
    _recordRulerView.scalesCountBetweenScaleText = config.scalesCountBetweenScaleText;
    _recordRulerView.scalesCountBetweenLargeLine = config.scalesCountBetweenLargeLine;
    [_recordRulerView updateRuler];
}

/**
 * 根据卡尺停留点，找到可用的seek时间戳
 * 原则：
 1. 卡尺停留点落在某个timeline的 start ~ start+duration区间为有效，直接返回卡尺停留点utc时间戳
 2. 卡尺停留在空白区域，如果卡尺向右滚动的，则返回右侧最近的可用start，否则返回左边最近的可用start
 *
 * @param expectSeekTime 检索的目标seekTime(期望的seekTime)
 * @param searchDirection 检索方向
 * @return 播放器需要seek的UTC时间戳
 */
- (NSUInteger)searchClosestSeekTime:(NSUInteger)expectSeekTime searchDirection:(QHVCGVSeekTimeSearchDirection)searchDirection {
    if (searchDirection == QHVCGVSeekTimeSearchDirectionBoth) {
        // 双向检索，取差值最小的
        NSUInteger left = [self searchClosestSeekTime:expectSeekTime searchDirection:QHVCGVSeekTimeSearchDirectionLeft];
        NSUInteger right = [self searchClosestSeekTime:expectSeekTime searchDirection:QHVCGVSeekTimeSearchDirectionRight];
        if (expectSeekTime - left < right - expectSeekTime) {
            return left;
        }
        else {
            return right;
        }
    }
    
    NSArray *recordTimelines = [_currentSelectDayDataDict objectForKey:_currentSelectDay];
    NSDate *date = [QHVCTool getDateByString:_currentSelectDay format:@"yyyy-MM-dd"];
    
    // 当天的起始UTC时间戳
    NSTimeInterval selectDayInterval = [date timeIntervalSince1970];
    
    NSUInteger lastLessThanExpect = selectDayInterval;
    for (QHVCNetGodSeesRecordTimeline *timeline in recordTimelines) {
        // 1.优先查找落在可用区间
        if (timeline.startMS <= expectSeekTime && expectSeekTime < timeline.startMS + timeline.durationMS) {
            return (NSUInteger)expectSeekTime;
        }
        // 2. 如果向右检索 遇到第一个大于停留点的start，则1中的情况不会存在，直接返回这个start（右侧最近）
        if (timeline.startMS > expectSeekTime && searchDirection == QHVCGVSeekTimeSearchDirectionRight) {
            return timeline.startMS;
        }
        // 3. 向左检索，第一次遇到大于停留点的时候，返回上一个start（左侧最近）
        if (timeline.startMS > expectSeekTime && searchDirection == QHVCGVSeekTimeSearchDirectionLeft) {
            // 向左滑动 第一个timeline.start就大于expectSeekInterval,说明左边没有可用，则返回timeline.start
            if (lastLessThanExpect == selectDayInterval) {
                return timeline.startMS;
            }
            return lastLessThanExpect;
        }
        lastLessThanExpect = timeline.startMS;
    }
    // 4. 如果右侧没有大于停留点的。等待循环结束后，会返回最后一个小于停留点的timeline.start（左侧最近）
    return lastLessThanExpect;
}

/**
 * 返回从timestamp倒退seconds后，可用的时间戳。
 *
 * 1. 如果timestamp减去seconds后，仍处在timestamp的时间区域，则直接返回减后的时间戳
 * 2. 如果减去seconds后跳出了timestamp所在的时间区域。 而timestamp所在的时间区域是当天第一个时间区域，则返回这个时间区域的start
 * 3. 如果减去seconds后跳出timestamp所在的时间区域，并且timestamp所在的时间区域前面还有时间区域，则返回前面时间区域的start
 */
- (NSUInteger)backwardSeconds:(CGFloat)seconds fromTimestamp:(NSUInteger)timestamp {
    NSArray<QHVCNetGodSeesRecordTimeline *>* timeLineArray = _currentSelectDayDataDict[_currentSelectDay];
    if (timeLineArray.count < 0) {
        return _currentSeekTime;
    }
    // 最终定位的时间戳
    __block NSUInteger finallyTimestamp = _currentSeekTime;
    // 期望后退到的时间点
    NSUInteger expectBackwardTimestamp = timestamp - (NSUInteger)(seconds * 1000);
    [timeLineArray enumerateObjectsUsingBlock:^(QHVCNetGodSeesRecordTimeline * _Nonnull timeline, NSUInteger idx, BOOL * _Nonnull stop) {
        // 找到timestamp在timeline中的位置
        if (timeline.startMS <= timestamp && timestamp <= (timeline.startMS + timeline.durationMS)) {
            // 倒退n秒后，仍在当前区间。 则直接返回倒退后的时间戳expectBackwardTimestamp
            if (timeline.startMS <= expectBackwardTimestamp && expectBackwardTimestamp <= timeline.startMS + timeline.durationMS) {
                finallyTimestamp = expectBackwardTimestamp;
                *stop = YES;
                return ;
            }
            // 倒退n秒后 跳出区间。如果当前区间是第一个，则返回当前区间的start
            if (idx == 0) {
                finallyTimestamp = timeline.startMS;
                *stop = YES;
                return;
            }
            // 返回上一个区间的start
            QHVCNetGodSeesRecordTimeline *lastTimeline = timeLineArray[idx - 1];
            finallyTimestamp = lastTimeline.startMS;
            *stop = YES;
            return;
        }
    }];
    return finallyTimestamp;
}

#pragma mark - LZDividingRulerViewDelegate
- (void)rulerViewWillBeginDragging {
    self.isRulerViewScrolling = YES;
}

- (void)rulerView:(LZDividingRulerView *)rulerView didScrollAtSeconds:(NSInteger)seconds {
    if (self.currentSelectDay != nil) {
        NSDate *dateToday = [QHVCTool getDateByString:self.currentSelectDay format:@"yyyy-MM-dd"];
        NSTimeInterval selectDayInterval = [dateToday timeIntervalSince1970];
        NSUInteger currentSeconds = (NSUInteger)selectDayInterval + seconds;
        NSString *currentTime = [QHVCTool getTimeStringBySecond:currentSeconds format:@"yyyy-MM-dd HH:mm:ss"];
        [_dateDisplayView updateTitle:currentTime];
    }
    else {
        // QHVCTool 工具函数是+8时区  只能表示到1970-01-01 08:00:00  时间轴
        // 是从00:00到24:00 所以1970-01-01需要用0时区来处理
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *title = [df stringFromDate:date];
        [_dateDisplayView updateTitle:title];
    }
}

- (void)rulerView:(LZDividingRulerView *)rulerView didEndScrollingAtSeconds:(NSInteger)seconds direction:(LZDividingRulerViewScorllDirection)scrollDirection {
    if (self.isSliderEditing) {
        self.isRulerViewScrolling = NO;
        return;
    }
    if (self.currentSelectDay ==  nil) {
        return;
    }
    
    QHVCGVSeekTimeSearchDirection searchDirection = QHVCGVSeekTimeSearchDirectionRight;
    if (scrollDirection == LZDividingRulerViewScorllDirectionLeft) {
        searchDirection = QHVCGVSeekTimeSearchDirectionLeft;
    }
    
    NSDate *selectDate = [QHVCTool getDateByString:_currentSelectDay format:@"yyyy-MM-dd"];
    NSTimeInterval selectDayInterval = [selectDate timeIntervalSince1970];
    // 卡尺停留点的UTC时间戳
    NSTimeInterval expectSeekTime = (selectDayInterval + seconds) * 1000;
    
    NSUInteger seekTime = [self searchClosestSeekTime:expectSeekTime searchDirection:searchDirection];
    self.currentSeekTime = seekTime;
    rulerView.currentValue = [QHVCTool surplusIntervalThatDayFromUTCInterval:self.currentSeekTime] / rulerView.timePrecision;
    if (self.didClickPlay) {
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesRecordSeek:_sessionId timeStamp:self.currentSeekTime];
        if (self.playButton.isSelected == NO) {
            [self.playButton setSelected:YES];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isRulerViewScrolling = NO;
    });
}

#pragma mark - 测试相关
- (void)calculateCostDate
{
    NSString *text1 = [NSString stringWithFormat:@"开屏总耗时:%f",[self.testDateBufferFirstComplete timeIntervalSince1970] - [self.testDateViewDidLoad timeIntervalSince1970]];
    NSString *text2 = [NSString stringWithFormat:@"获取卡录时间线耗时:%f",[self.testDateGetRecordTime timeIntervalSince1970] - [self.testDateViewDidLoad timeIntervalSince1970]];
    NSString *text3 = [NSString stringWithFormat:@"2.获取时间线到开屏耗时:%f",[self.testDateBufferFirstComplete timeIntervalSince1970] - [self.testDateGetRecordTime timeIntervalSince1970]];
    [self appendPerformanceTextIfNeed:text1];
    [self appendPerformanceTextIfNeed:text2];
    [self appendPerformanceTextIfNeed:text3];
}

- (void)appendPerformanceTextIfNeed:(NSString *)text {
    if ([QHVCGVConfig sharedInstance].shouldShowPerformanceInfo == NO)
    {
        return;
    }
    runOnMainQueueWithoutDeadlocking(^{
        NSString *textRet = [_tvPerformanceInfo.text stringByAppendingFormat:@"\n%@",text];
        _tvPerformanceInfo.text = textRet;
        [_tvPerformanceInfo scrollRangeToVisible:NSMakeRange(textRet.length - 1, 1)];
    });
}

@end

