//
//  QHVCEditTransitionView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTransitionView.h"
#import "QHVCEditTrackClipCell.h"
#import "QHVCEditMainFunctionCell.h"
#import "QHVCEditTrackClipItem.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "UIView+Toast.h"
#import "QHVCEditPlayerBaseVC.h"

static NSString * const effectCellIdentifier = @"QHVCEditMainFunctionCell";
static NSString * const clipCellIdentifier = @"QHVCEditTrackClipCell";

@interface QHVCEditTransitionView()
{
    __weak IBOutlet UICollectionView *_effectCollectionView;
    __weak IBOutlet UICollectionView *_segmentCollectionView;
}

@property (nonatomic, strong) NSMutableArray<NSArray *> *effects;
@property (nonatomic, strong) NSArray<QHVCEditTrackClipItem *> *clips;
@property (nonatomic, retain) QHVCEditTrackClipItem* curClip;

@end

@implementation QHVCEditTransitionView

#pragma mark - Event Methods

- (void)confirmAction
{
    SAFE_BLOCK(self.confirmBlock, self);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_effectCollectionView registerNib:[UINib nibWithNibName:effectCellIdentifier bundle:nil] forCellWithReuseIdentifier:effectCellIdentifier];
    [_segmentCollectionView registerNib:[UINib nibWithNibName:clipCellIdentifier bundle:nil] forCellWithReuseIdentifier:clipCellIdentifier];

    NSString* path = [[NSBundle mainBundle] pathForResource:@"QHVCEditTransitionList" ofType:@"plist"];
    NSArray* array = [NSArray arrayWithContentsOfFile:path];
    _effects = [NSMutableArray arrayWithArray:array];
#ifdef QHVCADVANCED
    NSString* advancedPath = [[NSBundle mainBundle] pathForResource:@"QHVCEditTransitionList+Advanced" ofType:@"plist"];
    NSArray* advancedArray = [NSArray arrayWithContentsOfFile:advancedPath];
    if ([advancedArray count] > 0)
    {
        [_effects addObjectsFromArray:advancedArray];
    }
#endif
    
    _clips = [[QHVCEditMediaEditor sharedInstance] getMainTrackClips];
    [_effectCollectionView reloadData];
    [_segmentCollectionView reloadData];
    [_effectCollectionView setHidden:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _effectCollectionView) {
        return _effects.count;
    }
    else if (collectionView == _segmentCollectionView)
    {
        return _clips.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _effectCollectionView)
    {
        QHVCEditMainFunctionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:effectCellIdentifier forIndexPath:indexPath];
        if (indexPath.row < [_effects count])
        {
            [cell updateCell:_effects[indexPath.row]];
        }
        return cell;
    }
    else if (collectionView == _segmentCollectionView)
    {
        QHVCEditTrackClipCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:clipCellIdentifier forIndexPath:indexPath];
        WEAK_SELF
        cell.selectedCompletion = ^(QHVCEditTrackClipItem *item)
        {
            STRONG_SELF
            [self updateClipIndex:item];
        };
        
        QHVCEditTrackClipItem *item = _clips[indexPath.row];
        [cell updateCell:item canAddTransfer:(indexPath.row != 0)];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _effectCollectionView) {
        return CGSizeMake(55, 70);
    }
    return CGSizeMake(115, 80);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _effectCollectionView)
    {
        [self updateTransfer:indexPath.row];
        [_segmentCollectionView setHidden:NO];
        [_effectCollectionView setHidden:YES];
    }
}

#pragma mark - Update Transfer Methods

- (void)updateClipIndex:(QHVCEditTrackClipItem *)item
{
    self.curClip = item;
    [_segmentCollectionView setHidden:YES];
    [_effectCollectionView setHidden:NO];
}

- (void)updateTransfer:(NSInteger)effectIndex
{
    if (effectIndex == 0)
    {
        //无
        if ([self.curClip hasTransition])
        {
            [[QHVCEditMediaEditor sharedInstance] mainTrackDeleteTransition:self.curClip.clipIndex];
        }
        [self.curClip setHasTransition:NO];
        [self.curClip setTransitionName:@""];
    }
    else
    {
        //更新转场效果
        NSString* transitionName = @"";
        if ([_effects count] > effectIndex)
        {
            transitionName = _effects[effectIndex][2];
        }
        
        QHVCEditTrackClipItem* preClip = nil;
        if ((self.curClip.clipIndex >= 1) && ([_clips count] > self.curClip.clipIndex - 1))
        {
            preClip = _clips[self.curClip.clipIndex - 1];
        }
        
        NSInteger preClipDuration = preClip.endMs - preClip.startMs;
        NSInteger curClipDuration = self.curClip.endMs - self.curClip.startMs;
        NSInteger transferDuration = MIN(kTransferMaxDuration, MAX(preClipDuration, curClipDuration)/3.0);
        
        if ([self.curClip hasTransition])
        {
            [[QHVCEditMediaEditor sharedInstance] mainTrackUpdateTransition:self.curClip.clipIndex duration:transferDuration transitionName:transitionName easingFunctionType:QHVCEditEasingFunctionTypeLinear];
        }
        else
        {
            [[QHVCEditMediaEditor sharedInstance] mainTrackAddTransition:self.curClip.clipIndex duration:transferDuration transitionName:transitionName easingFunctionType:QHVCEditEasingFunctionTypeLinear];
        }
        [self.curClip setHasTransition:YES];
        [self.curClip setTransitionName:transitionName];
    }
    
    BOOL isPlaying = [self.playerBaseVC isPlaying];
    SAFE_BLOCK(self.resetPlayerBlock);
    SAFE_BLOCK(self.updatePlayerDuraionBlock);
    if (isPlaying)
    {
        SAFE_BLOCK(self.playPlayerBlock);
    }
    [_segmentCollectionView reloadData];
}

@end
