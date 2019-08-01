//
//  QHVCPlayerViewController.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/7.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCRecordPlayerViewController.h"
#import "AppDelegate.h"
#import "QHVCSlider.h"
#import <QHVCPlayerKit/QHVCPlayerKit.h>
#import "QHVCPlayerInfoTableViewCell.h"
#import "md5.h"
#import "AFNetworkReachabilityManager.h"
#import "QHVCHUDManager.h"
#import <AVFoundation/AVFoundation.h>
#import <QHVCNetKit/QHVCNetKit.h>
#import "QHVCGlobalConfig.h"

#define kQHVCPlayerVC_PlayView_H                    (220.0f * kQHVCScreenScaleTo6)


static NSString *kQHVCPlayerConfigKeyBid            = @"bid";
static NSString *kQHVCPlayerConfigKeyCid            = @"cid";
static NSString *kQHVCPlayerConfigKeySN             = @"sn";
static NSString *kQHVCPlayerConfigKeyUrl            = @"url";
static NSString *kQHVCPlayerConfigKeyDecodeType     = @"decode";
static NSString *kQHVCPlayerConfigKeyIsOutputPacket = @"outputPacket";
static NSString *kQHVCPlayerConfigKeyEncryptKey     = @"encryptKey";

static NSString *APP_SIGN = @"";

@interface QHVCRecordPlayerViewController ()<QHVCPlayerDelegate, QHVCPlayerAdvanceDelegate, QHVCSliderDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    UIView *maskView;
    UIView *topView;
    CAGradientLayer *topGradientLayer;
    UIView *bottomView;
    CAGradientLayer *bottomGradientLayer;
    
    UILabel *titleLabel;
    UIView *playerView;
    
    UIButton *playPauseButton;
    UILabel *currentTimeLabel;
    QHVCSlider *playerSlider;
    UILabel *totalTimeLabel;
    UIButton *fullScreenButton;
    UIButton *resolutionButton;
    UIButton *multipleRateButton;
    UIButton *recordButton;
    
    BOOL canVideoRotate;
    BOOL isSliderGliding;
    BOOL isTableViewSlide;
    BOOL playingWhenBackground;
    BOOL willBackground;
    BOOL isLiving;
    
    BOOL isRecording;
    
    QHVCPlayer *_player;
    NSTimer *_hideTopBottomTimer;
    NSTimer *_downloadProgressTimer;
    
    NSString *bid;
    NSString *cid;
    NSString *testUrl;
    BOOL isHardDecode;
    NSString *sn;
    BOOL isOutputPacket;
    NSString *encryptedKey;
    
    long _downstreamTraffic;
    long _fps;
    long _bitrate;
    
    NSInteger resolutionIndex;
    NSInteger multipleRateIndex;
    
    QHVCHUDManager *hudManager;
}

@property (nonatomic, strong) UITableView *mediaInfoTableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation QHVCRecordPlayerViewController

- (instancetype)initWithPlayerConfig:(NSDictionary *)config
{
    if (self == [super init])
    {
        isLiving = NO;
        bid = [config valueForKey:kQHVCPlayerConfigKeyBid];
        cid = [config valueForKey:kQHVCPlayerConfigKeyCid];
        testUrl = [config valueForKey:kQHVCPlayerConfigKeyUrl];
        isHardDecode = [[config valueForKey:kQHVCPlayerConfigKeyDecodeType] boolValue];
        isOutputPacket = [[config valueForKey:kQHVCPlayerConfigKeyIsOutputPacket] boolValue];
        encryptedKey = [config valueForKey:kQHVCPlayerConfigKeyEncryptKey];
        [self initPlayer:NO];
    }
    
    return self;
}

- (instancetype)initWithLivePlayerConfig:(NSDictionary *)config hasAddress:(BOOL)hasAddress
{
    if (self == [super init])
    {
        isLiving = YES;
        bid = [config valueForKey:kQHVCPlayerConfigKeyBid];
        cid = [config valueForKey:kQHVCPlayerConfigKeyCid];
        testUrl = [config valueForKey:kQHVCPlayerConfigKeyUrl];
        isHardDecode = [[config valueForKey:kQHVCPlayerConfigKeyDecodeType] boolValue];
        isOutputPacket = [[config valueForKey:kQHVCPlayerConfigKeyIsOutputPacket] boolValue];
        sn = [config valueForKey:kQHVCPlayerConfigKeySN];
        encryptedKey = [config valueForKey:kQHVCPlayerConfigKeyEncryptKey];
        
        
        if (hasAddress)
        {
            [self initPlayer:YES];
        }
        else
        {
            [self initLivePlayer];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initPlayerView];
    [self initTopView];
    [self initBottomView];
    [self initMediaInfoTableView];
    [self startHideTopBottomTimer];
    [self startDownloadProgressTimer];
    [self addTapGesture];
    [self initNotify];
    
    hudManager = [QHVCHUDManager new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.oriention = UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.oriention = UIInterfaceOrientationMaskPortrait;
}

#pragma mark initPlayer
- (void)initPlayer:(BOOL)living
{
    if (living)
    {
        _player = [[QHVCPlayer alloc] initWithURL:testUrl channelId:cid userId:nil playType:QHVCPlayTypeLive options:@{@"hardDecode":@(isHardDecode)}];
    }
    else
    {
        _player = [[QHVCPlayer alloc] initWithURL:testUrl channelId:cid userId:nil playType:QHVCPlayTypeVod options:@{@"hardDecode":@(isHardDecode),kQHVCPlayerConfigKeyIsOutputPacket:@(isOutputPacket)}];
    }
    _player.playerDelegate = self;
    _player.playerAdvanceDelegate = self;
    
    playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.width * SCREEN_SCALE)];
    [_player createPlayerConstraintView:playerView];
    [_player setSystemVolumeCallback:YES];
    [_player setSystemVolumeViewHidden:NO];

    [_player prepare];
    resolutionIndex = 3;
    multipleRateIndex = 3;
    [_player setAutomaticallySwitchResolution:YES];
}

- (void)initLivePlayer
{
    _player = [[QHVCPlayer alloc] initWithSN:sn channelId:cid userId:@"demoUser" uSign:[self generateSign:APP_SIGN] options:@{@"hardDecode":@(isHardDecode)}];
    _player.playerDelegate = self;
    _player.playerAdvanceDelegate = self;
    playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.width * SCREEN_SCALE)];
    [_player createPlayerView:playerView];
    [_player prepare];
}

- (NSString *)generateSign:(NSString *)_key
{
    NSString *channelTag = @"channel__";
    NSString *appName = cid;
    NSString *snTag = @"sn__";
    NSString *key = _key;
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@%@", channelTag, appName, snTag, sn, key];
    
    gnet::MD5_CTX md5;
    MD5_Init(&md5);
    MD5_Update(&md5, [sign cStringUsingEncoding:NSUTF8StringEncoding], strlen([sign cStringUsingEncoding:NSUTF8StringEncoding]));
    unsigned char result[16];
    MD5_Final(result, &md5);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

#pragma mark PlayerAdvanceDelegate
- (void)onPlayerNetStats:(long)dvbps dabps:(long)dabps dvfps:(long)dvfps dafps:(long)dafps fps:(long)fps bitrate:(long)bitrate player:(QHVCPlayer *)player
{
    _downstreamTraffic = dvbps + dabps;
    _fps = fps;
    _bitrate = bitrate/1024;
}

- (void)onPlayerPreviewFinished:(QHVCPlayer *)player
{
    NSLog(@"previewFinished");
}

#pragma mark PlayerDelegate

- (void)onPlayerOutputPacket:(QHVCPacket)packet
{
    QHVCNetGodSeesFrameDataType frameDataType;
    if (packet.flags == QHVC_PACKET_TYPE_AAC || packet.flags == QHVC_PACKET_TYPE_OPUS)
    {
        frameDataType = QHVC_NET_GODSEES_FRAME_DATA_TYPE_AAC;
    } else if (packet.flags == QHVC_PACKET_TYPE_H264)
    {
        frameDataType = QHVC_NET_GODSEES_FRAME_DATA_TYPE_H264;
    } else if (packet.flags ==  QHVC_PACKET_TYPE_H265)
    {
        frameDataType = QHVC_NET_GODSEES_FRAME_DATA_TYPE_H265;
    }
    [[QHVCNet sharedInstance] decryptGodSeesMediaDataWithSecretKey:encryptedKey
                                                   decryptionRules:QHVC_NET_GODSEES_DECRYPTION_RULES_XOR
                                                     frameDataType:frameDataType
                                                 originalMediaData:packet.pData
                                                originalDataLength:packet.size
                                               decryptedDataLength:&packet.size];
}

//@required
/**
 播放器准备成功回调,在此回调中调用play开始播放
 */
- (void)onPlayerPrepared:(QHVCPlayer *)player
{
    [totalTimeLabel setText:[self formatedTime:[_player getDuration]]];
    [_player play];
    playPauseButton.selected = YES;
    [_player openNetStats:5];
//    [_player setAudioDataOutput:YES];
}

/**
 播放器渲染第一帧
 */
- (void)onPlayerFirstFrameRender:(NSDictionary *)mediaInfo player:(QHVCPlayer *)player
{
    NSString *version = [QHVCPlayer getVersion];//版本号
    NSString *url = testUrl;//播放url
    NSString *resolution = [NSString stringWithFormat:@"%@*%@", [mediaInfo valueForKey:@"width"], [mediaInfo valueForKey:@"height"]];//分辨率
    NSString *bitRate = [mediaInfo valueForKey:@"bitrate"];//码率
    NSString *fps = [mediaInfo valueForKey:@"fps"];//帧率
    NSString *adec_name = [mediaInfo valueForKey:@"adec_name"];//音频格式
    NSString *sample_rate = [mediaInfo valueForKey:@"sample_rate"];//采样率
    NSString *channel = [mediaInfo valueForKey:@"channel"];//音频轨道
    NSString *vdec_name = [mediaInfo valueForKey:@"vdec_name"];//视频编码格式
    NSString *downloadFlow = [self convertSize:_downstreamTraffic];//下行流量
    NSString *currentTime = @"";//已播时长
    NSString *netType = @"";//网络类型
    _dataSource = @[
                    [NSString stringWithFormat:@"版本号：%@", version],
                    [NSString stringWithFormat:@"%@", url],
                    [NSString stringWithFormat:@"分辨率：%@", resolution],
                    [NSString stringWithFormat:@"码率：%@", bitRate],
                    [NSString stringWithFormat:@"帧率：%@", fps],
                    [NSString stringWithFormat:@"音频格式：%@", adec_name],
                    [NSString stringWithFormat:@"采样率：%@", sample_rate],
                    [NSString stringWithFormat:@"音频轨道：%@", channel],
                    [NSString stringWithFormat:@"视频编码格式：%@", vdec_name],
                    [NSString stringWithFormat:@"下行流量：%@", downloadFlow],
                    [NSString stringWithFormat:@"已播时长：%@", currentTime],
                    [NSString stringWithFormat:@"网络类型：%@", netType],
                    ];
    [_mediaInfoTableView reloadData];
}

/**
 播放结束回调
 */
- (void)onPlayerFinish:(QHVCPlayer *)player
{
    [_player seekTo:0];
    
    playPauseButton.selected = NO;
    [_player pause];
    if (topView.hidden)
    {
        [self hideTopBottomView:NO];
    }
    [self killHideTimer];
    
    if (isRecording)
    {
        [self stopRecord];
    }
}

//@optional

/**
 * 视频大小变化通知
 *
 * @param width  视频宽度
 * @param height 视频高度
 */
- (void)onPlayerSizeChanged:(int)width height:(int)height player:(QHVCPlayer *)player
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (width > height)
    {
        appDelegate.oriention = UIInterfaceOrientationMaskAll;
        canVideoRotate = YES;
    }
    else
    {
        appDelegate.oriention = UIInterfaceOrientationMaskPortrait;
        canVideoRotate = NO;
    }
    fullScreenButton.enabled = YES;
}

/**
 开始缓冲(buffer为空，触发loading)
 */
- (void)onPlayerBufferingBegin:(QHVCPlayer *)player
{
    [hudManager showLoadingProgressOnView:playerView message:@"loading..."];
}

/**
 * 缓冲进度(buffer loading进度)
 *
 * @param progress 缓冲进度，progress==0表示开始缓冲， progress==100表示缓冲结束
 */
- (void)onPlayerBufferingUpdate :(int)progress player:(QHVCPlayer *)player
{

}

/**
 缓冲完成(buffer loading完成，可以继续播放)
 */
- (void)onPlayerBufferingComplete:(QHVCPlayer *)player
{
    [hudManager hideHud];
}

/**
 * 拖动操作缓冲完成
 */
- (void)onPlayerSeekComplete:(QHVCPlayer *)player
{
    
}

/**
 播放进度回调
 */
- (void)onPlayerPlayingProgress:(CGFloat)progress player:(QHVCPlayer *)player
{
    if (!isSliderGliding)
    {
        [playerSlider setValue:progress];
        [currentTimeLabel setText:[self formatedTime:[_player getCurrentPosition]]];
    }
}

- (void)onplayerPlayingUpdatingMediaInfo:(NSDictionary *)mediaInfo player:(QHVCPlayer *)player
{
    if (isTableViewSlide)
        return;
    NSString *version = [QHVCPlayer getVersion];//版本号
    NSString *url = testUrl;//播放url
    NSString *resolution = [NSString stringWithFormat:@"%@*%@", [mediaInfo valueForKey:@"width"], [mediaInfo valueForKey:@"height"]];//码率
    NSString *bitRate = [NSString stringWithFormat:@"%ld", _bitrate];//码率
    NSString *fps = [NSString stringWithFormat:@"%ld", _fps];//帧率
    NSString *adec_name = [mediaInfo valueForKey:@"adec_name"];//音频格式
    NSString *sample_rate = [mediaInfo valueForKey:@"sample_rate"];//采样率
    NSString *channel = [mediaInfo valueForKey:@"channel"];//音频轨道
    NSString *vdec_name = [mediaInfo valueForKey:@"vdec_name"];//视频编码格式
    NSString *downloadFlow = [self convertSize:_downstreamTraffic];//下行流量
    NSString *currentTime = [NSString stringWithFormat:@"%0.1f s", [_player getCurrentPosition]];//已播时长
    NSString *netType = [mediaInfo valueForKey:@"netType"];//网络类型
    _dataSource = @[
                    [NSString stringWithFormat:@"版本号：%@", version],
                    [NSString stringWithFormat:@"%@", url],
                    [NSString stringWithFormat:@"分辨率：%@", resolution],
                    [NSString stringWithFormat:@"码率：%@", bitRate],
                    [NSString stringWithFormat:@"帧率：%@", fps],
                    [NSString stringWithFormat:@"音频格式：%@", adec_name],
                    [NSString stringWithFormat:@"采样率：%@", sample_rate],
                    [NSString stringWithFormat:@"音频轨道：%@", channel],
                    [NSString stringWithFormat:@"视频编码格式：%@", vdec_name],
                    [NSString stringWithFormat:@"下行流量：%@", downloadFlow],
                    [NSString stringWithFormat:@"已播时长：%@", currentTime],
                    [NSString stringWithFormat:@"网络类型：%@", [self netType:netType]],
                    ];
    NSIndexSet *section = [[NSIndexSet alloc] initWithIndex:1]; //刷新第二个section
    [_mediaInfoTableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
}

/**
 * 播放器错误回调
 *
 * @param error       错误类型
 * @param extraInfo   额外的信息
 */
- (void)onPlayerError:(QHVCPlayerError) error extra:(QHVCPlayerErrorDetailedInfo)extraInfo player:(QHVCPlayer *)player
{
    NSLog(@"error:%ld", (long)extraInfo);//播放器初始化I/O错误要重新初始化player
}

/**
 * 播放状态回调
 *
 * @param info  参见状态信息枚举
 * @param extraInfo 扩展信息
 */
- (void)onPlayerInfo:(QHVCPlayerStatus)info extra:(NSString * _Nullable)extraInfo player:(QHVCPlayer *)player
{
    if ([extraInfo isEqualToString:@"play"])
    {
        playPauseButton.selected = YES;
        [self startHideTopBottomTimer];
    }
    NSLog(@"PlayerStatus:%@", extraInfo);
}

- (void)onPlayerSwitchResolutionSuccess:(int)index player:(QHVCPlayer *)player
{
    [hudManager showTextOnlyAlertViewOnView:playerView message:@"切换码率成功" hideFlag:YES];
}

- (void)onPlayerSwitchResolutionFailed:(NSString *)errorMsg player:(QHVCPlayer *)player
{
    [hudManager showTextOnlyAlertViewOnView:playerView message:[NSString stringWithFormat:@"切换码率失败:%@", errorMsg] hideFlag:YES];
}

- (void)onPlayerSystemVolume:(float)volume
{
    NSLog(@"volume:%f", volume);
}

- (void)audioPitch:(int)volume player:(QHVCPlayer *)player
{
    NSLog(@"-----------------%d", volume);
}

- (void)onPlayerAudioDataCallback:(CMSampleBufferRef)sampleBuffer
{
    NSLog(@"%@", sampleBuffer);
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

#pragma mark Layout
- (void)initPlayerView
{
    [self.view addSubview:playerView];
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(kQHVCPlayerVC_PlayView_H));
    }];
}

- (void)initTopView
{
    maskView = [UIView new];
    [self.view addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.equalTo(@60);
    }];

    topGradientLayer = [CAGradientLayer layer];
    topGradientLayer.opacity = 0.8;
    topGradientLayer.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 60);
    [maskView.layer addSublayer:topGradientLayer];
    topGradientLayer.startPoint = CGPointMake(0, 0);
    topGradientLayer.endPoint = CGPointMake(0, 1);
    topGradientLayer.colors = @[(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor clearColor].CGColor];
    topGradientLayer.locations = @[@(0.0f), @(1.0f)];
    
    topView = [UIView new];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(kQHVCPhoneFringeHeight + (kQHVCIPhoneXSerial ? 0 : 20));
        make.height.equalTo(@60);
    }];

    UIButton *backBtn = [UIButton new];
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView);
        make.left.equalTo(topView);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    titleLabel = [UILabel new];
    [titleLabel sizeToFit];
    titleLabel.text = self.title;
    titleLabel.textColor = [UIColor whiteColor];
    [topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backBtn.mas_right);
        make.bottom.equalTo(backBtn);
        make.top.equalTo(topView);
        make.right.equalTo(topView).offset(-100);
    }];
    
    resolutionButton = [UIButton new];
    [resolutionButton setTitle:@"x" forState:UIControlStateNormal];
    [resolutionButton addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:resolutionButton];
    [resolutionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView);
        make.right.equalTo(topView);
        make.width.equalTo(@80);
        make.height.equalTo(@20);
    }];
    
    multipleRateButton = [UIButton new];
    [multipleRateButton setTitle:@"倍速" forState:UIControlStateNormal];
    [multipleRateButton addTarget:self action:@selector(multipleRateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:multipleRateButton];
    [multipleRateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView);
        make.right.equalTo(resolutionButton.mas_left);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    recordButton = [UIButton new];
    [recordButton setTitle:@"录制" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:recordButton];
    [recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView);
        make.right.equalTo(multipleRateButton.mas_left);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
}

- (void)initBottomView
{
    bottomView = [UIView new];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(playerView);
        make.height.equalTo(@50);
    }];
    bottomGradientLayer = [CAGradientLayer layer];
    bottomGradientLayer.opacity = 0.8;
    bottomGradientLayer.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 50);
    [bottomView.layer addSublayer:bottomGradientLayer];
    bottomGradientLayer.startPoint = CGPointMake(0, 0);
    bottomGradientLayer.endPoint = CGPointMake(0, 1);
    bottomGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor blackColor].CGColor];
    bottomGradientLayer.locations = @[@(0.0f), @(1.0f)];
    
    playPauseButton = [UIButton new];
    [playPauseButton setImage:[UIImage imageNamed:@"playerPlay"] forState:UIControlStateNormal];
    [playPauseButton setImage:[UIImage imageNamed:@"playerPause"] forState:UIControlStateSelected];
    [playPauseButton addTarget:self action:@selector(playPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playPauseButton];
    [playPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(bottomView);
        make.width.equalTo(@40);
    }];
    
    currentTimeLabel = [UILabel new];
    currentTimeLabel.textColor = [UIColor whiteColor];
    currentTimeLabel.font = [UIFont systemFontOfSize:10];
    currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    currentTimeLabel.text = @"00:00";
    [bottomView addSubview:currentTimeLabel];
    [currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(playPauseButton.mas_right);
        make.top.bottom.equalTo(bottomView);
    }];
    
    fullScreenButton = [UIButton new];
    fullScreenButton.enabled = NO;
    [fullScreenButton setImage:[UIImage imageNamed:@"fullScreen"] forState:UIControlStateNormal];
    [fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:fullScreenButton];
    [fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(bottomView);
        make.width.equalTo(@40);
    }];
    
    totalTimeLabel = [UILabel new];
    totalTimeLabel.textColor = [UIColor whiteColor];
    totalTimeLabel.font = [UIFont systemFontOfSize:10];
    totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    totalTimeLabel.text = @"00:00";
    [bottomView addSubview:totalTimeLabel];
    [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(fullScreenButton.mas_left);
        make.top.bottom.equalTo(bottomView);
    }];
    
    playerSlider = [[QHVCSlider alloc] initWithFrame:CGRectMake(60, 0, SCREEN_SIZE.width - 80 - 40, 50)];
    playerSlider.trackImage = [UIImage imageNamed:@"progressBar"];
    playerSlider.delegate = self;
    [bottomView addSubview:playerSlider];
    
    if (isLiving)
    {
        playerSlider.hidden = YES;
        currentTimeLabel.hidden = YES;
        totalTimeLabel.hidden = YES;
        playPauseButton.userInteractionEnabled = NO;
        resolutionButton.hidden = YES;
        multipleRateButton.hidden = YES;
//        recordButton.hidden = YES;
    }
}

- (void)initMediaInfoTableView
{
    _mediaInfoTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [_mediaInfoTableView registerClass: [QHVCPlayerInfoTableViewCell class]
       forCellReuseIdentifier: @"urlCell"];
    [_mediaInfoTableView registerClass: [UITableViewCell class]
                forCellReuseIdentifier: @"cell"];
    _mediaInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mediaInfoTableView.backgroundColor = [UIColor clearColor];
    _mediaInfoTableView.delegate = self;
    _mediaInfoTableView.dataSource = self;
    [self.view addSubview:_mediaInfoTableView];
    [_mediaInfoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(playerView.mas_bottom).offset(10);
    }];
}

- (void)resetTableViewConstraint:(BOOL)isFullScreen
{
    [self.view bringSubviewToFront:_mediaInfoTableView];
    [_mediaInfoTableView reloadData];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)
            {
                return 80;
            }
            return 40;
        }
    }
    return 22;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    return _dataSource.count - 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        QHVCPlayerInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"urlCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setTitleEnable:YES];
        [cell setTitle:_dataSource[indexPath.row]];
        if (playerView.bounds.size.height == SCREEN_SIZE.height)
        {
            [cell setTitleColor:[UIColor whiteColor]];
        }
        else
        {
            [cell setTitleColor:[UIColor blackColor]];
        }
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (indexPath.section == 0)
        {
            cell.textLabel.text = _dataSource[indexPath.row];
        }
        else
        {
            cell.textLabel.text = _dataSource[indexPath.row + 2];
        }
        if (playerView.bounds.size.height == SCREEN_SIZE.height)
        {
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        else
        {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        return cell;
    }
}

#pragma mark ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isTableViewSlide = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isTableViewSlide = NO;
}

#pragma mark ButtonAction
- (void)closeBtnAction:(UIButton *)button
{
    [self backBtnAction:nil];
}

- (void)backBtnAction:(UIButton *)button
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation != UIInterfaceOrientationPortrait)
    {
        [self forceOrientationPortrait:UIInterfaceOrientationPortrait];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController popViewControllerAnimated:NO];
        [self killHideTimer];
        [_player closeNetStats];
        [_player stop];
        [_downloadProgressTimer invalidate];
        _downloadProgressTimer = nil;
        
        if (isRecording)
        {
            [self stopRecord];
        }
        if (self.gotoRecord) {
            self.gotoRecord(button?YES:NO);
        }
    }
}

- (void)multipleRateButtonAction:(UIButton *)button
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"倍速播放" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"0.5x" style:multipleRateIndex == 0 ?  UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        multipleRateIndex = 0;
        [_player setPlaybackRate:0.5];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"4x" style:multipleRateIndex == 1 ?  UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        multipleRateIndex = 1;
        [_player setPlaybackRate:4];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"5x" style:multipleRateIndex == 2 ?  UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        multipleRateIndex = 2;
        [_player setPlaybackRate:6];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"正常" style:multipleRateIndex == 3 ?  UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        multipleRateIndex = 3;
        [_player setPlaybackRate:1];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)stopRecord
{
    isRecording = NO;
    [_player stopRecorder];
    [recordButton setTitle:@"录制" forState: UIControlStateNormal];
    [recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)recordButtonAction:(UIButton *)button
{
    if (isRecording)
    {
        [self stopRecord];
        
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"录制" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __block NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"recordVideo"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"音视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        path = [path stringByAppendingPathComponent:@"test.mp4"];
        if ([_player startRecorder:path recorderFormat:QHVCRecordFormatDefault recordConfig:NULL])
        {
            isRecording = YES;
            [button setTitle:@"结束" forState: UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"纯视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        path = [path stringByAppendingPathComponent:@"test.mp4"];
        if ([_player startRecorder:path recorderFormat:QHVCRecordFormatOnlyVideo recordConfig:NULL])
        {
            isRecording = YES;
            [button setTitle:@"结束" forState: UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"纯音频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        path = [path stringByAppendingPathComponent:@"test.mp4"];
        if ([_player startRecorder:path recorderFormat:QHVCRecordFormatOnlyAudio recordConfig:NULL])
        {
            isRecording = YES;
            [button setTitle:@"结束" forState: UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"gif" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *input = [rootPath stringByAppendingPathComponent:@"recordVideo/test.mp4"];
        NSString *output = [rootPath stringByAppendingPathComponent:@"recordVideo/test.gif"];

        [QHVCPlayer createGifWithVideo:input outPutPath:output sampleInterval:100 callback:^(float progress, BOOL completed) {
            NSLog(@"gifProgress:%f", progress);
        }];
        isRecording = YES;
        [button setTitle:@"结束" forState: UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)playPauseButtonAction:(UIButton *)button
{
    button.selected = !button.selected;
    if ([_player playerStatus] == QHVCPlayerStatusPaused)
    {
        [_player play];
        [self startHideTopBottomTimer];
    }
    else
    {
        [_player pause];
        [self killHideTimer];
    }
}

- (void)fullScreenButtonAction:(UIButton *)button
{
    if (canVideoRotate)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation != UIInterfaceOrientationPortrait)
        {
            [self forceOrientationPortrait:UIInterfaceOrientationPortrait];
        }
        else
        {
            [self forceOrientationPortrait:UIInterfaceOrientationLandscapeRight];
        }
    }
    else
    {
        if (playerView.frame.size.height == SCREEN_SIZE.height)
        {
            [UIView animateWithDuration:0.1 animations:^{
                [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo(self.view);
                    make.height.equalTo(playerView.mas_width).multipliedBy(SCREEN_SCALE);
                }];
                [playerView.superview layoutIfNeeded];
            } completion:nil];
            [self resetTableViewConstraint:YES];
        }
        else
        {
            [UIView animateWithDuration:0.1 animations:^{
                [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.view);
                }];
                [playerView.superview layoutIfNeeded];
            } completion:nil];
            [self resetTableViewConstraint:NO];
        }
    }
}

#pragma mark ScreenRotate
- (void)forceOrientationPortrait:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = interfaceOrientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    topGradientLayer.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 60);
    bottomGradientLayer.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 50);
    
    CGFloat trackValue = playerSlider.trackValue;
    CGFloat value = playerSlider.value;
    UIView *view = playerSlider.superview;
    [playerSlider removeFromSuperview];
    playerSlider = nil;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait)
        
    {
        [self resetTableViewConstraint:YES];
        [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.equalTo(@(kQHVCPlayerVC_PlayView_H));
        }];
        [topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(kQHVCPhoneFringeHeight + (kQHVCIPhoneXSerial ? 0 : 20));
            make.height.equalTo(@60);
        }];
        
        [bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(playerView);
            make.height.equalTo(@50);
        }];
        
        [_mediaInfoTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(playerView.mas_bottom).offset(10);
        }];
        playerSlider = [[QHVCSlider alloc] initWithFrame:CGRectMake(60, 0, SCREEN_SIZE.width - 80 - 40, 50)];
    }
    else
    {
        [self resetTableViewConstraint:NO];
        [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kQHVCPhoneFringeHeight);
            make.right.equalTo(self.view).offset(-kQHVCPhoneFringeHeight);
            make.top.equalTo(self.view).offset(20);
            make.height.equalTo(@60);
        }];
        
        [bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(playerView);
            make.left.equalTo(playerView).offset(kQHVCPhoneFringeHeight);
            make.right.equalTo(playerView).offset(-kQHVCPhoneFringeHeight);
            make.height.equalTo(@50);
        }];
        
        [_mediaInfoTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kQHVCPhoneFringeHeight);
            make.right.equalTo(self.view).offset(-kQHVCPhoneFringeHeight);
            make.bottom.equalTo(bottomView.mas_top);
            make.top.equalTo(topView.mas_bottom).offset(10);
        }];
        
        playerSlider = [[QHVCSlider alloc] initWithFrame:CGRectMake(60, 0, SCREEN_SIZE.width - 132 - kQHVCPhoneFringeHeight*2, 50)];
    }
    
    playerSlider.trackImage = [UIImage imageNamed:@"progressBar"];
    playerSlider.delegate = self;
    [view addSubview:playerSlider];
    [playerSlider setTrackValue:trackValue];
    [playerSlider setValue:value];
    if (isLiving)
    {
        playerSlider.hidden = YES;
    }
}

- (void)willResignAction:(NSNotification *)notification
{
    if (willBackground)
        return;
    
    willBackground = YES;
//    if (!isLiving)
//    {
//        if (_player.playerStatus == QHVCPlayerStatusPlaying)
//        {
//            playingWhenBackground = YES;
//            [_player pause];
//        }
//        else
//        {
//            playingWhenBackground = NO;
//        }
//    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.oriention == UIInterfaceOrientationMaskAll && [[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait)
    {
        appDelegate.oriention = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft ? UIInterfaceOrientationMaskLandscapeLeft : UIInterfaceOrientationMaskLandscapeRight;
    }
    
    if (isRecording)
    {
        [self stopRecord];
    }
}

- (void)becomeActive:(NSNotification *)notification
{
    willBackground = NO;
    
//    if (!isLiving)
//    {
//        if (playingWhenBackground)
//        {
//            playingWhenBackground = NO;
//            [_player play];
//        }
//    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (canVideoRotate)
    {
        appDelegate.oriention = UIInterfaceOrientationMaskAll;
    }
    else
    {
        appDelegate.oriention = UIInterfaceOrientationMaskPortrait;
    }
}

- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    int reason = [[[notification userInfo] valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    switch (reason)
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            if (isRecording)
            {
                [self stopRecord];
            }
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
        {
            break;
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark PlayerViewControl
- (void)startDownloadProgressTimer
{
    _downloadProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                              target:self
                                                            selector:@selector(loadProgressTimerFire:)
                                                            userInfo:nil
                                                             repeats:YES];
}

- (void)loadProgressTimerFire:(id)userinfo
{
    double download = [_player getDownloadProgress];
    double current = [_player getCurrentPosition];
    double total = [_player getDuration];
    if (download < 0 || total <= 0)
        return;
    playerSlider.trackValue = (download + current)/total;
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

- (void)hideTopBottomView:(BOOL)hidden
{
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionFade;
//    animation.duration = 0.4;
//    [topView.layer addAnimation:animation forKey:nil];
//    [bottomView.layer addAnimation:animation forKey:nil];

    maskView.hidden = hidden;
    topView.hidden = hidden;
    bottomView.hidden = hidden;
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
}

- (void)addTapGesture
{
    UITapGestureRecognizer *playerTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureHandle:)];
    [playerView addGestureRecognizer:playerTapGesture];
    
    UITapGestureRecognizer *tableViewtapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureHandle:)];
    [_mediaInfoTableView addGestureRecognizer:tableViewtapGesture];
}

- (void)tapGestureHandle:(UITapGestureRecognizer *)tap
{
    if ((tap.view == _mediaInfoTableView && playerView.frame.size.width == SCREEN_SIZE.width && playerView.frame.size.height == SCREEN_SIZE.height) || tap.view == playerView)
    {
        if (topView.hidden)
        {
            [self hideTopBottomView:NO];
            if ([_player playerStatus] != QHVCPlayerStatusPaused)
            {
                [self startHideTopBottomTimer];
            }
        }
        else
        {
            [self hideTopBottomView:YES];
            [self killHideTimer];
        }
    }
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
        minStr = [NSString stringWithFormat:@"0%ld", minute];
    }
    int second = (int)timeDuration % 60;
    formatedString = [NSString stringWithFormat:@"%@:%02d",minStr,second];
    
    return formatedString;
}

- (NSString *)netType:(NSString *)net
{
    if ([net isEqualToString:@"0"])
    {
        return @"没有网络";
    }
    else if ([net isEqualToString:@"1"])
    {
        return @"wifi";
    }
    else
    {
        return @"移动网络";
    }
}

- (NSString *)convertSize:(long long)size
{
    long kb = 1024;
    long mb = kb*1024;
    long gb = mb*1024;
    if (size >= gb)
    {
        return [NSString stringWithFormat:@"%.1f GB", (float)size/gb];
    }
    else if (size >= mb)
    {
        float f = (float) size/mb;
        return [NSString stringWithFormat:@"%.1f MB", f];
    }
    else if (size > kb)
    {
        float f = (float) size / kb;
        return [NSString stringWithFormat:@"%.f KB", f];
    }
    else
    {
        return [NSString stringWithFormat:@"%lld B", size];
    }
}

- (void)initNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignAction:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionWasInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    
#ifdef DEBUG
    [QHVCPlayer setLogLevel:QHVCPlayerLogLevelFatal];
#endif
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(QHVCHUDManager) *weakHud = hudManager;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                [weakHud showTextOnlyAlertViewOnView:weakSelf.view message:@"没有网络" hideFlag:YES];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"移动网络");
                [weakHud showTextOnlyAlertViewOnView:weakSelf.view message:@"移动网络" hideFlag:YES];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
        }
    }];
    [manager startMonitoring];
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
