//
//  QHVCEditAudioViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAudioViewController.h"
#import "QHVCEditAddAudioView.h"
#import "QHVCEditFrameView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditAudioItem.h"
#import "QHVCEditCommandManager.h"
#import "AudioWaveForm.h"
#import "EZAudioFloatData.h"

#define MAX_VALUE 32768.0

@interface QHVCEditAudioViewController () <QHVCEditAudioProducerDelegate>
{
    QHVCEditFrameView *_frameView;
    QHVCEditAddAudioView *_audioView;
    QHVCEditFrameStatus _viewType;
    float _originAudioVolume;
    float _musicAudioVolume;
    QHVCEditAudioProducer *_audioProducer;
    EZAudioFloatData *_waveformData;
}
@property (nonatomic, strong) QHVCEditAudioItem *currentAudioItem;
@property (nonatomic, strong) NSMutableArray<QHVCEditAudioItem *> *audiosArray;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *audioInfos;

@end

@implementation QHVCEditAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"音乐";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    _originAudioVolume = [QHVCEditPrefs sharedPrefs].originAudioVolume;
    _musicAudioVolume = [QHVCEditPrefs sharedPrefs].musicAudioVolume;
    _audiosArray = [NSMutableArray array];
    _audioInfos = [NSMutableArray arrayWithArray:[QHVCEditPrefs sharedPrefs].audioTimestamp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createFrameView];
    _sliderViewBottom.constant = 70;
}

- (void)createFrameView
{
    _frameView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditFrameView class] description] owner:self options:nil][0];
    _frameView.frame = CGRectMake(0, kScreenHeight - 210, kScreenWidth, 210);
    _frameView.duration = self.durationMs;
    _frameView.timeStamp = [QHVCEditPrefs sharedPrefs].audioTimestamp;
    _viewType = QHVCEditFrameStatusAdd;
    [_frameView setUIStatus:_viewType];
    
    __weak typeof(self) weakSelf = self;
    _frameView.addCompletion = ^(NSTimeInterval insertStartMs) {
        [weakSelf handleAddAction:insertStartMs];
    };
    _frameView.doneCompletion = ^(NSTimeInterval insertEndMs) {
        [weakSelf handleDoneAction:insertEndMs];
    };
    _frameView.editCompletion = ^{
        [weakSelf handleEditAction];
    };
    _frameView.discardCompletion = ^{
        [weakSelf handleDiscardAction];
    };
    [self.view addSubview:_frameView];
}

- (void)handleAddAction:(NSTimeInterval)insertStartMs
{
    [self updateViewType:QHVCEditFrameStatusEdit];
    
    _currentAudioItem = [[QHVCEditAudioItem alloc] init];
    _currentAudioItem.insertStartTimeMs = insertStartMs;
    
    _audioView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditAddAudioView class] description] owner:self options:nil][0];
    _audioView.frame = CGRectMake(0, kScreenHeight - 200, kScreenWidth, 200);
    _audioView.audioItem = self.currentAudioItem;
    _audioView.audioSelectBlock = ^(QHVCEditAudioItem *audioItem) {
    };
    [self.view addSubview:_audioView];
}

- (void)handleDoneAction:(NSTimeInterval)insertEndMs
{
    [self nextAction:nil];
}

- (void)handleEditAction
{
    [self backAction:nil];
}

- (void)handleDiscardAction
{
    [_audioView removeFromSuperview];
    _audioView = nil;
    
    [self updateViewType:QHVCEditFrameStatusAdd];
}

- (void)updateViewType:(QHVCEditFrameStatus)status
{
    _viewType = status;
    
    if (status == QHVCEditFrameStatusAdd) {
        self.titleLabel.text = @"音乐";
        [_frameView setUIStatus:_viewType];
        _frameView.hidden = NO;
        _sliderViewBottom.constant = 70;
        [_frameView removeUncompleteTimestamp];
    }
    else if (status == QHVCEditFrameStatusEdit)
    {
        self.titleLabel.text = @"选择";
        _frameView.hidden = YES;
        _sliderViewBottom.constant = 100;
    }
    else if (status == QHVCEditFrameStatusDone)
    {
        self.titleLabel.text = @"添加";
        [_frameView setUIStatus:_viewType];
        _frameView.hidden = NO;
        _sliderViewBottom.constant = 70;
    }
}

- (void)nextAction:(UIButton *)btn
{
    if(_viewType == QHVCEditFrameStatusEdit)
    {
        if (_currentAudioItem.audiofile.length > 0) {
            _audioView.hidden = YES;
            _originAudioVolume = [QHVCEditPrefs sharedPrefs].originAudioVolume;
            _musicAudioVolume = [QHVCEditPrefs sharedPrefs].musicAudioVolume;
            _currentAudioItem.volume = _musicAudioVolume;
            
            [self updateViewType:QHVCEditFrameStatusDone];
        }
        else
        {
            [_audioView removeFromSuperview];
            _audioView = nil;

            [self updateViewType:QHVCEditFrameStatusAdd];
            
            if (![_audiosArray containsObject:_currentAudioItem]) {
                [_audiosArray addObject:_currentAudioItem];
            }
            [[QHVCEditCommandManager manager] addAudios:@[_currentAudioItem]];
            [[QHVCEditCommandManager manager] adjustMainVolume:_originAudioVolume];
            [self resetPlayer:[_frameView fetchCurrentTimeStampMs]];
        }
    }
    else if (_viewType == QHVCEditFrameStatusDone)
    {
        [_audioView removeFromSuperview];
        _audioView = nil;

        [self updateViewType:QHVCEditFrameStatusAdd];
        
        self.currentAudioItem.insertEndTimeMs = [_frameView fetchCurrentTimeStampMs];
        if (![_audiosArray containsObject:_currentAudioItem]) {
            [_audiosArray addObject:_currentAudioItem];
        }
        [[QHVCEditCommandManager manager] addAudios:@[_currentAudioItem]];
        [[QHVCEditCommandManager manager] adjustMainVolume:_originAudioVolume];
        [self resetPlayer:[_frameView fetchCurrentTimeStampMs]];
        
        [self addWaveFormView];
    }
    else
    {
        if (_audiosArray.count > 0) {
            if (self.confirmCompletion) {
                self.confirmCompletion(QHVCEditPlayerStatusReset);
            }
            [[QHVCEditCommandManager manager] updateAudios];
        }
        if (_audioProducer) {
            [_audioProducer stopProducer];
            _audioProducer = nil;
        }
        [self releasePlayerVC];
    }
}

- (void)backAction:(UIButton *)btn
{
    if(_viewType == QHVCEditFrameStatusEdit)
    {
        [_audioView removeFromSuperview];
        _audioView = nil;

        [self updateViewType:QHVCEditFrameStatusAdd];
        [QHVCEditPrefs sharedPrefs].originAudioVolume = _originAudioVolume;
    }
    else if (_viewType == QHVCEditFrameStatusDone)
    {
        _audioView.hidden = NO;
       
        [self updateViewType:QHVCEditFrameStatusEdit];
    }
    else
    {
        if ([QHVCEditPrefs sharedPrefs].originAudioVolume != _originAudioVolume) {
            QHVCEditAudioItem *item = [[QHVCEditAudioItem alloc] init];
            item.volume = _musicAudioVolume;
            [[QHVCEditCommandManager manager] addAudios:@[item]];
            [[QHVCEditCommandManager manager] adjustMainVolume:_originAudioVolume];
            [QHVCEditPrefs sharedPrefs].originAudioVolume = _originAudioVolume;
        }
        if (_audiosArray.count > 0) {
            [[QHVCEditCommandManager manager] deleteAudios];
        }
        [QHVCEditPrefs sharedPrefs].audioTimestamp = _audioInfos;
        [self releasePlayerVC];
    }
    if (_audioProducer) {
        [_audioProducer stopProducer];
        _audioProducer = nil;
    }
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

- (void)addWaveFormView
{
    NSArray *audios = [[QHVCEditCommandManager manager] getAudios];
    if (audios && [audios count] > 0) {
        _audioProducer = [[QHVCEditAudioProducer alloc] initWithCommandFactory:[[QHVCEditCommandManager manager] commandFactory]];
        QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)audios[0][@"object"];
        _audioProducer.overlayCommandId = (int)cmd.commandId;
        _audioProducer.startTime = 0;
        _audioProducer.endTime = cmd.endTime;
        _audioProducer.delegate = self;
        [_audioProducer startProducer];
    }
}

#pragma mark - <QHVCEditAudioProducerDelegate>

- (void)onPCMData:(unsigned char *)pcm size:(int)size
{
    [self dataWithNumberOfPoints:1024 data:pcm length:size];
    AudioWaveForm* waveForm = [AudioWaveForm sharedManager];
    EZAudioPlot* audioPlot = [waveForm generateWave:_waveformData frame:CGRectMake(0, 0, kScreenWidth, 50)];
    
    [_frameView addSubview:audioPlot];
}

- (void)onProducerStatus:(QHVCEditAudioProducerStatus)status
{
    NSLog(@"onProducerStatus status[%lu]", (unsigned long)status);
}

- (EZAudioFloatData *)dataWithNumberOfPoints:(UInt32)numberOfPoints data:(unsigned char *)audioData length:(NSInteger)length
{
    UInt32 channels = 2;
    if (channels == 0)
    {
        return nil;
    }
    int16_t *audioData16 = (int16_t *)audioData;
    
    float **data = (float **)malloc( sizeof(float*) * channels );
    for (int i = 0; i < channels; i++)
    {
        data[i] = (float *)malloc( sizeof(float) * numberOfPoints );
    }
    
    // calculate the required number of frames per buffer
    SInt64 totalFrames = length/2;//两个unsigned char 为一个声音数据
    SInt64 framesPerBuffer = ((SInt64) totalFrames / numberOfPoints);//包含全部交叉存储声道数据
    SInt64 framesPerChannel = framesPerBuffer / channels;
    
    // read through file and calculate rms at each point
    for (SInt64 i = 0; i < numberOfPoints; i++)
    {
        int16_t *buffer = &audioData16[framesPerBuffer*i];
        for (int channel = 0; channel < channels; channel++)
        {
            float channelData[framesPerChannel];
            for (int frame = 0; frame < framesPerChannel; frame++)
            {
                channelData[frame] = buffer[frame * channels + channel]/MAX_VALUE;
            }
            float rms = [[self class] RMS:channelData length:framesPerChannel];
            data[channel][i] = rms;
        }
    }
    
    _waveformData = [EZAudioFloatData dataWithNumberOfChannels:channels
                                                      buffers:(float **)data
                                                   bufferSize:numberOfPoints];
    
    // cleanup
    for (int i = 0; i < channels; i++)
    {
        free(data[i]);
    }
    free(data);
    
    return _waveformData;
}

+ (float)RMS:(float *)buffer length:(SInt64)bufferSize
{
    float sum = 0.0;
    for(int i = 0; i < bufferSize; i++)
    {
        sum += buffer[i] * buffer[i];
    }
    
    float val = sqrtf( sum / bufferSize);
    
    return val;
}



@end
