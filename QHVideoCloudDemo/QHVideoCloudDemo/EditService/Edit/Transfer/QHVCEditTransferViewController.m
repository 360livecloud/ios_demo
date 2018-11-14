//
//  QHVCEditTransferViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTransferViewController.h"
#import "QHVCEditTransferView.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditSegmentItem.h"
#import "QHVCEditViewController.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditPhotoManager.h"

@interface QHVCEditTransferViewController ()
{
    QHVCEditTransferView *_transferView;
    NSArray<NSArray *> *_transferEffects;
    NSMutableArray<QHVCEditSegmentItem *> *_segments;
    NSMutableArray<QHVCEditPhotoItem *> *_photoList;
    BOOL _hasEffect;
}

@end

@implementation QHVCEditTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"转场";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    _transferEffects = @[@[@"无",@"edit_transfer_un", @"none"],
                         @[@"效果1",@"edit_transfer_dissolution", @"transition_1"],
                         @[@"效果2",@"edit_transfer_aperture", @"transition_2"],
                         @[@"效果3",@"edit_transfer_swipeToRight", @"transition_3"],
                         @[@"效果4",@"edit_transfer_swipeToLeft", @"transition_4"],
                         @[@"效果5",@"edit_transfer_swipeToTop", @"transition_5"],
                         @[@"效果6",@"edit_transfer_swipeToBottom", @"transition_6"],
                         @[@"效果7",@"edit_transfer_moveToRight", @"transition_7"],
                         @[@"效果8",@"edit_transfer_moveToLeft", @"transition_8"],
                         @[@"效果9",@"edit_transfer_moveToTop", @"transition_9"],
                         @[@"效果10",@"edit_transfer_moveToBottom", @"transition_10"]];
//                   @[@"溶解",@"edit_transfer_dissolution"],
//                   @[@"光圈",@"edit_transfer_aperture"],
//                   @[@"向右轻擦",@"edit_transfer_swipeToRight"],
//                   @[@"向左轻擦",@"edit_transfer_swipeToLeft"],
//                   @[@"向上轻擦",@"edit_transfer_swipeToTop"],
//                   @[@"向下轻擦",@"edit_transfer_swipeToBottom"],
//                   @[@"向右滑动",@"edit_transfer_moveToRight"],
//                   @[@"向左滑动",@"edit_transfer_moveToLeft"],
//                   @[@"向上滑动",@"edit_transfer_moveToTop"],
//                   @[@"向下滑动",@"edit_transfer_moveToBottom"],
//                   @[@"淡化",@"edit_transfer_fade"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createTransferView];
    [self fetchSegmentInfos];
    _sliderViewBottom.constant = 70;
}

- (void)nextAction:(UIButton *)btn
{
    [self releasePlayerVC];
}

- (void)backAction:(UIButton *)btn
{
    [self releasePlayerVC];
}

- (void)fetchSegmentInfos
{
    __weak typeof(self) weakSelf = self;
    [[QHVCEditCommandManager manager] fetchSegmentInfo:^(NSArray<QHVCEditSegmentInfo *> *segments, NSInteger totalDurationMs) {
//        [weakSelf handleSegmentInfo:segments];
        weakSelf.durationMs = totalDurationMs;
    }];
    
    NSArray<QHVCEditCommandAddFileSegment *>* segments = [[QHVCEditCommandManager manager] getFileSegments];
    [self handleSegmentInfo:segments];
}

- (void)handleSegmentInfo:(NSArray<QHVCEditCommandAddFileSegment *> *)segments
{
    if (!_segments) {
        _segments = [NSMutableArray array];
    }
    __block NSMutableArray<QHVCEditThumbnailItem *> *thumbs = [NSMutableArray array];

    for (QHVCEditCommandAddFileSegment *item in segments) {
        [[QHVCEditCommandManager manager] fetchThumbs:item.filePath start:0.0 end:1000 frameCnt:1 thumbSize:CGSizeMake(200, 100) completion:^(NSArray<QHVCEditThumbnailItem *> *thumbnails) {
            
            [thumbs addObject:thumbnails[0]];
            if (thumbs.count == segments.count) {
                [self handleThumbsInfo:thumbs segments:segments];
            }
        }];
    }
}

- (void)handleThumbsInfo:(NSArray<QHVCEditThumbnailItem *> *)thumbs segments:(NSArray<QHVCEditCommandAddFileSegment *> *)segments
{
    NSTimeInterval start = 0;
    NSInteger i = 0;
    for (QHVCEditThumbnailItem *thumb in thumbs) {
        NSPredicate *apredicate=[NSPredicate predicateWithFormat: @"filePath = %@", thumb.videoPath];
        NSArray<QHVCEditSegmentItem *> *segmentItems = [_segments filteredArrayUsingPredicate:apredicate];
        if (segmentItems.count > 0) {
            start = segmentItems[0].segmentEndTime;
            i++;
            continue;
        }
        NSArray<QHVCEditCommandAddFileSegment *> *segs = [segments filteredArrayUsingPredicate:apredicate];
        if (segs.count > 0) {
            QHVCEditSegmentItem *item = [[QHVCEditSegmentItem alloc] init];
            item.filePath = segs[0].filePath;
            item.fileDuration = segs[0].endTimestampMs - segs[0].startTimestampMs;
            item.segmentStartTime = start;
            item.segmentEndTime = item.segmentStartTime + item.fileDuration;
            item.thumbnail = thumb.thumbnail;
            item.segmentIndex = i;
            item.slowMotionVideoInfos = segs[0].slowMotionVideoInfos;
            [_segments addObject:item];
            start = item.segmentEndTime;
            i++;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_transferView updateView:_transferEffects segments:_segments];
    });
}

- (void)createTransferView
{
    if (!_transferView) {
        _transferView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditTransferView class] description] owner:self options:nil][0];
        _transferView.frame = CGRectMake(0, kScreenHeight - 160, kScreenWidth, 160);
        __weak typeof(self) weakSelf = self;
        _transferView.addCompletion = ^{
            [weakSelf showPhotoVC];
        };
        _transferView.transferCompletion = ^{
            [weakSelf handleStopPlayer];
        };
        [self.view addSubview:_transferView];
    }
}

- (void)showPhotoVC
{
    QHVCEditViewController *vc = [[QHVCEditViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    vc.completion = ^(NSArray<QHVCEditPhotoItem *> *items) {
        [weakSelf handleAddAction:items];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleAddAction:(NSArray<QHVCEditPhotoItem *> *)items
{
    if (!_photoList) {
        _photoList = [NSMutableArray arrayWithArray:[QHVCEditPrefs sharedPrefs].photosList];
    }
    [[QHVCEditPhotoManager manager] writeAssetsToSandbox:items complete:^{
        [_photoList addObjectsFromArray:items];
        [[QHVCEditCommandManager manager] appendFiles:items];
        
        QHVCEditSegmentItem *item = [_segments lastObject];
        
        [self fetchSegmentInfos];
        [_transferView updateView:_transferEffects segments:_segments];
        
        [self freshDurationView];
        [self resetPlayer:0.0];
    }];
}

- (void)handleStopPlayer
{
    _hasEffect = YES;
    [self setPlayerStatus:QHVCEditPlayStatusStop];
}

- (void)playBtnCallback:(QHVCEditPlayStatus)status
{
    if (status == QHVCEditPlayStatusPlay && _hasEffect) {
        [[QHVCEditCommandManager manager] addTransfers:_segments];
        [self resetPlayer:0.0];
        _hasEffect = NO;
    }
    [self setPlayerStatus:status];
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

@end
