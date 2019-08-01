//
//  QHVCEditProducerVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/27.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditProducerVC.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditPrefs.h"
#import "QHVCPhotoManager.h"
#import "UIView+Toast.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import "QHVCEditMediaEditorConfig.h"

@interface QHVCEditProducerVC () <QHVCEditProducerDelegate>

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property (nonatomic, retain) QHVCEditProducer* producer;
@property (nonatomic, retain) NSString* makeFilePath;
@property (nonatomic, assign) BOOL producerComplete;
@property (nonatomic, assign) BOOL isPlayComplete;
@property (nonatomic, assign) NSTimeInterval startTime;

@end

@implementation QHVCEditProducerVC

#pragma mark - Life Circle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNextBtnTitle:@"导出"];
    [self setTitle:@"合成"];
    [self createPlayerAndParams];
    [self createProducer];
    [self startProducer];
}

- (void)createPlayerAndParams
{
    [self createPlayerWithPreview:self.preview];
    [self seekTo:0];
    [self.playBtn setHidden:YES];
    
    //播放器preview高度适配
    CGFloat maxHeight = CGRectGetHeight(self.preview.frame);
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
}

- (void)backAction:(UIButton *)btn
{
    [self freePlayer];
    [self freeProducer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction:(UIButton *)btn
{
    if (self.producerComplete)
    {
        [[QHVCPhotoManager manager] saveVideoToAlbum:_makeFilePath complete:^(BOOL success, NSError *error)
        {
            [self.view makeToast:success? @"导入相册成功":@"导入相册失败"];
        }];
    }
}

#pragma mark - Producer Methods

- (void)createProducer
{
    _makeFilePath = [NSString stringWithFormat:@"%@/%@.mp4", [[QHVCEditPrefs sharedPrefs] videoTempDir], @([NSDate date].timeIntervalSinceNow)];
    _producer = [[QHVCEditMediaEditor sharedInstance] createProducerWithDelegate:self];
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    [timeline setOutputPath:_makeFilePath];
}

- (void)freeProducer
{
    [[QHVCEditMediaEditor sharedInstance] freeProducer:_producer];
}

- (void)startProducer
{
    [self.producer start];
    self.producerComplete = NO;
    self.startTime = [[NSDate date] timeIntervalSince1970];
}

- (void)stopProducer
{
    [self.producer stop];
}

- (void)onProducerProgress:(float)progress
{
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        
        STRONG_SELF
        NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
        NSInteger duration = (curTime - self.startTime) * 1000;
        [self.progressLabel setText:[NSString stringWithFormat:@"%.2f%%",progress]];
        [self.durationLabel setText:[NSString stringWithFormat:@"耗时 %ld 毫秒", (long)duration]];
    });
}

- (void)onProducerComplete
{
    //合成结束
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF
        [self.progressLabel setHidden:YES];
        self.producerComplete = YES;
        [self.playBtn setHidden:NO];
        
        NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
        NSInteger duration = (curTime - self.startTime) * 1000;
        [self.durationLabel setHidden:YES];
        NSLog(@"耗时 %ld 毫秒", (long)duration);
    });
}

- (void)onProducerError:(QHVCEditError)error
{
    NSLog(@"%@", [NSString stringWithFormat:@"produce error, %ld", (long)error]);
}

#pragma mark - Player Methods

- (IBAction)clickedPlayerBtn:(UIButton *)sender
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
    }];
}

- (void)playAction
{
    [self play];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
}

- (void)pauseAction
{
    [self stop];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
}

- (void)playerComplete
{
    self.isPlayComplete = YES;
    [self.playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
}

@end
