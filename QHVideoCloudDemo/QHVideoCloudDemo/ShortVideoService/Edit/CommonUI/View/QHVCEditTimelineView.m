//
//  QHVCEditTimelineView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTimelineView.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import "QHVCEditPlayerBaseVC.h"

#define kFrameCnt 4
#define kCellWidth 40.0
#define kCellHeight 40.0
#define kTimelineTimerInterval 0.05
#define kThumbnailCacheCount 60
#define kThumbnailOffsetDuration 5000
#define kThumbnailInterval 1000.0

static NSString * const frameCellIdentifier = @"QHVCEditFrameCell";

@interface QHVCEditTimelineView() <UIScrollViewDelegate>
{
    __weak IBOutlet UIButton* _playBtn;
    __weak IBOutlet UIButton* _addBtn;
    __weak IBOutlet UILabel* _nowLabel;
    __weak IBOutlet UILabel* _endLabel;
}

@property (nonatomic, strong) dispatch_queue_t thumbnailQueue;
@property (nonatomic, strong) NSMutableArray<QHVCEditTrackClipItem *>* clipArray;
@property (atomic,    strong) NSMutableDictionary<NSNumber*, QHVCEditThumbnailItem *>* thumbnailCache;
@property (nonatomic, assign) NSInteger currentTime;
@property (nonatomic, assign) NSInteger totoalDuration;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isDraging;
@property (nonatomic, assign) BOOL isPlayComplete;
@property (nonatomic, assign) NSTimer* timelineTimer;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, assign) CGFloat lastUpdateOffset;
@property (nonatomic, assign) NSInteger lastPlayerTime;
@property (nonatomic, assign) CGFloat initialInsetLeft;

@end

@implementation QHVCEditTimelineView

#pragma mark - Life Circle Methods

- (void)dealloc
{
    [self stopTimelineTimer];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_collectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    self.clipArray = [[QHVCEditMediaEditor sharedInstance] getMainTrackClips];;
    _thumbnailQueue = dispatch_queue_create("ThumbnailQueue", NULL);
    _currentTime = 0;
    _totoalDuration = [[QHVCEditMediaEditor sharedInstance] getTimelineDuration];
    _nowLabel.text = [QHVCEditPrefs timeFormatMs:0];
    _endLabel.text = [QHVCEditPrefs timeFormatMs:_totoalDuration];
    _thumbnailCache = [NSMutableDictionary dictionary];
}

- (void)layoutSubviews
{
    self.initialInsetLeft = (CGRectGetWidth(self.frame) - 50.0)/2.0 - 5;
    [_collectionView setContentInset:UIEdgeInsetsMake(0, self.initialInsetLeft, 0, self.initialInsetLeft)];
    [_collectionView reloadData];
}

#pragma mark - Thumbnail Methods

- (void)fetchThumbsOfIndex:(NSInteger)index complete:(void(^)(QHVCEditThumbnailItem* thumbnailItem))complete
{
    NSInteger time = index * kThumbnailInterval;
    QHVCEditThumbnailItem* thumbnailItem = [self.thumbnailCache objectForKey:@(time)];
    if (thumbnailItem)
    {
        SAFE_BLOCK(complete, thumbnailItem);
    }
    else
    {
        WEAK_SELF
        dispatch_async(self.thumbnailQueue, ^{
            STRONG_SELF
            
            __block NSInteger insertTime = 0;
            [self.clipArray enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
             {
                 if (insertTime <= time && (insertTime + obj.clip.duration) >= time)
                 {
                     NSInteger realTime = (time - insertTime) * obj.clip.speed + obj.clip.fileStartTime;
                     if (![[QHVCEditMediaEditorConfig sharedInstance] usePhotoIdentifier])
                     {
                         [[QHVCEditMediaEditor sharedInstance] requestThumbFromFilePath:obj.filePath
                                                                              timestamp:realTime
                                                                              thumbSize:CGSizeMake(200, 400) thumbCallback:^(QHVCEditThumbnailItem *thumbnail)
                          {
                              SAFE_BLOCK(complete, thumbnail);
                              [self.thumbnailCache setObject:thumbnail forKey:@(time)];
                          }];
                     }
                     else
                     {
                         [[QHVCEditMediaEditor sharedInstance] requestThumbFromFileIdentifier:obj.fileIdentifier
                                                                                    timestamp:realTime
                                                                                    thumbSize:CGSizeMake(200, 400) thumbCallback:^(QHVCEditThumbnailItem *thumbnail)
                         {
                             SAFE_BLOCK(complete, thumbnail);
                             [self.thumbnailCache setObject:thumbnail forKey:@(time)];
                         }];
                     }
                     
                     *stop = YES;
                 }
                 insertTime += obj.clip.duration;
             }];
        });
    }
    
    if ([self.thumbnailCache count] > kThumbnailCacheCount)
    {
        NSMutableArray* keys = [NSMutableArray array];
        NSInteger offset = [self.thumbnailCache count] - kThumbnailCacheCount;
        __block NSInteger count = 0;
        
        [self.thumbnailCache enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QHVCEditThumbnailItem * _Nonnull obj, BOOL * _Nonnull stop)
        {
            if (labs([key integerValue] - time) > kThumbnailCacheCount * kThumbnailInterval / 2.0)
            {
                [keys addObject:key];
                count ++;
            }
            
            if (count == offset)
            {
                *stop = YES;
            }
        }];
        
        [self.thumbnailCache removeObjectsForKeys:keys];
    }
}

#pragma mark - Event Response Methods

- (IBAction)touchedPlayBtn:(id)sender
{
    if (self.isPlaying)
    {
        self.lastUpdateTime = [self currentTimestamp];
        self.lastUpdateOffset = _collectionView.contentOffset.x;
    }
}

- (IBAction)clickedPlayBtn:(UIButton *)sender
{
    if (self.isPlayComplete)
    {
        //播放完成
        [self playFromZeroAction];
    }
    else
    {
        if (!self.isPlaying)
        {
            [self play];
        }
        else
        {
            [self pause];
        }
    }
}

- (void)play
{
    SAFE_BLOCK(self.playAction);
    [self.playerBaseVC play];
    [_playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
    [self createTimelineTimer];
    self.lastUpdateTime = [self currentTimestamp];
    self.lastUpdateOffset = _collectionView.contentOffset.x;
    self.lastPlayerTime = self.currentTime;
    self.isPlaying = YES;
    self.isPlayComplete = NO;
    self.isDraging = NO;
}

- (void)pause
{
    SAFE_BLOCK(self.pauseAction);
    [self.playerBaseVC stop];
    [_playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
    self.isPlaying = NO;
    self.isPlayComplete = NO;
    [self stopTimelineTimer];
}

- (void)playFromZeroAction
{
    WEAK_SELF
    [self.playerBaseVC seekTo:0 complete:^{
        STRONG_SELF
        [self->_collectionView setContentOffset:CGPointMake(-self.initialInsetLeft, 0)];
        [self play];
    }];
}

- (void)createTimelineTimer
{
    if (!_timelineTimer)
    {
        _timelineTimer = [NSTimer scheduledTimerWithTimeInterval:kTimelineTimerInterval target:self selector:@selector(updateTimelineView) userInfo:nil repeats:YES];
    }
}

- (void)stopTimelineTimer
{
    if (_timelineTimer)
    {
        [_timelineTimer invalidate];
        _timelineTimer = nil;
    }
}

- (NSTimeInterval)currentTimestamp
{
    NSDate* currentDate = [NSDate date];
    NSTimeInterval currentTimeStamp = [currentDate timeIntervalSince1970];
    return currentTimeStamp;
}

- (void)updateTimelineView
{
    if (!self.isPlaying)
    {
        return;
    }
    
    NSTimeInterval curTimestamp = [self currentTimestamp];
    CGFloat timeOffset = curTimestamp - self.lastUpdateTime;

    if (self.currentTime >= self.totoalDuration)
    {
        [self pause];
        timeOffset = (self.totoalDuration - self.lastPlayerTime) / 1000.0;
        self.currentTime = self.totoalDuration;
        self.isPlayComplete = YES;
    }

    CGFloat x = self.lastUpdateOffset + timeOffset * kCellWidth;
    [_collectionView setContentOffset:CGPointMake(x, 0) animated:NO];
}


- (BOOL)isFrameHighlight:(NSInteger)index
{
    return NO;
}

#pragma mark - UICollection Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = ceil(self.totoalDuration / kThumbnailInterval);
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __block QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
    [cell updateCell:nil highlightViewType:QHVCEditFrameHighlightViewTypeNone];
    [self fetchThumbsOfIndex:indexPath.row complete:^(QHVCEditThumbnailItem *thumbnailItem)
    {
        SAFE_BLOCK_IN_MAIN_QUEUE(^{
            [cell updateCell:thumbnailItem.thumbnail highlightViewType:QHVCEditFrameHighlightViewTypeNone];
        });
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger maxNum = ceil(self.totoalDuration / kThumbnailInterval);
    if (indexPath.row == maxNum - 1)
    {
        CGFloat x = kCellWidth * (1 - (maxNum * kThumbnailInterval - self.totoalDuration)/kThumbnailInterval);
        return CGSizeMake(x, kCellHeight);
    }
    else
    {
        return CGSizeMake(kCellWidth, kCellHeight);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.isPlaying)
    {
        [self pause];
    }
    
    CGPoint offset = scrollView.contentOffset;
    (scrollView.contentOffset.x > 0) ? offset.x-- : offset.x++;
    [scrollView setContentOffset:offset animated:NO];
    self.isDraging = YES;
    self.isPlayComplete = NO;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.playerBaseVC seekTo:self.currentTime forceRequest:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.playerBaseVC seekTo:self.currentTime forceRequest:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.currentTime = floor(_collectionView.contentOffset.x + self.initialInsetLeft) * 1000.0/ kCellWidth;
    self.currentTime = MIN(self.totoalDuration, MAX(0, self.currentTime));
    _nowLabel.text = [QHVCEditPrefs timeFormatMs:MAX(self.currentTime, 0)];
    
    if (self.currentTime >= self.totoalDuration)
    {
        self.isPlayComplete = YES;
    }
    
    if (self.isDraging)
    {
        [self.playerBaseVC seekTo:self.currentTime forceRequest:NO];
    }
    else if(self.isPlaying)
    {
        SAFE_BLOCK(self.playingAction, self.currentTime)
    }
}

- (NSInteger)timelineTimestamp
{
    return self.currentTime;
}

@end
