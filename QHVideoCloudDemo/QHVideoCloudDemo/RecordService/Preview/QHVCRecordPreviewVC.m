//
//  QHVCRecordPreviewVC.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/10/22.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordPreviewVC.h"
#import "QHVCGlobalConfig.h"
#import <QHVCRecordKit/QHVCRecordKit.h>
#import "UIViewAdditions.h"
#import "QHVCToast.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "QHVCRecordEffectNavView.h"
#import "QHVCRecordAuxFilterView.h"
#import "QHVCRecordSpeedView.h"
#import "QHVCRecordSegmentCell.h"

#import "QHVCRecordBGMView.h"

#import <QHVCPlayerKit/QHVCPlayerKit.h>
#import "QHVCRecordPlayerViewController.h"

#define RECORD_AUDIO
#define RECORD_VIDEO

#define BACK_CUT_SEGMEGT
//#define BACK_CUT_DURATION
static int backcutDuration = 1000;//ms

static NSString * const segmentCellIdentifier = @"QHVCRecordSegmentCell";

typedef NS_ENUM( NSInteger, QHVCCamSetupResult ) {
    QHVCCamSetupResultSuccess,
    QHVCCamSetupResultCameraNotAuthorized,
    QHVCCamSetupResultSessionConfigurationFailed
};

typedef NS_ENUM( NSInteger, QHVCCamCaptureMode ) {
    QHVCCamCaptureModeMovie = 0,
    QHVCCamCaptureModePhoto = 1,
};

@interface QHVCRecordPreviewVC ()<QHVCRecordDelegate,QHVCPlayerDelegate,QHVCPlayerAdvanceDelegate>
{
    UIView *_videoRecordPreview;
    QHVCRecord *_videoSession;
    BOOL _isFrontCamera;
    BOOL _isFlashOn;
    BOOL _isRecording;
    BOOL _isMute;
    BOOL _isModifiedTone;//变调
    QHVCCamCaptureMode _captureMode;
    IBOutlet UIButton *_flashBtn;
    IBOutlet UIButton *_recordBtn;
    IBOutlet UIButton *_backDeleteBtn;
    IBOutlet UIButton *_nextBtn;
    IBOutlet UISwitch *_toneSwitch;
    
    QHVCRecordEffectNavView *_effectNavView;
    QHVCRecordAuxFilterView *_filterView;
    QHVCRecordCICLUTFilter *_clutFilter;
    
    QHVCRecordSpeedView *_speedView;
    QHVCRecordBGMView *_musicView;
    
    IBOutlet UICollectionView *_segmentCollectionView;
    NSMutableArray<NSString *> *_segmentDurationMs;
    float _currentDuration;
    
    UIBackgroundTaskIdentifier _backgroundRecordingID;
    
    BOOL _isFirstRecord;
    
    QHVCPlayer *_player;//for music
    QHVCRecordMusicInfo *_musicInfo;
    BOOL _isPlayOver;
}

@property (nonatomic) QHVCCamSetupResult setupResult;
@property (nonatomic, assign) float recordSpeed;
@property (nonatomic, strong) NSString *outputFile;
@property (nonatomic, strong) NSString *cacheFolder;

@property (nonatomic, strong) NSArray<QHVCRecordSegmentInfo *> *draftSegs;
@property (nonatomic, strong) QHVCRecordMusicInfo *draftMusicInfo;

@end

@implementation QHVCRecordPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isFrontCamera = YES;
    _isFlashOn = NO;
    _flashBtn.enabled = NO;
    _isRecording = NO;
    _isMute = NO;
    _isModifiedTone = NO;
    _currentDuration = 0.0;
    _recordSpeed = 1.0;
    _captureMode = QHVCCamCaptureModeMovie;
    
    _cacheFolder = NSTemporaryDirectory();
    
    [_segmentCollectionView registerNib:[UINib nibWithNibName:segmentCellIdentifier bundle:nil] forCellWithReuseIdentifier:segmentCellIdentifier];
    _segmentDurationMs = [NSMutableArray array];

    _videoRecordPreview = [[UIView alloc] initWithFrame:CGRectMake(0, (kScreenHeight-kScreenWidth)/2, kScreenWidth, kScreenWidth)];
//    _videoRecordPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view insertSubview:_videoRecordPreview atIndex:0];
    
    [self requestAuthorization:AVMediaTypeVideo completion:^(BOOL granted) {
        if (granted) {
            [self requestAuthorization:AVMediaTypeAudio completion:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setupSession];
                    });
                }
            }];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createEffectNavView];
    [self createSpeedView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    NSLog(@"QHVCRecordPreviewVC dealloc!!!");
}

#pragma mark Effect
- (void)createEffectNavView
{
    if (!_effectNavView) {
        _effectNavView = [[NSBundle mainBundle] loadNibNamed:[[QHVCRecordEffectNavView class] description] owner:self options:nil][0];
        _effectNavView.frame = CGRectMake(100, 40, kScreenWidth, 50);
        __weak typeof(self) weakSelf = self;
        _effectNavView.selectedCompletion = ^(NSInteger index) {
            [weakSelf navToEffectFunction:index];
        };
        [self.view addSubview:_effectNavView];
    }
}

- (void)createSpeedView
{
    if (!_speedView) {
        _speedView = [[NSBundle mainBundle] loadNibNamed:[[QHVCRecordSpeedView class] description] owner:self options:nil][0];
        _speedView.frame = CGRectMake(50, kScreenHeight - 200, kScreenWidth - 2*50, 50);
        __weak typeof(self) weakSelf = self;
        _speedView.speedAction = ^(float value) {
            weakSelf.recordSpeed = value;
            NSLog(@"record speed value %@",@(value));
        };
        [self.view addSubview:_speedView];
    }
}

- (void)navToEffectFunction:(NSInteger)index
{
    switch (index) {
        case 0:
            [self showFilterView];
            break;
        case 1:
            [self showMusicView];
        default:
            break;
    }
}

- (void)showFilterView
{
    if (!_filterView) {
        _filterView = [[NSBundle mainBundle] loadNibNamed:[[QHVCRecordAuxFilterView class] description] owner:self options:nil][0];
        _filterView.frame = CGRectMake(0, kScreenHeight - 120, kScreenWidth, 120);
        __weak typeof(self) weakSelf = self;
        _filterView.filterAction = ^(NSDictionary *value) {
            [weakSelf addFilter:value];
        };
        [self.view addSubview:_filterView];
    }
    else
    {
        BOOL isHidden = _filterView.hidden;
        _filterView.hidden = !isHidden;
    }
}

- (void)addFilter:(NSDictionary *)item
{
    NSString *path = item[@"color"];
    CIImage *filterImage = nil;
    if (path.length > 0) {
        filterImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:path isDirectory:NO]];
    }
    
    if (!filterImage) {
        [_videoSession removeEffect:_clutFilter];
        _clutFilter = nil;
    }
    else
    {
        if (!_clutFilter) {
            _clutFilter = [[QHVCRecordCICLUTFilter alloc] init];
            [_videoSession appendEffect:_clutFilter];
        }
        _clutFilter.clutImage = filterImage;
    }
}

#pragma mark BGM

- (void)showMusicView
{
    if (_segmentDurationMs.count > 0) {
        [QHVCToast makeToast:@"背景音乐录制前添加哦"];
        return;
    }
    if (_musicView && _musicView.hidden && _musicInfo)
    {
        [QHVCToast makeToast:@"背景音乐已添加，不可以重复哦"];
        return;
    }
    if (!_musicView) {
        _musicView = [[NSBundle mainBundle] loadNibNamed:[[QHVCRecordBGMView class] description] owner:self options:nil][0];
        _musicView.frame = CGRectMake(0, kScreenHeight - 272, kScreenWidth, 272);
        __weak typeof(self) weakSelf = self;
        _musicView.playMusic = ^(NSDictionary * _Nonnull value) {
            [weakSelf playMusic:value];
        };
        _musicView.cutMusic = ^(int from, int to) {
            [weakSelf cutMusic:from to:to];
        };
        _musicView.loopMusic = ^(BOOL isLoop) {
            [weakSelf loopMusic:isLoop];
        };
        _musicView.volumeMusic = ^(int volume) {
            [weakSelf volumeMusic:volume];
        };
        _musicView.confirmMusic = ^(NSDictionary * _Nonnull value) {
            [weakSelf addMusic:value];
        };
        [self.view addSubview:_musicView];
    }
    else
    {
        BOOL isHidden = _musicView.hidden;
        _musicView.hidden = !isHidden;
    }
}

- (void)addMusic:(NSDictionary *)item
{
    if (_isRecording) {
        return;
    }
    if (_player) {
        [_player pause];
    }
    if (!item) {
        return;
    }
    [_videoSession setBackgroundMusic:_musicInfo];
}

- (void)playMusic:(NSDictionary *)item
{
    if (_player) {
        [self releasePlayer];
    }
    QHVCRecordMusicInfo *info = [[QHVCRecordMusicInfo alloc] init];
    NSString *musicName = item[@"name"];
    NSString *path = [[NSBundle mainBundle] pathForResource:musicName ofType:@"mp3"];
    info.filePath = path;
    info.insertTime = 0;
    info.startTime = [item[@"start"] intValue];
    info.endTime = [item[@"end"] intValue];
    info.volume = [item[@"volume"] intValue];
    info.isLoop = [item[@"loop"] boolValue];
    
    _musicInfo = info;
    
    [self createPlayer:path];
}

- (void)cutMusic:(int)from to:(int)to
{
    if (from >= 0) {
        _musicInfo.startTime = from;
        if (_player) {
            [_player seekTo:from/1000.0];
        }
    }
    
    if (to >= 0) {
        _musicInfo.endTime = to;
    }
}

- (void)volumeMusic:(int)volume
{
    _musicInfo.volume = volume;
    if (_player) {
        [_player setVolume:volume/100.0];
    }
}

- (void)loopMusic:(BOOL)isLoop
{
    _musicInfo.isLoop = isLoop;
    if (isLoop) {
        _isPlayOver = NO;
    }
}

#pragma mark Session
- (void)resetSession
{
    if (_videoSession) {
        [_videoSession stopCameraPreview];
        _videoSession = nil;
    }
}

- (void)setupSession
{
     _outputFile = [NSString stringWithFormat:@"%@record_%@.mp4",NSTemporaryDirectory(),[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]]];
    _isFirstRecord = NO;
    _recordBtn.enabled = YES;
    
    for (UIView *view in _videoRecordPreview.subviews) {
        [view removeFromSuperview];
    }
//    NSLog(@"subviews %@",_videoRecordPreview.subviews);
    
#ifdef DEBUG
    [QHVCRecord openLogWithLevel:QHVCRecordLogLevelInfo];//for test
#endif
    
    _videoSession = [[QHVCRecord alloc] init];
    [_videoSession setStatisticsInfo:@{@"channelId":@"demo_1",
                                       @"userId":@"110",
                                       }];
    UIView *preview = nil;
#ifdef RECORD_VIDEO
    QHVCRecordVideoConfig *videoConfig = [QHVCRecordVideoConfig defaultVideoConfig];
    videoConfig.videoWidth = 720;
    videoConfig.videoHeight = 1280;
    videoConfig.videoBitrate = 4500;
    [_videoSession setVideoConfig:videoConfig];
    preview = _videoRecordPreview;
#endif
    
#ifdef RECORD_AUDIO
    [_videoSession setAudioConfig:[QHVCRecordAudioConfig defaultAudioConfig]];
#endif
    [_videoSession setRecordDelegate:self];
    [_videoSession switchCamera:_isFrontCamera];
    
    if (_clutFilter) {
        [_videoSession appendEffect:_clutFilter];
    }
    [_videoSession startCameraPreview:preview];
    
    //配置录制相关
    if (self.draftSegs.count > 0) {
        [_videoSession setRecordSegments:self.draftSegs];
    }
    if (self.draftMusicInfo) {
        [_videoSession setBackgroundMusic:self.draftMusicInfo];
    }
    [_videoSession setRecordPath:_outputFile videoSegmentsFolder:_cacheFolder];
    [_videoSession prepareToRecord];
}

static int factor = 1;
- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
//    CGPoint point = [recognizer locationInView:recognizer.view];
//    CGPoint focusPoint = CGPointMake(point.x*1.0/_videoRecordPreview.width,point.y*1.0/_videoRecordPreview.height);
//    NSLog(@"focusPoint %@",[NSValue valueWithCGPoint:focusPoint]);
//    [_videoSession setFocusPointOfInterest:focusPoint];
    if (factor >= 6) {
        factor = 1;
    }
    [_videoSession setZoom:factor];

//    [_videoSession setVideoOrientation:factor];
    factor++;
    NSLog(@"factor %@",@(factor));
}

- (void)requestAuthorization:(AVMediaType)mediaType completion:(void(^)(BOOL granted))completion
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    NSLog(@"status --- %@,%@",@(status),mediaType);
    if (status == AVAuthorizationStatusAuthorized) {
        if (completion) {
            completion(YES);
        }
    }
    else if (status == AVAuthorizationStatusNotDetermined)
    {
        NSLog(@"AVAuthorizationStatusNotDetermined --- %@,%@",@(status),mediaType);
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^( BOOL granted ) {
            NSLog(@"requestAccessForMediaType --- %@",@(granted));
            if (granted != YES) {
                [self showAlert:mediaType];
            }
            if (completion) {
                completion(granted);
            }
        }];
    }
    else
    {
        NSLog(@"requestAccessForMediaType --- ");
        [self showAlert:mediaType];
        if (completion) {
            completion(NO);
        }
    }
    NSLog(@"completion ---");
}

- (void)showAlert:(AVMediaType)mediaType {
    NSString *msg = mediaType == AVMediaTypeVideo?@"访问相机":@"访问麦克风";
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"设置" otherButtonTitles:@"取消", nil];
        [alert show];
    });
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark Action
- (IBAction)clickedBack:(id)sender
{
    [self resetSession];
    
    if (_player) {
        _player.playerDelegate = nil;
        _player.playerAdvanceDelegate = nil;
        [self releasePlayer];
    }
    self.draftSegs = nil;
    BOOL status = [[NSFileManager defaultManager] removeItemAtPath:NSTemporaryDirectory() error:nil];//每次录制前或者结束后清空cacheFolder
    if (!status) {
        NSLog(@"remove fail !!!");
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)nextAction:(id)sender
{
    _recordBtn.enabled = NO;
    [_videoSession joinAllSegments];
}

- (IBAction)backDeleteAction:(id)sender
{
#ifdef BACK_CUT_SEGMEGT
    float cutDuration = [_segmentDurationMs lastObject].floatValue;
    double pos = [_player getCurrentPosition];
    double seek = pos - cutDuration;
    if (seek < 0) {
        seek = 0;
    }
    [_player seekTo:seek];
    
    [_segmentDurationMs removeLastObject];
    [_segmentCollectionView reloadData];
    [_videoSession deleteLastSegment];
//    [_videoSession deleteAllSegments];
#endif
  
#ifdef BACK_CUT_DURATION
    float currentDuration = [_segmentDurationMs lastObject].floatValue;
    currentDuration = currentDuration - backcutDuration/1000.0;
    while (1) {
        if (currentDuration > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_segmentDurationMs.count-1 inSection:0];
            QHVCRecordSegmentCell * cell = [_segmentCollectionView cellForItemAtIndexPath:indexPath];
            [cell updateCell:[NSString stringWithFormat:@"%.1f",currentDuration]];
            [_segmentDurationMs replaceObjectAtIndex:_segmentDurationMs.count -1 withObject:[NSString stringWithFormat:@"%.1f",currentDuration]];
            break;
        }
        else
        {
            [_segmentDurationMs removeLastObject];
            [_segmentCollectionView reloadData];
            if (_segmentDurationMs.count > 0) {
                NSString *duration = [_segmentDurationMs lastObject];
                currentDuration = duration.floatValue + currentDuration;
            }
            else
            {
                break;
            }
        }
    }
    [_videoSession deleteLastSegmentByMS:backcutDuration];
#endif
    
    if (_segmentDurationMs.count == 0) {
        _backDeleteBtn.hidden = YES;
        _nextBtn.hidden = YES;
    }
}

- (IBAction)muteAction:(UIButton *)sender
{
    _isMute = !_isMute;
    if (_isMute) {
        [sender setImage:[UIImage imageNamed:@"room_mic_close"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"room_mic"] forState:UIControlStateNormal];
    }
    [_videoSession setMute:_isMute];
}

- (IBAction)toggleRecordOrPhoto:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex != _captureMode) {
        if (_isRecording) {
            [QHVCToast makeToast:@"拍照前先停止录制"];
            return;
        }
        _captureMode = sender.selectedSegmentIndex;
    }
}

- (IBAction)toneSwitch:(UISwitch *)sender
{
    _isModifiedTone = sender.on;
}

#pragma mark Record
- (IBAction)startRecording:(id)sender
{
    NSLog(@"capture video size %d,%d",_videoSession.captureVideoDimensions.width,_videoSession.captureVideoDimensions.height);
    if (_captureMode == QHVCCamCaptureModePhoto) {
        _recordBtn.enabled = NO;
        [_videoSession takePhoto:640 outputHeight:640];
//        [_videoSession takePhoto:1080 outputHeight:1920];
    }
    else
    {
        if (_isRecording) {
            _recordBtn.enabled = NO;
            [_videoSession stopRecord];
            [self pausePlayer];
        }
        else
        {
            // Disable the idle timer while recording
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            
            // Make sure we have time to finish saving the movie if the app is backgrounded during recording
            if ( [[UIDevice currentDevice] isMultitaskingSupported] ) {
                _backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
            }
            [_videoSession setRecordSpeed:self.recordSpeed];//默认变声不变调
//            [_videoSession setRecordSpeed:self.recordSpeed mode:_isModifiedTone?QHVCRecordSpeedModeSetrate:QHVCRecordSpeedModeTempo];
            
            _recordBtn.enabled = NO;// avoid re-enabled
            
            [self resumePlayer];
            [_videoSession startRecord];
        }
    }
}

- (IBAction)switchCamera:(id)sender
{
    factor = 1;
    
    _isFrontCamera = !_isFrontCamera;
    [_videoSession switchCamera:_isFrontCamera];
    
    if (!_isFrontCamera) {
        _flashBtn.enabled = YES;
    }
    else
    {
        _flashBtn.enabled = NO;
    }
    [_flashBtn setImage:[UIImage imageNamed:@"live_flash_off"] forState:UIControlStateNormal];
//    [_videoSession toggleTorch:NO];
}

- (IBAction)flash:(id)sender
{
    _isFlashOn = !_isFlashOn;
    if (_isFlashOn) {
        [_flashBtn setImage:[UIImage imageNamed:@"live_flash"] forState:UIControlStateNormal];
    }
    else
    {
        [_flashBtn setImage:[UIImage imageNamed:@"live_flash_off"] forState:UIControlStateNormal];
    }
    [_videoSession toggleTorch:_isFlashOn];
}

static int aspectRatio = 0;
- (void)setAspectRatio
{
    if (aspectRatio >= 3) {
        aspectRatio = 0;
    }
    CGFloat height = 0;
    switch (aspectRatio) {
        case 0:
            height = _videoRecordPreview.frame.size.width * 16 / 9;
            break;
        case 1:
            height = _videoRecordPreview.frame.size.width * 4 / 3;
            break;
        case 2:
            height = _videoRecordPreview.frame.size.width * 1 / 1;
            break;
        default:
            break;
    }
    [UIView animateWithDuration:0.2 animations:^{
        _videoRecordPreview.frame = CGRectMake(0, (kScreenHeight - height) / 2.0, _videoRecordPreview.frame.size.width, height);;
    }];
    aspectRatio++;
}

#pragma mark Player
- (void)createPlayer:(NSString *)url
{
    _player = [[QHVCPlayer alloc] initWithURL:url channelId:@"demo_1" userId:nil playType:QHVCPlayTypeVod options:nil];
    _player.playerDelegate = self;
    _player.playerAdvanceDelegate = self;
    [_player seekTo:_musicInfo.startTime/1000.0];
    [_player prepare];
}

- (void)releasePlayer
{
    if (_player) {
        [_player closeNetStats];
        [_player stop];
    }
}

- (void)resumePlayer
{
    if (_player) {
        if (_isPlayOver) {
            return;
        }
        float rate = 1/self.recordSpeed;
        NSLog(@"rate --- %@",@(rate));
        [_player setPlaybackRate:rate];
        [_player play];
    }
}

- (void)pausePlayer
{
    if (_player) {
        [_player pause];
    }
}

#pragma mark QHVCPlayerDelegate
/**
 播放器准备成功回调,在此回调中调用play开始播放
 */
- (void)onPlayerPrepared:(QHVCPlayer *)player
{
    [_player play];
    [_player openNetStats:5];
}

/**
 播放器渲染第一帧
 */
- (void)onPlayerFirstFrameRender:(NSDictionary *)mediaInfo player:(QHVCPlayer *)player
{
    
}

/**
 播放进度回调
 */
- (void)onPlayerPlayingProgress:(CGFloat)progress player:(QHVCPlayer *)player
{
    if (_player) {
//        NSLog(@"onPlayerPlayingProgress %@",@(progress));
        if (_musicInfo.endTime < [_player getDuration]*1000) {
            NSTimeInterval pos = [_player getCurrentPosition]*1000;//ms
            if (pos >= _musicInfo.endTime) {
                [self onPlayerFinish:player];
            }
        }
    }
}

/**
 播放结束回调
 */
- (void)onPlayerFinish:(QHVCPlayer *)player
{
    _isPlayOver = YES;
    [_player pause];
    [_player seekTo:_musicInfo.startTime/1000.0];//s
    if (_musicInfo.isLoop) {
        _isPlayOver = NO;
        [_player play];
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _segmentDurationMs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCRecordSegmentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:segmentCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_segmentDurationMs[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(72, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)updateStartRecordUI
{
    [_segmentDurationMs addObject:@"-1"];
    [_segmentCollectionView reloadData];
    
    [_recordBtn setImage:[UIImage imageNamed:@"live_startRecord"] forState:UIControlStateNormal];
    _backDeleteBtn.hidden = YES;
    _nextBtn.hidden = YES;
    
    _speedView.speedSlider.enabled = !_isRecording;
    _toneSwitch.enabled = !_isRecording;
}

- (void)updateSegmentCell:(CGFloat)fileDuration
{
    NSLog(@"fileDuration %@",@(fileDuration));
    _currentDuration = fileDuration;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_segmentDurationMs.count-1 inSection:0];
    QHVCRecordSegmentCell * cell = [_segmentCollectionView cellForItemAtIndexPath:indexPath];
    [cell updateCell:[NSString stringWithFormat:@"%.1f",_currentDuration]];
//    AVAudioSession *sharedAudioSession = [AVAudioSession sharedInstance];
//    NSLog(@"AVAudioSession num %@,volume %@,samplerate %@",@(sharedAudioSession.inputNumberOfChannels),@(sharedAudioSession.outputVolume),@(sharedAudioSession.sampleRate));
}

- (void)updateStopRecordUI
{
    [_recordBtn setImage:[UIImage imageNamed:@"live_start"] forState:UIControlStateNormal];
    _backDeleteBtn.hidden = NO;
    _nextBtn.hidden = NO;
    
    NSInteger index = _segmentDurationMs.count;
    if (index > 0) {
        [_segmentDurationMs replaceObjectAtIndex:index-1 withObject:[NSString stringWithFormat:@"%.1f",_currentDuration]];
    }
    [_segmentCollectionView reloadData];
    _currentDuration = 0.0;
    
    _speedView.speedSlider.enabled = !_isRecording;
    _toneSwitch.enabled = !_isRecording;
}

#pragma mark QHVCRecordDelegate

- (void)didStartRecordingSegment:(int)segmentId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _isRecording = YES;
        _recordBtn.enabled = YES;
        [self updateStartRecordUI];
    });
}

/**
 *  @abstract 正在录制的过程中。在完成该段视频录制前会一直回调，可用来更新视频段时长
 */
- (void)didRecordingSegment:(int)segmentId
               fileDuration:(CGFloat)fileDuration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isRecording) {
            [self updateSegmentCell:fileDuration/1000.0];
        }
    });
}

/**
 *  @abstract 完成一段视频的录制
 */
- (void)didFinishRecordingSegment:(int)segmentId
                     fileDuration:(CGFloat)fileDuration
                            error:(nullable NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _isRecording = NO;
        _recordBtn.enabled = YES;
        NSLog(@"final fileDuration %@",@(fileDuration));
        _currentDuration = fileDuration/1000.0;
        [self updateStopRecordUI];
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundRecordingID];
        _backgroundRecordingID = UIBackgroundTaskInvalid;
        
        if (error) {
            //todo
            _recordBtn.enabled = NO;
            [QHVCToast makeToast:@(error.code).stringValue];
        }
    });
}

- (void)didJoinSegmentsProgress:(float)progress
{
    NSLog(@"didJoinSegmentsProgress %@",@(progress));
}

- (void)didJoinSegmentsFinish:(int)status
                 segmentsInfo:(NSArray<QHVCRecordSegmentInfo *> *)segmentsInfo
                     fileInfo:(nonnull QHVCRecordFileInfo *)fileInfo
                        error:(nullable NSError *)error
{
    //end
    if (status == 1) {
        NSLog(@"combine file info %@",fileInfo.path);
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSURL *recordingURL = [NSURL URLWithString:_outputFile];
        [library writeVideoAtPathToSavedPhotosAlbum:recordingURL completionBlock:^(NSURL *assetURL, NSError *error) {
            
            //segmentsInfo返回分段录制素材路径，不需要直接删除即可
            //        [[NSFileManager defaultManager] removeItemAtURL:recordingURL error:NULL];
            if (assetURL) {
                [QHVCToast makeToast:@"合成视频文件已存入相册!"];
            }
            else
            {
                [QHVCToast makeToast:@"视频导入相册未获得有效地址!"];
            }
            self.draftSegs = segmentsInfo;
            self.draftMusicInfo = [_videoSession backgroundMusic];
            NSLog(@"musicInfo %@",self.draftMusicInfo);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self resetSession];
                [self gotoPlayerPreview:_outputFile];
            });
        }];
    }
    else if (status == 2)
    {
        [QHVCToast makeToast:@"取消合成！"];
    }
    else if (status == -100)
    {
        [QHVCToast makeToast:[NSString stringWithFormat:@"合成失败error %@",@(error.code)]];
    }
}

- (void)didFinishProcessingPhoto:(NSData *)photoData error:(nullable NSError *)error
{
    if (error == nil && photoData) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    
                    PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                    [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:photoData options:nil];
                    
                    [QHVCToast makeToast:@"照片已存入相册"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _recordBtn.enabled = YES;
                    });
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    
                    NSLog(@"save photo staus %@,%@",@(success),error);
                }];
            }
        }];
    }
}

#pragma mark Draft

- (void)gotoPlayerPreview:(NSString *)path
{
    NSString *_decode = @"1";
    NSString *_bid = @"demo_bid";
    NSString *_cid = @"demo";
    NSString *_url = path;
    
    NSDictionary *config = @{
                             @"bid":_bid,
                             @"cid":_cid,
                             @"url":_url,
                             @"decode":_decode
                             };
    QHVCRecordPlayerViewController *pvc = [[QHVCRecordPlayerViewController alloc] initWithPlayerConfig:config];
    __weak typeof(self) weakSelf = self;
    pvc.gotoRecord = ^(BOOL isRecord) {
        if (isRecord) {
            [weakSelf setupSession];
        }
        else
        {
            [weakSelf clickedBack:nil];
        }
    };
    [self.navigationController pushViewController:pvc animated:YES];
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
