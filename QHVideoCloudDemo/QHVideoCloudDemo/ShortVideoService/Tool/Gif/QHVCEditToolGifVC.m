//
//  QHVCEditToolGifVC.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/24.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditToolGifVC.h"
#import "QHVCPhotoItem.h"
#import "QHVCShortVideoMacroDefs.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import "QHVCPhotoItem.h"
#import "UIView+Toast.h"
#import "QHVCPhotoManager.h"

@interface QHVCEditToolGifVC () <QHVCEditGifProducerDelegate>
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;
@property (weak, nonatomic) IBOutlet UIView *urlView;

@property (nonatomic, retain) QHVCPhotoItem* photoItem;
@property (nonatomic, retain) QHVCEditGifProducer* producer;
@property (nonatomic, retain) NSString* outputPath;

@end

@implementation QHVCEditToolGifVC

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
    [self setTitle:@"转gif动图"];
    [self.nextBtn setHidden:YES];
    
    [self.indicator startAnimating];
    [self.progressView setHidden:NO];
    [self startGifProducer];
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

#pragma mark - Gif Producer Methods

- (void)startGifProducer
{
    if (!self.photoItem)
    {
        return;
    }
    
    NSString* fileIdentifier = self.photoItem.fileIdentifier;
    self.outputPath = [NSTemporaryDirectory() stringByAppendingString:@"output.gif"];
    QHVCEditFileInfo* fileInfo = [QHVCEditTools getFileInfoWithIdentifier:fileIdentifier];
    NSInteger duration = fileInfo.durationMs;
    
    self.producer = [[QHVCEditGifProducer alloc] init];
    [self.producer setDelegate:self];
    [self.producer setOutputWidth:fileInfo.width];
    [self.producer setOutputHeight:fileInfo.height];
    [self.producer startWithFileIdentifier:fileIdentifier
                            outputFilePath:self.outputPath
                        inputFileStartTime:0
                          inputFileEndTime:duration
                           inputFrameCount:duration/1000];
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
        [self.urlView setHidden:NO];
        [self.urlTextView setText:self.outputPath];
    });
    
    [self.producer free];
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

@end
