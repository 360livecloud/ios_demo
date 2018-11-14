//
//  QHVCEditOverlayVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/22.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayVC.h"
#import "QHVCEditOverlayBottomView.h"
#import "QHVCEditOverlayContentView.h"
#import "QHVCEditPhotoItem.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditMainViewController.h"
#import "QHVCEditOverlayChangeResourceVC.h"
#import "QHVCEditOverlayItemPreview.h"

@interface QHVCEditOverlayVC ()
@property (weak, nonatomic) IBOutlet UIView *playerView;

@property (nonatomic, strong) QHVCEditOverlayBottomView* overlayBottomView;
@property (nonatomic, strong) QHVCEditOverlayContentView* overlayContentView;
@property (nonatomic, assign) NSInteger totalDurationMs;
@property (nonatomic, retain) UIButton* playBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewWidthConstraint;

@end

@implementation QHVCEditOverlayVC

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setText:@"叠加"];
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    NSString* color = [QHVCEditPrefs sharedPrefs].renderColor;
    [[QHVCEditCommandManager manager] updateOutputBackgroudMode:color];
    
    WEAK_SELF
    [[QHVCEditCommandManager manager] fetchSegmentInfo:^(NSArray<QHVCEditSegmentInfo *> *segments, NSInteger totalDurationMs)
     {
         STRONG_SELF
         self.totalDurationMs = totalDurationMs;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createOverlayBottomView];
    [self createOverlayContentView];
    [self createPlayer:self.overlayContentView];
}

- (void)backAction:(UIButton *)btn
{
    [self processWhenLeave];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction:(UIButton *)btn
{
    [self processWhenLeave];
    NSArray* vcs = [self.navigationController viewControllers];
    __block QHVCEditMainViewController* mainVC = nil;
    [vcs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if ([obj isKindOfClass:[QHVCEditMainViewController class]])
        {
            mainVC = obj;
            *stop = YES;
        }
    }];
    
    if (mainVC)
    {
        [self.navigationController popToViewController:mainVC animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)processWhenLeave
{
    [self freePlayer];
}

- (CGRect)rectToOutputRect:(QHVCEditMatrixItem *)item
{
    UIView* view = item.preview;
    CGRect rect = view.frame;
    view.transform = CGAffineTransformRotate(view.transform, -item.preview.radian);
    rect = CGRectMake(rect.origin.x, rect.origin.y, view.frame.size.width, view.frame.size.height);
    
    CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
    CGFloat scaleW = outputSize.width/CGRectGetWidth(self.overlayContentView.frame);
    CGFloat scaleH = outputSize.height/CGRectGetHeight(self.overlayContentView.frame);
    
    CGFloat x = rect.origin.x * scaleW;
    CGFloat y = rect.origin.y * scaleH;
    CGFloat w = rect.size.width * scaleW;
    CGFloat h = rect.size.height * scaleH;
    
    CGRect newRect = CGRectMake(x, y, w, h);
    return newRect;
}

- (void)createOverlayBottomView
{
    self.overlayBottomView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayBottomView class] description] owner:self options:nil][0];
    self.overlayBottomView.frame = CGRectMake(0, kScreenHeight - 160, kScreenWidth, 160);
    [self.view addSubview:self.overlayBottomView];
    
    WEAK_SELF
    [self.overlayBottomView setChangeColorAction:^(NSString *argbColor)
    {
        STRONG_SELF
        UIColor* bgColor = [QHVCEditPrefs colorARGBHex:argbColor];
        [QHVCEditPrefs sharedPrefs].renderColor = argbColor;
        [[QHVCEditCommandManager manager] updateOutputBackgroudMode:argbColor];
        [self.overlayContentView setBackgroundColor:bgColor];
        [self setPlayerBackgroudColor:argbColor];
        [self refreshPlayer];
    }];
    
    [self.overlayBottomView setResetPlayerAction:^{
        STRONG_SELF
        [self resetPlayer:[self playerTime]];
    }];
    
    [self.overlayBottomView setRefreshPlayerAction:^{
        STRONG_SELF
        [self refreshPlayer];
    }];
    
    [self.overlayBottomView setShowPhotoAlbumAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        QHVCEditOverlayChangeResourceVC* changeResourceVC = [[QHVCEditOverlayChangeResourceVC alloc] initWithNibName:@"QHVCEditViewController" bundle:nil];
        changeResourceVC.item = item;
        [self presentViewController:changeResourceVC animated:YES completion:nil];
        [changeResourceVC setResetPlayerAction:^{
            [self resetPlayer:[self playerTime]];
        }];
    }];
    
    [self.overlayBottomView setToTopAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        [self.overlayContentView updateOverlayZOrderToTop:item];
    }];
    
    [self.overlayBottomView setToBottomAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        [self.overlayContentView updateOverlayZOrderToBottom:item];
    }];
    
    [self.overlayBottomView setStartCropAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        [self.overlayContentView overlayStartCrop:item];
    }];
    
    [self.overlayBottomView setStopCropAction:^(QHVCEditMatrixItem *item, BOOL confirm)
    {
        STRONG_SELF
        [self.overlayContentView overlayStopCrop:item confirm:confirm];
        [[QHVCEditCommandManager manager] updateMatrix:item];
        if (confirm)
        {
            [self refreshPlayer];
        }
    }];
}

- (void)createOverlayContentView
{
    CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
    CGFloat scale = outputSize.width / outputSize.height;
    CGFloat width = CGRectGetHeight(_playerView.frame) * scale;
    [self.previewWidthConstraint setConstant:width];
    
    UIColor* bgColor = [QHVCEditPrefs colorARGBHex:[QHVCEditPrefs sharedPrefs].renderColor];
    self.overlayContentView = [[QHVCEditOverlayContentView alloc] initWithFrame:CGRectMake(0, 0, width, CGRectGetHeight(self.playerView.frame))];
    [self.overlayContentView setBackgroundColor:bgColor];
    [self.playerView addSubview:self.overlayContentView];
    
    self.playBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.playerView.frame)/2 - 20, CGRectGetHeight(self.playerView.frame)/2 - 20, 40, 40)];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(clickedPlayerBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.playerView addSubview:self.playBtn];
    
    WEAK_SELF
    [self.overlayContentView setOverlayTapAction:^(QHVCEditMatrixItem *item)
     {
        STRONG_SELF
        [self.overlayBottomView showOverlayToolsView:item];
         [self playerStop];
    }];
    
    [self.overlayContentView setPlayerNeedRefreshAction:^(BOOL forceRefresh)
    {
        STRONG_SELF
        [self refreshPlayer:forceRefresh];
    }];
}

- (void)clickedPlayerBtn
{
//    //获取视频帧，test
//    UIImage* image = [_player getCurrentFrameOfOverlayCommandId:2];
    
    if ([self isPlaying])
    {
        [self playerStop];
    }
    else
    {
        [self playerPlay];
    }
}

- (void)playerPlay
{
    [self play];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
}

- (void)playerStop
{
    [self stop];
    [self.playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
}

- (void)playerRenderFirstFrame
{
    [self playerPlay];
}

- (void)playerComplete
{
    [self seekTo:0];
    [self playerStop];
}

@end
