//
//  QHVCGVWatchLivingViewController.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVWatchLivingViewController.h"
#import "QHVCGVDeviceModel.h"
#import "QHVCGVDefine.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGVCloudRecordViewModel.h"
#import "QHVCGVFunctionBtn.h"
#import "QHVCGVWatchRecordViewController.h"
#import "QHVCGVSpeakBoardView.h"
#import <QHVCNetKit/QHVCNetKit.h>
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGodViewLocalManager.h"
#import <QHVCPlayerKit/QHVCPlayerKit.h>
#import "QHVCGVConfig.h"
#import "QHVCGVSignallingManager.h"
#import "QHVCGVInteractiveManager.h"
#import "QHVCGVUserSystem.h"
#import "QHVCToast.h"
#import "UIView+Toast.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIView+QHVCGVGodViewCustom.h"
#import "QHVCGVStreamSecureManager.h"
#import "QHVCGVRTCVideoView.h"
#import "QHVCGVContainerView.h"
#import "QHVCGSCloudRecordListViewController.h"
#import "QHVCGSCloudRecordCell.h"
#import "QHVCGVCloudRecordModel.h"
#import "QHVCGSCloudRecordFlowLayout.h"
#import "QHVCPlayerViewController.h"
#import "QHVCHUDManager.h"
#import "QHVCLogger.h"
#import "QHVCGSExtendViewController.h"

// 播放视频的画布
#define kQHVCGVWatchLivingVC_PlayView_H                    (220.0f * kQHVCScreenScaleTo6)
// 视频层
#define kQHVCGVWatchLivingVC_VideosView_H                  (220.0f * kQHVCScreenScaleTo6)
// 视频控件层
#define kQHVCGVWatchLivingVC_VideoControlsView_H           (220.0f * kQHVCScreenScaleTo6)
// 视频加载的loading
#define kQHVCGVWatchLivingVC_Loading_W                     (37.0f)
#define kQHVCGVWatchLivingVC_Loading_H                     (37.0f)
// 指标日志面板
#define kQHVCGVWatchLivingVC_PerformanceLog_W               (160.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_PerformanceLog_H               (130.0f * kQHVCScreenScaleTo6)
// 播放按钮
#define kQHVCGVWatchLivingVC_BtnPlay_W                      (40.0f)
#define kQHVCGVWatchLivingVC_BtnPlay_H                      (40.0f)
// 全屏按钮
#define kQHVCGVWatchLivingVC_BtnFullScreen_W               (28.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnFullScreen_H               (28.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnFullScreen_MarginRight     (15.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnFullScreen_MarginBottom    (9.0f * kQHVCScreenScaleTo6)
// CollectionView的headerView
//#define kQHVCGVWatchLivingVC_TableHeaderView_H             (134.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_TableHeaderView_H             (145.0f * kQHVCScreenScaleTo6)
// 功能面板
#define kQHVCGVWatchLivingVC_FunctionBoard_H               (104.0f * kQHVCScreenScaleTo6)
// 功能区文案label
#define kQHVCGVWatchLivingVC_LabFunctionArea_W             (150.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_LabFunctionArea_H             (19.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_LabFunctionArea_MarginLeft    (14.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_LabFunctionArea_MarginTop     (7.0f * kQHVCScreenScaleTo6)
// "查看卡录"按钮
#define kQHVCGVWatchLivingVC_BtnWatchRecord_W              (70.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnWatchRecord_H              (38.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnWatchRecord_MarginBottom   (18.6f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnWatchRecord_MarginLeft     (70.6f * kQHVCScreenScaleTo6)
// "对讲"按钮
#define kQHVCGVWatchLivingVC_BtnSpeak_W                    (70.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnSpeak_H                    (38.0f * kQHVCScreenScaleTo6)
// "功能开发中"按钮
#define kQHVCGVWatchLivingVC_BtnDeveloping_W               (70.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnDeveloping_H               (38.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_BtnDeveloping_MarginRight     (70.0f * kQHVCScreenScaleTo6)
// 分割线
#define kQHVCGVWatchLivingVC_LineSeparator_H               (7.0f * kQHVCScreenScaleTo6)
// "云录像"文案
#define kQHVCGVWatchLivingVC_LabRecord_W                   (100.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_LabRecord_H                   (20.0f * kQHVCScreenScaleTo6)
#define kQHVCGVWatchLivingVC_LabRecord_MarginLeft          (14.0f * kQHVCScreenScaleTo6)
// collectionView
#define kQHVCGVWatchLivingVC_CollectionViewMarginTop            (7.0f * kQHVCScreenScaleTo6 + kQHVCGVWatchLivingVC_PlayView_H)

// 文案
static NSString * const kQHVCGVWatchLivingVC_FunctionAreaText   = @"功能区";
static NSString * const kQHVCGVWatchLivingVC_WatchRecordText    = @"查看卡录";
static NSString * const kQHVCGVWatchLivingVC_SpeakText          = @"对讲";
static NSString * const kQHVCGVWatchLivingVC_DevelopingText     = @"功能开发中";
static NSString * const kQHVCGVWatchLivingVC_RecordText         = @"云录像";
static NSString * const kQHVCGVWatchLivingVC_AllRecordText      = @"全部录像";
static NSString * const kQHVCGWatchLivingVC_HUD_LoadingText     = @"Loading...";

// 常量
static NSString * const kQHVCGVWatchLivingCellReuseIdentifier        =  @"QHVCGVWatchLivingCell";
static NSString * const kQHVCGVWatchLivingHeaderViewReuseIdentifier  =  @"QHVCGVWatchLivingCollectionViewHeader";
// 直播界面第一次展示loading需要延迟的时间
static CGFloat const kQHVCGVWatchLivingFirstShowLoadingDelay    = 0.5;


@interface QHVCGVWatchLivingViewController () <UICollectionViewDelegate, UICollectionViewDataSource,QHVCGodViewLocalManagerDelegate, QHVCPlayerDelegate, QHVCPlayerAdvanceDelegate, QHVCGVInteractiveAutomationDelegate,QHVCGVSpeakBoardViewDelegate,QHVCGSCloudRecordCellDelegate>
{
    QHVCPlayer *_player;
    NSString* _sessionId;
    NSString* _playerUrl;
}
@property (nonatomic,strong) UIView *playerView;
/// 视频面板 包含：播放的视频 RTC通话的视频等
@property (nonatomic,strong) UIView *videosView;
/// 视频控件面板 包含：播放按钮、全屏按钮、loading等
@property (nonatomic,strong) QHVCGVContainerView *videoControlsView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) QHVCGVCloudRecordViewModel *watchLivingViewModel;
@property (nonatomic,strong) QHVCGVSpeakBoardView *speakBoardView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingActiveIndicator;
@property (nonatomic,strong) UIButton *btnFullScreen;
@property (nonatomic,assign) BOOL isFullScreen;
/// 重新播放按钮，平时隐藏，在sessionId崩溃时显示，用户点击后创建新的session
@property (nonatomic,strong) UIButton *btnReplay;
/// 功能区的对接按钮
@property (nonatomic,strong) QHVCGVFunctionBtn *speakBtn;
@property (nonatomic,strong) UIView *collectionHeaderView;
/// 前往卡录界面、全部云录界面、播放云录界面等，标记为需要恢复，则会在viewWillAppear时，统一恢复直播。（第一次进入直播界面，不在viewWillAppear而在viewDidLoad是为了开屏速度更快）
@property (nonatomic,assign) BOOL isNeedResumePlay;

// -------------------- 功能优化 ------------------
/// 第一次开始缓冲的flag,用于开屏loading优化
@property (nonatomic,assign) BOOL isNotFirstBufferingFlag;
/// 开屏占位图
@property (nonatomic,strong) UIImageView *ivPlaceHolder;

// ----------------- 指标测试用的时间 start-------------
/// 加载界面
@property (nonatomic,strong) NSDate *testDateViewDidLoad;
/// buffer第一次缓冲完成
@property (nonatomic,strong) NSDate *testDateBufferFirstComplete;
/// 是否播放过 用于统计第一次缓冲完成的时间
@property (nonatomic,assign) BOOL testIsPlayed;
/// 开始缓冲的时间
@property (nonatomic,strong) NSDate *testDateBufferingBegin;
/// 展示性能指标
@property (nonatomic,strong) UITextView *tvPerformanceInfo;
/// 码率
@property (nonatomic,strong) UITextView *tvVideoInfo;
/// 采样率
@property (nonatomic,assign) int testSampleRate;
/// ----------------- 指标测试用的时间 end --------------


@end

@implementation QHVCGVWatchLivingViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setupBackBarButton];
    
    if (self.isNeedResumePlay) {
        self.testDateViewDidLoad = [NSDate date];
        self.testIsPlayed = NO;
        self.isNotFirstBufferingFlag = NO;
        self.btnReplay.hidden = YES;
        [self prepareLive];
    }
    
    [self refreshVideoData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.testDateViewDidLoad = [NSDate date];
    [self initViews];
    [self subscribeRoom];
    [self prepareLive];
}

#pragma mark - UI
- (void)initViews
{
    self.navigationItem.title = self.deviceModel.name;
    self.view.backgroundColor = [QHVCToolUtils colorWithHexString:@"F0F0F0"];
    [self setupBackBarButton];
    
    // 视频面板
    self.videosView = [UIView new];
    _videosView.clipsToBounds = YES;
    [self.view addSubview:_videosView];
    [_videosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.width.equalTo(self.view);
        make.height.equalTo(@(kQHVCGVWatchLivingVC_VideosView_H));
    }];
    
    // 播放视频的画布
    self.playerView = [UIView new];
    _playerView.backgroundColor = [UIColor blackColor];
    [_videosView addSubview:_playerView];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_videosView);
    }];
    
    // 占位图 用于首屏优化
    self.ivPlaceHolder = [UIImageView new];
    [_videosView addSubview:_ivPlaceHolder];
    [_ivPlaceHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_videosView);
    }];
    [_ivPlaceHolder setImageWithURL:[NSURL URLWithString:_deviceModel.converImg] placeholderImage:kQHVCGetImageWithName(@"godsees_camera_default")];
    
    
    // 视频控件面板
    self.videoControlsView = [QHVCGVContainerView new];
    _videoControlsView.clipsToBounds = YES;
    [self.view addSubview:_videoControlsView];
    [_videoControlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.width.equalTo(self.view);
        make.height.equalTo(@(kQHVCGVWatchLivingVC_VideoControlsView_H));
    }];
    
    // 视频加载loading
    self.loadingActiveIndicator = [UIActivityIndicatorView new];
    [_videoControlsView addSubview:_loadingActiveIndicator];
    [_loadingActiveIndicator setHidden:YES];
    [_loadingActiveIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_videoControlsView);
        make.width.height.equalTo(@(kQHVCGVWatchLivingVC_Loading_W));
    }];
    
    self.btnFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnFullScreen addTarget:self action:@selector(btnFullScreenClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnFullScreen setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_fullscreen") forState:UIControlStateNormal];
    [_videoControlsView addSubview:_btnFullScreen];
    [_btnFullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchLivingVC_BtnFullScreen_W));
        make.height.equalTo(@(kQHVCGVWatchLivingVC_BtnFullScreen_H));
        make.trailing.equalTo(_videoControlsView).offset(-kQHVCGVWatchLivingVC_BtnFullScreen_MarginRight);
        make.bottom.equalTo(_videoControlsView).offset(-kQHVCGVWatchLivingVC_BtnFullScreen_MarginBottom);
    }];
    
    // 性能面板
    [self setupPerformanceInfoTextView];
    [self setupVideoInfoTextView];
    
    // UICollectionView
    [self setupCollectionView];
    [self setupSpeakBoard];
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
    [_videosView addSubview:_tvPerformanceInfo];
    _tvPerformanceInfo.editable = NO;
    [_tvPerformanceInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.equalTo(_videosView);
        make.width.equalTo(@(kQHVCGVWatchLivingVC_PerformanceLog_W));
        make.height.equalTo(@(kQHVCGVWatchLivingVC_PerformanceLog_H));
    }];
    _tvPerformanceInfo.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}

- (void)setupVideoInfoTextView
{
    if ([QHVCGVConfig sharedInstance].shouldShowPerformanceInfo == NO)
    {
        return;
    }
    self.tvVideoInfo = [UITextView new];
    _tvVideoInfo.textColor = [UIColor whiteColor];
    _tvVideoInfo.layer.cornerRadius = 5;
    [_videosView addSubview:_tvVideoInfo];
    _tvVideoInfo.editable = NO;
    [_tvVideoInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_videosView).offset(-50);
        make.top.equalTo(_tvPerformanceInfo.mas_bottom).offset(5);
        make.width.equalTo(@(kQHVCGVWatchLivingVC_PerformanceLog_W));
        make.height.equalTo(@(75));
    }];
    _tvVideoInfo.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
}


- (void)setupCollectionView
{
    
    QHVCGSCloudRecordFlowLayout *flowLayout = [QHVCGSCloudRecordFlowLayout new];
    flowLayout.headerReferenceSize = CGSizeMake(kQHVCScreenWidth, kQHVCGVWatchLivingVC_TableHeaderView_H);
    // collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[QHVCGSCloudRecordCell class] forCellWithReuseIdentifier:kQHVCGVWatchLivingCellReuseIdentifier];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kQHVCGVWatchLivingHeaderViewReuseIdentifier];
    if (@available(iOS 11, *))
    {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kQHVCGVWatchLivingVC_CollectionViewMarginTop);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
}

- (void)setupSpeakBoard
{
    self.speakBoardView = [QHVCGVSpeakBoardView new];
    self.speakBoardView.delegate = self;
    [self.view addSubview:_speakBoardView];
    self.speakBoardView.alpha = 0;
    [self.speakBoardView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(kQHVCGVWatchLivingVC_CollectionViewMarginTop);
        make.centerX.equalTo(self.view);
    }];
    [_speakBoardView setupUI];
}

- (UIView *)collectionHeaderView
{
    if (_collectionHeaderView != nil)
    {
        return _collectionHeaderView;
    }
    _collectionHeaderView = [UIView new];
    _collectionHeaderView.backgroundColor = [UIColor whiteColor];
    _collectionHeaderView.frame = CGRectMake(0, 0, kQHVCScreenWidth, kQHVCGVWatchLivingVC_TableHeaderView_H);
    
    UIView *functionBoard = [UIView new];
    [_collectionHeaderView addSubview:functionBoard];
    [functionBoard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(_collectionHeaderView);
        make.height.equalTo(@(kQHVCGVWatchLivingVC_FunctionBoard_H));
    }];
    // 功能区文案
    UILabel *labFunction = [UILabel new];
    labFunction.textColor = [QHVCToolUtils colorWithHexString:@"333333"];
    labFunction.font = kQHVCFontPingFangSCMedium(14);
    labFunction.text = kQHVCGVWatchLivingVC_FunctionAreaText;
    [functionBoard addSubview:labFunction];
    [labFunction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(functionBoard).offset(kQHVCGVWatchLivingVC_LabFunctionArea_MarginLeft);
        make.top.equalTo(functionBoard).offset(kQHVCGVWatchLivingVC_LabFunctionArea_MarginTop);
        make.width.equalTo(@(kQHVCGVWatchLivingVC_LabFunctionArea_W));
        make.height.equalTo(@(kQHVCGVWatchLivingVC_LabFunctionArea_H));
    }];
    
    // “查看卡录”按钮
    QHVCGVFunctionBtn *watchRecordBtn = [QHVCGVFunctionBtn buttonWithType:UIButtonTypeCustom];
    [watchRecordBtn addTarget:self action:@selector(watchRecordBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [functionBoard addSubview:watchRecordBtn];
    [watchRecordBtn setupWithIconImage:kQHVCGetImageWithName(@"godview_btn_watch_record") text:kQHVCGVWatchLivingVC_WatchRecordText];
    [watchRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchLivingVC_BtnWatchRecord_W));
        make.height.equalTo(@(kQHVCGVWatchLivingVC_BtnWatchRecord_H));
        make.bottom.equalTo(functionBoard).offset(-kQHVCGVWatchLivingVC_BtnWatchRecord_MarginBottom);
        make.leading.equalTo(functionBoard).offset(kQHVCGVWatchLivingVC_BtnWatchRecord_MarginLeft);
    }];
    
    // "对讲"按钮
    self.speakBtn = [QHVCGVFunctionBtn buttonWithType:UIButtonTypeCustom];
    [_speakBtn addTarget:self action:@selector(speakBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [functionBoard addSubview:_speakBtn];
    _speakBtn.enabled = NO;
    [_speakBtn setupWithIconImage:kQHVCGetImageWithName(@"godview_btn_speak_nor") text:kQHVCGVWatchLivingVC_SpeakText];
    [_speakBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchLivingVC_BtnSpeak_W));
        make.height.equalTo(@(kQHVCGVWatchLivingVC_BtnSpeak_H));
        make.bottom.equalTo(watchRecordBtn);
        make.centerX.equalTo(functionBoard);
    }];
    
    // "功能开发中"按钮
    QHVCGVFunctionBtn *developingBtn = [QHVCGVFunctionBtn buttonWithType:UIButtonTypeCustom];
    [developingBtn addTarget:self action:@selector(developBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [functionBoard addSubview:developingBtn];
    [developingBtn setupWithIconImage:kQHVCGetImageWithName(@"godview_icon_developing") text:kQHVCGVWatchLivingVC_DevelopingText];
    [developingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVWatchLivingVC_BtnDeveloping_W));
        make.height.equalTo(@(kQHVCGVWatchLivingVC_BtnDeveloping_H));
        make.bottom.equalTo(watchRecordBtn);
        make.trailing.equalTo(functionBoard).offset(-kQHVCGVWatchLivingVC_BtnDeveloping_MarginRight);
    }];
    
    // 分割线
    UIView *separatorLine = [UIView new];
    separatorLine.backgroundColor = [QHVCToolUtils colorWithHexString:@"F0F0F0"];
    [_collectionHeaderView addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(functionBoard.mas_bottom);
        make.leading.trailing.equalTo(_collectionHeaderView);
        make.height.equalTo(@(kQHVCGVWatchLivingVC_LineSeparator_H));
    }];
    
    // "云录像"文案
    UILabel *labRecord = [UILabel new];
    labRecord.textColor = [QHVCToolUtils colorWithHexString:@"333333"];
    labRecord.font = kQHVCFontPingFangSCMedium(14);
    labRecord.text = kQHVCGVWatchLivingVC_RecordText;
    [_collectionHeaderView addSubview:labRecord];
    [labRecord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_collectionHeaderView).offset(kQHVCGVWatchLivingVC_LabRecord_MarginLeft);
        make.width.equalTo(@(kQHVCGVWatchLivingVC_LabRecord_W));
        make.height.equalTo(@(kQHVCGVWatchLivingVC_LabRecord_H));
        make.bottom.equalTo(_collectionHeaderView).offset(-9);
    }];
    
    UIImageView *accessoryIcon = [UIImageView new];
    accessoryIcon.image = kQHVCGetImageWithName(@"godness_btn_accessory");
    [_collectionHeaderView addSubview:accessoryIcon];
    [accessoryIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_collectionHeaderView).offset(-15);
        make.centerY.equalTo(labRecord);
        make.width.equalTo(@11);
        make.height.equalTo(@11);
    }];
    
    // 全部录像
    UIButton *btnAllRecord = [UIButton  buttonWithType:UIButtonTypeCustom];
    [btnAllRecord setTitle:kQHVCGVWatchLivingVC_AllRecordText forState:UIControlStateNormal];
    btnAllRecord.titleLabel.font = kQHVCFontPingFangHKRegular(12);
    [btnAllRecord setTitleColor:[QHVCToolUtils colorWithHexString:@"4D4D4D"] forState:UIControlStateNormal];
    [btnAllRecord addTarget:self action:@selector(btnAllRecordClick) forControlEvents:UIControlEventTouchUpInside];
    [_collectionHeaderView addSubview:btnAllRecord];
    [btnAllRecord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(accessoryIcon.mas_leading).offset(-3);
        make.centerY.equalTo(labRecord);
        make.width.equalTo(@50);
        make.height.equalTo(@17);
    }];
    
    return _collectionHeaderView;
}

- (UIButton *)btnReplay
{
    if (_btnReplay)
    {
        return _btnReplay;
    }
    _btnReplay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnReplay setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_play_nor") forState:UIControlStateNormal];
    [_btnReplay addTarget:self action:@selector(btnReplayClick) forControlEvents:UIControlEventTouchUpInside];
    [_videoControlsView addSubview:_btnReplay];
    [_btnReplay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_videoControlsView);
        make.width.height.equalTo(@(kQHVCGVWatchLivingVC_BtnPlay_W));
    }];
    _btnReplay.hidden = YES;
    return _btnReplay;
}

/**
 * 获取用户自己的正在展示的RTC VideoView
 */
- (QHVCGVRTCVideoView *)getUserRTCVideoViewFromVideoAreaView
{
    if ([QHVCGVConfig sharedInstance].isRTCOpenVideo == NO)
    {
        return nil;
    }
    
    for (UIView *subView in _videosView.subviews)
    {
        if ([subView isKindOfClass:[QHVCGVRTCVideoView class]])
        {
            QHVCGVRTCVideoView *videoView = (QHVCGVRTCVideoView *)subView;
            if ([videoView.talkId isEqualToString:[QHVCGVUserSystem sharedInstance].userInfo.talkId])
            {
                return videoView;
            }
        }
    }
    return nil;
}

/**
 * 退出全屏时，适配rtc视频的位置
 *
 * 在全屏时，将rtc视频拖放到屏幕右边缘，其坐标x在恢复竖屏时超出屏幕，需要修正
 */
- (void)adjustRTCVideoViewFrameWhenExitFullScreen
{
    if ([QHVCGVConfig sharedInstance].isRTCOpenVideo == NO)
    {
        return;
    }
    
    CGRect superViewFrame = _videosView.frame;
    for (UIView *subView in _videosView.subviews)
    {
        if ([subView isKindOfClass:[QHVCGVRTCVideoView class]])
        {
            CGRect frame = subView.frame;
            if (frame.origin.x > superViewFrame.size.width - frame.size.width) {
                frame.origin.x = superViewFrame.size.width - frame.size.width;
            }
            if (frame.origin.y > superViewFrame.size.height - frame.size.height) {
                frame.origin.y = superViewFrame.size.height - frame.size.height;
            }
            subView.frame = frame;
        }
    }
}


/**
 *  调整播放视图进入全屏
 */
- (void)adjustPlayerViewToEnterFullScreen
{
    [_btnFullScreen setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_exit_fullscreen") forState:UIControlStateNormal];
    
    UIView *keywindow = [UIApplication sharedApplication].keyWindow;
    
    // 视频层
    [_videosView removeFromSuperview];
    [keywindow addSubview:_videosView];
    [_videosView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keywindow);
        make.height.equalTo(@(kQHVCGVWatchLivingVC_PlayView_H));
        make.top.equalTo(keywindow).offset(kQHVCStatusAndNaviBarHeight);
    }];
    
    // 视频控件层
    [_videoControlsView removeFromSuperview];
    [keywindow addSubview:_videoControlsView];
    [_videoControlsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(keywindow);
        make.height.equalTo(@(kQHVCGVWatchLivingVC_PlayView_H));
        make.top.equalTo(keywindow).offset(kQHVCStatusAndNaviBarHeight);
    }];
    
    
    if (self.btnReplay.hidden == NO)
    {
        _loadingActiveIndicator.hidden = YES;
    }
    
    [keywindow setNeedsLayout];
    [keywindow layoutIfNeeded];
    
    [_videosView setNeedsLayout];
    [_videosView layoutIfNeeded];
    
    [_videoControlsView setNeedsLayout];
    [_videoControlsView layoutIfNeeded];
    
    QHVCGVRTCVideoView *videoView = [self getUserRTCVideoViewFromVideoAreaView];
    if (videoView != nil)
    {
        videoView.transform = CGAffineTransformRotate(_videoControlsView.transform, -M_PI_2);
        CGRect videoViewFrame = videoView.frame;
        videoView.frame = CGRectMake(videoViewFrame.origin.x, videoViewFrame.origin.y, videoViewFrame.size.height, videoViewFrame.size.width);
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [_videosView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(keywindow);
            make.width.equalTo(@(kQHVCScreenHeight));
            make.height.equalTo(@(kQHVCScreenWidth));
        }];
        
        [_videoControlsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(keywindow);
            make.width.equalTo(@(kQHVCScreenHeight));
            make.height.equalTo(@(kQHVCScreenWidth));
        }];
        
        [keywindow setNeedsLayout];
        [keywindow layoutIfNeeded];
        
        [_videosView setNeedsLayout];
        [_videosView layoutIfNeeded];
        _videosView.transform = CGAffineTransformRotate(_videosView.transform, M_PI_2);
        
        [_videoControlsView setNeedsLayout];
        [_videoControlsView layoutIfNeeded];
        _videoControlsView.transform = CGAffineTransformRotate(_videoControlsView.transform, M_PI_2);
 
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }];
}

/**
 * 调整播放视图退出全屏
 */
- (void)adjustPlayerViewToExitFullScreen
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_btnFullScreen setBackgroundImage:kQHVCGetImageWithName(@"godview_btn_fullscreen") forState:UIControlStateNormal];
    
    UIView *keywindow = [UIApplication sharedApplication].keyWindow;
    
    QHVCGVRTCVideoView *videoView = [self getUserRTCVideoViewFromVideoAreaView];
    if (videoView != nil)
    {
        videoView.transform = CGAffineTransformRotate(_videoControlsView.transform, -M_PI_2);
        CGRect videoViewFrame = videoView.frame;
        videoView.frame = CGRectMake(videoViewFrame.origin.x, videoViewFrame.origin.y, videoViewFrame.size.height, videoViewFrame.size.width);
    }
    [UIView animateWithDuration:0.5 animations:^{
        [_videosView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keywindow);
            make.height.equalTo(@(kQHVCGVWatchLivingVC_VideosView_H));
            make.top.equalTo(keywindow).offset(kQHVCStatusAndNaviBarHeight);
        }];
        _videosView.transform = CGAffineTransformRotate(_videosView.transform, -M_PI_2);
        
        [_videoControlsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(keywindow);
            make.height.equalTo(@(kQHVCGVWatchLivingVC_VideoControlsView_H));
            make.top.equalTo(keywindow).offset(kQHVCStatusAndNaviBarHeight);
        }];
        _videoControlsView.transform = CGAffineTransformRotate(_videoControlsView.transform, -M_PI_2);

        [keywindow setNeedsLayout];
        [keywindow layoutIfNeeded];
        
        [_videosView setNeedsLayout];
        [_videosView layoutIfNeeded];
        
        [_videoControlsView setNeedsLayout];
        [_videoControlsView layoutIfNeeded];
        
        [self adjustRTCVideoViewFrameWhenExitFullScreen];
    } completion:^(BOOL finished) {
        [_videosView removeFromSuperview];
        [self.view addSubview:_videosView];
        [_videosView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.width.equalTo(self.view);
            make.height.equalTo(@(kQHVCGVWatchLivingVC_VideosView_H));
        }];
        
        [_videoControlsView removeFromSuperview];
        [self.view addSubview:_videoControlsView];
        [_videoControlsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.width.equalTo(self.view);
            make.height.equalTo(@(kQHVCGVWatchLivingVC_VideosView_H));
        }];
        
        if (self.btnReplay.hidden == NO)
        {
            _loadingActiveIndicator.hidden = YES;
        }
        [self adjustRTCVideoViewFrameWhenExitFullScreen];
        [self.view bringSubviewToFront:_videosView];
        [self.view bringSubviewToFront:_videoControlsView];
    }];
}

- (void)showLoadingActiveIndicator
{
    [self.loadingActiveIndicator setHidden:NO];
    [self.loadingActiveIndicator startAnimating];
}

#pragma mark - UI交互事件
- (void)onBack
{
    [self stopPlayer];
    [[QHVCGodViewLocalManager sharedInstance] setDelegate:nil];
    
    if (self.speakBoardView.rtcStatus != QHVCGVSpeakRTCStatusReady)
    {
        [[QHVCGVInteractiveManager sharedInstance] destory];
    }
    [self unsubscribeRoom];
    
    [[QHVCGVStreamSecureManager sharedManager] setCurrentWatchingSN:nil];
    
    [super onBack];
}

- (void)btnAllRecordClick
{
    // 停止播放
    self.ivPlaceHolder.hidden = NO;
    self.ivPlaceHolder.image = [_playerView takeScreenshot];
    [self stopPlayer];
    [[QHVCGodViewLocalManager sharedInstance] setDelegate:nil];
    
    // 标记为需要恢复播放
    self.isNeedResumePlay =  YES;
    
    QHVCGSCloudRecordListViewController *videoListVC = [[QHVCGSCloudRecordListViewController alloc] initWithNibName:@"QHVCGSCloudRecordListViewController" bundle:nil];
    videoListVC.deviceModel = _deviceModel;
    videoListVC.dataSource = _dataSource;
    [self.navigationController pushViewController:videoListVC animated:YES];
}

- (void)watchRecordBtnClicked
{
    // 停止播放
    self.ivPlaceHolder.image = [_playerView takeScreenshot];
    self.ivPlaceHolder.hidden = NO;
    [self stopPlayer];
    [[QHVCGodViewLocalManager sharedInstance] setDelegate:nil];
    
    // 标记为需要恢复播放
    self.isNeedResumePlay =  YES;
    
    QHVCGVWatchRecordViewController* watchRecord = [QHVCGVWatchRecordViewController new];
    watchRecord.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:watchRecord animated:YES];
}

- (void)speakBtnClicked
{
    // 显示对讲面板
    [self.speakBoardView showWithAnimation];
}

/**
 * 对讲面板上的“对讲”按钮按下， 开始讲话
 */
- (void)speakBoardViewWillSpeakStart
{
    [self mutePlayer:YES];
    [[QHVCGVInteractiveManager sharedInstance] startAutomaticConversation:self];
}

/**
 * 对讲面板上的“对讲”按钮按下，结束讲话
 */
- (void)speakBoardViewWillSpeakStop
{
    [[QHVCGVInteractiveManager sharedInstance] stopAutomaticConversation];
}

/**
 * 对讲面板将要关闭
 */
- (void)speakBoardViewWillClose
{
    if (self.speakBoardView.rtcStatus != QHVCGVSpeakRTCStatusReady)
    {
        [[QHVCGVInteractiveManager sharedInstance] destory];
        [self mutePlayer:NO];
    }
}

- (void)developBtnClicked
{
    QHVCGSExtendViewController* viewController = [QHVCGSExtendViewController new];
    viewController.deviceModel = _deviceModel;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)btnFullScreenClick:(UIButton *)btn
{
    if (self.isFullScreen)
    {
        [self adjustPlayerViewToExitFullScreen];
    } else
    {
        [self adjustPlayerViewToEnterFullScreen];
    }
    self.isFullScreen = !_isFullScreen;
}

/**
 * session断开连接后，播放视图上会显示一个播放按钮，点击调用下面方法 重新创建连接
 */
- (void)btnReplayClick
{
    self.btnReplay.hidden = YES;
    if (_player)
    {
        [self stopPlayer];
    }
    [self prepareLive];
}

#pragma mark - others
- (void)refreshVideoData
{
    QHVC_WEAK_SELF
    [self.watchLivingViewModel refreshCloudRecordListWithSerialNumber:self.deviceModel.bindedSN completion:^(NSArray<QHVCGVCloudRecordModel *> * _Nonnull lists) {
        QHVC_STRONG_SELF
        self.dataSource = lists;
        [self.collectionView reloadData];
    }];
}

- (QHVCGVCloudRecordViewModel *)watchLivingViewModel
{
    if (_watchLivingViewModel == nil)
    {
        _watchLivingViewModel = [QHVCGVCloudRecordViewModel new];
    }
    return _watchLivingViewModel;
}

/**
 * 订阅设备所在房间
 */
- (void)subscribeRoom
{
    [[QHVCGVSignallingManager sharedInstance] subscribe:_deviceModel.bindedSN];
}

/**
 * 取消订阅设备所在的房间
 */
- (void)unsubscribeRoom
{
    [[QHVCGVSignallingManager sharedInstance] unsubscribe:self.deviceModel.bindedSN];
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCGSCloudRecordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQHVCGVWatchLivingCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    QHVCGVCloudRecordModel *recordModel = self.dataSource[indexPath.row];
    [cell setupWithImageName:recordModel.thumbnail indexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 直播界面只展示4个
    return _dataSource.count > 4 ? 4 : _dataSource.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (![kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        return [UICollectionReusableView new];
    }
    UICollectionReusableView *rsView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kQHVCGVWatchLivingHeaderViewReuseIdentifier forIndexPath:indexPath];
    if (self.collectionHeaderView.superview == nil)
    {
        [rsView addSubview:self.collectionHeaderView];
    }
    return rsView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    // 停止播放
    self.ivPlaceHolder.hidden = NO;
    self.ivPlaceHolder.image = [_playerView takeScreenshot];
    [self stopPlayer];
    [[QHVCGodViewLocalManager sharedInstance] setDelegate:nil];
    
    // 标记为需要恢复播放
    self.isNeedResumePlay = YES;
    
    QHVCGVCloudRecordModel *model = _dataSource[indexPath.row];
    NSDictionary *config = @{
                             kQHVCPlayerConfigKeyBid:[QHVCGlobalConfig sharedInstance].appId,
                             kQHVCPlayerConfigKeyCid:[QHVCGlobalConfig sharedInstance].appId,
                             kQHVCPlayerConfigKeyUrl:model.url ?: @"",
                             kQHVCPlayerConfigKeyDecodeType:@0,
                             kQHVCPlayerConfigKeyIsOutputPacket:@1,
                             kQHVCPlayerConfigKeyEncryptKey:model.encryptKey
                             };
    QHVCPlayerViewController *pvc = [[QHVCPlayerViewController alloc] initWithPlayerConfig:config];
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - QHVCGSCloudRecordCellDelegate
- (void)cloudRecordCell:(QHVCGSCloudRecordCell *)cloudRecordCell didClickDeleteAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCGVCloudRecordModel *model = _dataSource[indexPath.row];
    QHVC_WEAK_SELF
    
    QHVCHUDManager *hud = [QHVCHUDManager new];
    [hud showLoadingProgressOnView:self.view message:kQHVCGWatchLivingVC_HUD_LoadingText];
    [_watchLivingViewModel deleteCloudRecordWithSerialNumber:_deviceModel.bindedSN recordId:model.recordId completion:^(BOOL isSuccess) {
        [hud hideHud];
        if (isSuccess)
        {
            QHVC_STRONG_SELF
            NSMutableArray *tmpArray = [_dataSource mutableCopy];
            [tmpArray removeObjectAtIndex:indexPath.row];
            self.dataSource = [tmpArray copy];
            [self.collectionView reloadData];
        }
    }];
}

- (void)cloudRecordCell:(QHVCGSCloudRecordCell *)cloudRecordCell didClickMenuIndexPath:(NSIndexPath *)indexPath
{
    // 点击单元格的菜单时，消除其他单元格上的菜单
    NSArray *cells = _collectionView.visibleCells;
    for (QHVCGSCloudRecordCell *cell in cells)
    {
        if (cell != cloudRecordCell)
        {
            [cell hideMenu];
        }
    }
}

#pragma mark - 直播相关 -

- (void) prepareLive
{
    if (_isLocal)
    {
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesNetworkConnectType:QHVC_NET_GODSEES_NETWORK_CONNECT_TYPE_DIRECT_IP];
        [[QHVCGodViewLocalManager sharedInstance] setGodSeesDeviceNetworkAddress:@"360H0700079"
                                                                              ip:@"192.168.0.9"
                                                                            port:2000];
    }
    QHVCGlobalConfig* globalConfig = [QHVCGlobalConfig sharedInstance];
    QHVCGVConfig * config = [QHVCGVConfig sharedInstance];
    [[QHVCGodViewLocalManager sharedInstance] setDelegate:self];
    _sessionId = [NSString stringWithFormat:@"%@_%@_%lld", globalConfig.appId, config.userName, [QHVCToolUtils getCurrentDateByMilliscond]];
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
                                                       sessionType:QHVC_NET_GODSEES_SESSION_TYPE_LIVE
                                                           options:@{kQHVCNetGodSeesOptionsStreamTypeKey:@([config streamType]),kQHVCNetGodSeesOptionsPlayerReceiveDataModelKey:@([config playerReceiveDataModel])}];
    _playerUrl = [[QHVCGodViewLocalManager sharedInstance] getGodSeesPlayUrl:_sessionId];
    [[QHVCGodViewLocalManager sharedInstance] verifyGodSeesBusinessTokenToDevice:_sessionId
                                                                           token:[QHVCGVUserSystem sharedInstance].userInfo.token];
    [self initPlayer];
}

- (void)initPlayer
{
    [QHVCPlayer setLogLevel:(QHVCPlayerLogLevel)[QHVCLogger getLoggerLevel]];
    QHVCGlobalConfig* globalConfig = [QHVCGlobalConfig sharedInstance];
    QHVCGVConfig* config = [QHVCGVConfig sharedInstance];
    int inputStreamValue = [config playerReceiveDataModel] == QHVC_NET_GODSEES_PLAYER_RECEIVE_DATA_MODEL_CALLBACK?1:0;
    _player = [[QHVCPlayer alloc] initWithURL:_playerUrl
                                    channelId:globalConfig.appId
                                       userId:config.userName
                                     playType:QHVCPlayTypeLive
                                      options:@{@"hardDecode":@([config isHardDecode]),@"playMode":@(QHVCPlayModeLowLatency),@"inputStream":@(inputStreamValue)}];
    _player.playerDelegate = self;
    _player.playerAdvanceDelegate = self;
    
    [_player createPlayerView:_playerView];
    [_player setSystemVolumeCallback:YES];
    [_player setSystemVolumeViewHidden:NO];
    [_player prepare];
    if ([[QHVCGVConfig sharedInstance] shouldShowPerformanceInfo])
    {
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

- (void) mutePlayer:(BOOL)mute
{
    if (mute)
    {
        [_player destroyAudioModule];
    }else
    {
        [_player reStartAudioModule];
    }
}

#pragma mark - QHVCGodViewLocalManagerDelegate实现 -

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

- (void) onGodSees:(NSString *)sessionId didMonitorNetworkInfo:(NSString *)info
{
    [self appendPerformanceTextIfNeed:info];
}

- (void) onGodSees:(NSString *)sessionId didError:(QHVCNetGodSeesErrorCode)errorCode
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"onGodsees didError: sessionId = %@, errorCode = %zd",sessionId,errorCode]];
    NSString *errMsg = @"";
    if (errorCode == QHVC_NET_GODSEES_ERROR_SESSION_ID_INVALID)
    {
        errMsg = kQHVC_NET_GODSEES_ERROR_SID_INVALID_TEXT;
    }
    else if (errorCode == QHVC_NET_GODSEES_ERROR_SERIAL_NUMBER_INVALID)
    {
        errMsg = kQHVC_NET_GODSEES_ERROR_SN_INVALID_TEXT;
    }
    else if (errorCode == QHVC_NET_GODSEES_ERROR_TOKEN_INVALID)
    {
        errMsg = kQHVC_NET_GODSEES_ERROR_TOKEN_INVALID_TEXT;
    }
    else if (errorCode == QHVC_NET_GODSEES_ERROR_SESSION_DISCONNECT)
    {
        runOnMainQueueWithoutDeadlocking(^{
            [self stopPlayWhenException];
        });
        errMsg = kQHVC_NET_GODSEES_ERROR_SESSION_NET_BROKEN_TEXT;
    }
    else if(errorCode == QHVC_NET_GODSEES_ERROR_FRAME_DECRYPT_KEY_INVALID)
    {
        errMsg = kQHVC_NET_GODSEES_ERROR_DECRYPT_KEY_INVALID_TEXT;
    }
    errMsg = [errMsg stringByAppendingFormat:@" 错误码:%zd",errorCode];
    runOnMainQueueWithoutDeadlocking(^{
        [QHVCToast makeToast:errMsg];
    });
}

- (void) onGodSees:(NSString *)sessionId didVerifyToken:(NSInteger)status info:(NSString *)info
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"onGodsees didVerifyToken: sessionId = %@, status = %zd, info = %@",sessionId,status,info]];
    if ([_sessionId isEqual:sessionId])
    {
        
        if (status == QHVC_NET_GODSEES_TOKEN_ERROR_NO_ERROR)
        {
            return;
        }
        
        NSString *errMsg = @"";
        if (status == QHVC_NET_GODSEES_TOKEN_ERROR_TokenVerifyFail)
        {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_TokenVerifyFail_TEXT;
        }
        else if (status == QHVC_NET_GODSEES_TOKEN_ERROR_RelayConnectionOverLimit)
        {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_RelayConnectionOverLimit_TEXT;
        }
        else if (status == QHVC_NET_GODSEES_TOKEN_ERROR_RecordConnectionOverLimit)
        {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_RecordConnectionOverLimit_TEXT;
        }
        else if (status == QHVC_NET_GODSEES_TOKEN_ERROR_TotalConnectionOverLimit)
        {
            errMsg = kQHVC_NET_GODSEES_TOKEN_ERROR_TotalConnectionOverLimit_TEXT;
        }
        errMsg = [errMsg stringByAppendingFormat:@" 错误码:%zd",status];
        runOnMainQueueWithoutDeadlocking(^{
            [QHVCToast makeToast:errMsg];
            [self stopPlayWhenException];
        });
    }
    
}

- (void) onGodSeesSignallingSendData:(NSString *)destId data:(NSString *)data
{
    [[QHVCGVSignallingManager sharedInstance] sendMessage:data to:destId];
}

#pragma mark - QHVCPlayerDelegate -

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
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"onPlayerFirstFrameRender mediaInfo:%@",mediaInfo]];
    self.ivPlaceHolder.hidden = YES;
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
    // 开屏第一次 延迟展示
    if (self.isNotFirstBufferingFlag == NO)
    {
        self.isNotFirstBufferingFlag = YES;
        [self performSelector:@selector(showLoadingActiveIndicator) withObject:nil afterDelay:kQHVCGVWatchLivingFirstShowLoadingDelay];
    } else
    {
        [self.loadingActiveIndicator setHidden:NO];
        [self.loadingActiveIndicator startAnimating];
    }
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingActiveIndicator) object:nil];
    _speakBtn.enabled = YES;

    [self.loadingActiveIndicator setHidden:YES];
    [self.loadingActiveIndicator stopAnimating];
    
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

#pragma mark - PlayerAdvanceDelegate -

- (void)onPlayerNetStats:(long)dvbps dabps:(long)dabps dvfps:(long)dvfps dafps:(long)dafps fps:(long)fps bitrate:(long)bitrate player:(QHVCPlayer *)player
{
    NSString *text = [NSString stringWithFormat:@"dvbps:%ld    dabps:%ld   \ndvfps:%ld  sample_rate:%d   fps:%ld   \nbitrate:%ld",dvbps,dabps,dvfps,_testSampleRate,fps,bitrate];
    _tvVideoInfo.text = text;
}

- (void)onPlayerPreviewFinished:(QHVCPlayer *)player
{
    
}

#pragma mark - QHVCGVInteractiveAutomationDelegate -

- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didOccurError:(QHVCITLErrorCode)errorCode
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"interactiveAutomationEngine didOccurError:%ld",(long)errorCode]];
    [_speakBoardView didStopRTC];
    [[QHVCGVInteractiveManager sharedInstance] destory];
    [self mutePlayer:NO];
    [QHVCToast makeToast:[NSString stringWithFormat:@"interactiveAutomationEngine didOccurError QHVCITLErrorCode:%zd",errorCode]];
}

- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didStartAutomaticConversation:(NSString *)channel withUid:(NSString *)uid
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"interactiveAutomationEngine didStartAutomaticConversation channel:%@, uid = %@",channel,uid]];
    [_speakBoardView didStartRTC];
}

- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didStopAutomaticConversation:(NSString *)channel withUid:(NSString *)uid
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"interactiveAutomationEngine didStopAutomaticConversation channel:%@, uid = %@",channel,uid]];
    [[QHVCGVInteractiveManager sharedInstance] destory];
    [self mutePlayer:NO];
    [_speakBoardView didStopRTC];
}

- (void)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didSendingSignalingMessage:(NSString *)message toDestId:(NSString *)destId
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"interactiveAutomationEngine didSendingSignalingMessage destId:%@, toDestId = %@",message,destId]];
    [[QHVCGVSignallingManager sharedInstance] sendMessage:message to:destId];
}

- (UIView *)interactiveAutomationEngine:(QHVCGVInteractiveManager *)engine didCreateViewWithUid:(NSString *)uid
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"interactiveAutomationEngine didCreateViewWithUid: %@",uid]];
    return [self createBroadcasterView:uid];
}

- (UIView *) createBroadcasterView:(NSString *)userId
{
    if ([QHVCToolUtils isNullString:userId] || [userId isEqualToString:_deviceModel.talkId])
    {
        return nil;
    }
    int width = 90;
    int height = 160;
    int startx = 10;
    int starty = 10;
    int endx = self.view.bounds.size.width - width - startx;
    int endy = kQHVCGVWatchLivingVC_PlayView_H - height;
    CGFloat x = [QHVCToolUtils getRandomNumber:startx end:endx];
    CGFloat y = [QHVCToolUtils getRandomNumber:starty end:endy];
    QHVCGVRTCVideoView *videoView = [[QHVCGVRTCVideoView alloc] initWithFrame:CGRectMake(x, y, width, height) talkId:userId];
    [_videosView addSubview:videoView];
    return videoView;
}

#pragma mark - 播放器错误处理
- (void)stopPlayWhenException
{
    // 停止播放器
    [self stopPlayer];
    [_loadingActiveIndicator setHidden:YES];
    self.btnReplay.hidden = NO;
    [_btnReplay.superview bringSubviewToFront:_btnReplay];
}

#pragma mark - 测试相关
- (void)calculateCostDate
{
    NSString *text = [NSString stringWithFormat:@"开屏总耗时:%f",[self.testDateBufferFirstComplete timeIntervalSince1970] -[self.testDateViewDidLoad timeIntervalSince1970]];
    [self appendPerformanceTextIfNeed:text];
}

- (void)appendPerformanceTextIfNeed:(NSString *)text
{
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
