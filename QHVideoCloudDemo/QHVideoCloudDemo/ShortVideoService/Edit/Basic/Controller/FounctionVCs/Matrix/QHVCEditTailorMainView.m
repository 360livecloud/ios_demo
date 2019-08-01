//
//  QHVCEditTailorMainView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTailorMainView.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditTailorFormatView.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditTrackClipItem.h"
#import "UIView+Toast.h"

@interface QHVCEditTailorMainView()
{
    __weak IBOutlet UICollectionView *_collectionView;
    NSArray<NSString *> *_tabsArray;
}

@property (nonatomic, retain) NSArray<QHVCEditTrackClipItem *>* clips;
@property (nonatomic, assign) CGFloat initialRadian;
@property (nonatomic, assign) BOOL initialFlipY;
@property (nonatomic, assign) BOOL initialFlipX;

@end

static NSString * const tabCellIdentifier = @"QHVCEditFrameCell";

@implementation QHVCEditTailorMainView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_collectionView registerNib:[UINib nibWithNibName:tabCellIdentifier bundle:nil] forCellWithReuseIdentifier:tabCellIdentifier];
    _tabsArray = @[@"edit_tailor_restore",
                   @"edit_tailor_rotate",
                   @"edit_tailor_u_d",
                   @"edit_tailor_l_r",
                   @"edit_tailor_format"];
    [_collectionView reloadData];
    _clips = [[QHVCEditMediaEditor sharedInstance] getMainTrackClips];
    _initialRadian = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackClipsRadian];
    _initialFlipY = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackClipsFlipY];
    _initialFlipX = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackClipsFlipX];
}

- (void)confirmAction
{
    SAFE_BLOCK(self.confirmBlock, self);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tabsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:tabCellIdentifier forIndexPath:indexPath];
    [cell updateCell:[UIImage imageNamed:_tabsArray[indexPath.row]] highlightViewType:QHVCEditFrameHighlightViewTypeNone];
    [cell setImageFillMode:UIViewContentModeScaleToFill];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return CGSizeMake(58, 28);
    }
    return CGSizeMake(30, 30);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 20;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 30;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleTailorAction:indexPath.row];
}

#pragma mark - 裁剪事件

- (void)handleTailorAction:(NSInteger)index
{
    switch (index)
    {
        case 0:
        {
            //还原
            [self onRestoreAction];
            break;
        }
        case 1:
        {
            //旋转
            [self onRotateAction];
            break;
        }
        case 2:
        {
            //上下镜像
            [self onFlipYAction];
            break;
        }
        case 3:
        {
            //左右镜像
            [self onFlipXAction];
            break;
        }
        case 4:
        {
            //填充方式、背景颜色
            [self onFillFormatAction];
            break;
        }
        case 5:
        {
            //视频源裁剪
            [self makeToast:@"demo功能未开放"];
            break;
        }
        default:
            break;
    }
}

- (void)onRestoreAction
{
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackClipsRadian:_initialRadian];
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackClipsFlipX:_initialFlipX];
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackClipsFlipY:_initialFlipY];
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackFillModeIndex:kDefaultFillModeIndex];
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackBgColorIndex:kDefaultBgColorIndex];
    [_clips enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [obj.clip setFlipX:self->_initialFlipX];
        [obj.clip setFlipY:self->_initialFlipY];
    }];
    QHVCEditTrack* mainTrack = [[QHVCEditMediaEditor sharedInstance] mainTrack];
    [mainTrack.renderInfo setRenderRadian:_initialRadian];
    mainTrack.renderInfo = nil;
    SAFE_BLOCK(self.refreshPlayerBlock, YES);
}

- (void)onRotateAction
{
    CGFloat radian = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackClipsRadian];
    radian += M_PI_2;
    if (radian > M_PI*2)
    {
        radian -= M_PI*2;
    }
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackClipsRadian:radian];
    QHVCEditTrack* mainTrack = [[QHVCEditMediaEditor sharedInstance] mainTrack];
    QHVCEditRenderInfo* renderInfo = [mainTrack renderInfo];
    if (!renderInfo)
    {
        renderInfo = [QHVCEditRenderInfo new];
        [mainTrack setRenderInfo:renderInfo];
    }
    
    [renderInfo setRenderRadian:radian];
    SAFE_BLOCK(self.refreshPlayerBlock, YES);
}

- (void)onFlipYAction
{
    BOOL flipY = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackClipsFlipY];
    flipY = !flipY;
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackClipsFlipY:flipY];
    [_clips enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [obj.clip setFlipY:flipY];
    }];
    SAFE_BLOCK(self.refreshPlayerBlock, YES);
}

- (void)onFlipXAction
{
    BOOL flipX = [[QHVCEditMediaEditorConfig sharedInstance] mainTrackClipsFlipX];
    flipX = !flipX;
    [[QHVCEditMediaEditorConfig sharedInstance] setMainTrackClipsFlipX:flipX];
    [_clips enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [obj.clip setFlipX:flipX];
    }];
    SAFE_BLOCK(self.refreshPlayerBlock, YES);
}

- (void)onFillFormatAction
{
    QHVCEditTailorFormatView* formatView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditTailorFormatView class] description] owner:self options:nil][0];
    formatView.frame = CGRectMake(0, 0, kScreenWidth, 140);
    [self addSubview:formatView];
    
    WEAK_SELF
    [formatView setRefreshPlayerBlock:^{
        STRONG_SELF
        SAFE_BLOCK(self.refreshPlayerBlock, YES);
    }];
}

@end
