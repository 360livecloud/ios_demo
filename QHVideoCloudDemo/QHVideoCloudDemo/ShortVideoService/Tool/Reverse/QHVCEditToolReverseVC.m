//
//  QHVCEditToolReverseVC.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/23.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditToolReverseVC.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import <QHVCPlayerKit/QHVCPlayerKit.h>
#import "QHVCPhotoItem.h"
#import "QHVCShortVideoMacroDefs.h"

@interface QHVCEditToolReverseVC () <QHVCEditReverseProducerDelegate, QHVCPlayerDelegate>
@property (nonatomic, retain) QHVCPhotoItem* photoItem;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerTopConstraint;

@property (nonatomic, retain) QHVCPlayer* player;
@property (nonatomic, retain) QHVCEditReverseProducer* producer;
@property (nonatomic, retain) NSString* outputPath;

@end

@implementation QHVCEditToolReverseVC

- (instancetype)initWithPhotoItem:(QHVCPhotoItem *)item
{
    self = [super init];
    if (self)
    {
        self.photoItem = item;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"视频倒放"];
    [self.nextBtn setHidden:YES];
    
    [self.indicator startAnimating];
    [self.progressView setHidden:NO];
    [self startReverse];
}

- (void)backAction:(UIButton *)btn
{
    [super backAction:btn];
    if (![self.progressView isHidden])
    {
        [self.producer stop];
        [self.producer free];
    }
}

#pragma mark - Reverse Methods

- (void)startReverse
{
    if (!self.photoItem)
    {
        return;
    }
    
    NSString* fileIdentifier = self.photoItem.fileIdentifier;
    self.outputPath = [NSTemporaryDirectory() stringByAppendingString:@"reverse.mp4"];
    QHVCEditFileInfo* fileInfo = [QHVCEditTools getFileInfoWithIdentifier:fileIdentifier];
    NSInteger duration = fileInfo.durationMs;
    
    self.producer = [[QHVCEditReverseProducer alloc] init];
    [self.producer setDelegate:self];
    [self.producer startWithFileIdentifier:fileIdentifier
                           reverseFilePath:self.outputPath
                        inputFileStartTime:0
                          inputFileEndTime:duration
             inputFileSlowMotionVideoInfos:nil];
}

- (void)onProducerError:(QHVCEditError)error
{
    NSLog(@"reverse error[%ld]", error);
    [self.producer free];
}

- (void)onProducerComplete
{
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF
        [self.indicator stopAnimating];
        [self.progressView setHidden:YES];
        [self.producer free];
        [self showPlayer];
    });
}

- (void)onProducerProgress:(float)progress
{
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF
        NSString* str = [NSString stringWithFormat:@"%.1f%%", progress];
        [self.progressLabel setText:str];
    });
}

#pragma mark - Player Methods

- (void)showPlayer
{
    [self.playerView setHidden:NO];
    self.player = [[QHVCPlayer alloc] initWithURL:self.outputPath channelId:@"demo" userId:nil playType:QHVCPlayTypeVod];
    [self.player setPlayerDelegate:self];
    [self.player createPlayerView:self.playerView];
    [self.player prepare];
}

- (void)onPlayerPrepared:(QHVCPlayer *)player
{
    [self.player play];
}

- (void)onPlayerFinish:(QHVCPlayer *)player
{
    [self.player seekTo:0];
    [self.player play];
}

- (void)onPlayerFirstFrameRender:(NSDictionary *_Nullable)mediaInfo player:(QHVCPlayer *_Nonnull)player
{}

@end
