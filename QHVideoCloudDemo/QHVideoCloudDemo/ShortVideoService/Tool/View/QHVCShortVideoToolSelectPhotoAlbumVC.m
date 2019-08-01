//
//  QHVCShortVideoToolSelectPhotoAlbumVC.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/23.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCShortVideoToolSelectPhotoAlbumVC.h"
#import "QHVCShortVideoPhotoItemCell.h"
#import "QHVCShortVideoPhotoSelectedCell.h"
#import "QHVCPhotoManager.h"
#import "QHVCPhotoItem.h"
#import "UIView+Toast.h"
#import "QHVCShortVideoMacroDefs.h"

#define kNumsInLine 4
#define kLines 2
#define kVSpace 1
#define kHSpece 1

static NSString * const videoItemCellIdentifier = @"QHVCShortVideoPhotoItemCell";
static NSString * const selectedCellIdentifier = @"QHVCShortVideoPhotoSelectedCell";

@interface QHVCShortVideoToolSelectPhotoAlbumVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *selectedCollectionView;

@property (nonatomic, readwrite, strong) NSMutableArray<QHVCPhotoItem *>* selectedLists;
@property (nonatomic, strong) NSMutableArray<QHVCPhotoItem *>* videoLists;
@property (nonatomic, strong) NSMutableArray<PHAsset *>* videoCacheLists;
@property (nonatomic, assign) CGSize photoCellSize;
@property (nonatomic, assign) CGRect previousPreheatRect;

@end

@implementation QHVCShortVideoToolSelectPhotoAlbumVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"相册视频"];
    [self.topConstraint setConstant:[self topBarHeight]];
    
    //content view
    [_videoCollectionView registerNib:[UINib nibWithNibName:videoItemCellIdentifier bundle:nil] forCellWithReuseIdentifier:videoItemCellIdentifier];
    [_selectedCollectionView registerNib:[UINib nibWithNibName:selectedCellIdentifier bundle:nil] forCellWithReuseIdentifier:selectedCellIdentifier];
    _videoCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    
    //fetch data
    _videoLists = [NSMutableArray array];
    _videoCacheLists = [NSMutableArray array];
    _selectedLists = [NSMutableArray array];
    
    WEAK_SELF
    [[QHVCPhotoManager manager] requestAuthorization:^(BOOL granted)
     {
         STRONG_SELF
         if (granted)
         {
             [[QHVCPhotoManager manager] fetchAllVideos:^(NSArray<QHVCPhotoItem *> *items, NSArray<PHAsset *> *caches)
              {
                  [self.videoLists addObjectsFromArray:items];
                  [self.videoCacheLists addObjectsFromArray:caches];
                  [self.videoCollectionView reloadData];
              }];
         }
     }];
}

- (void)backAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction:(UIButton *)btn
{
    if (self.completion)
    {
        [[QHVCPhotoManager manager] addAssetIdentifier:_selectedLists];
        self.completion(_selectedLists);
    }
}

#pragma mark - UICollectionView

- (CGSize)photoCellSize
{
    if(CGSizeEqualToSize(CGSizeZero, _photoCellSize))
    {
        CGFloat width = floorf((SCREEN_SIZE.width - 3*kHSpece)/kNumsInLine);
        CGFloat height = width;
        _photoCellSize = CGSizeMake(width, height);
    }
    return _photoCellSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   if (collectionView == _videoCollectionView)
    {
        return self.videoLists.count;
    }
    else if (collectionView == _selectedCollectionView)
    {
        return self.selectedLists.count;
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kVSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kHSpece;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _videoCollectionView)
    {
        QHVCShortVideoPhotoItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:videoItemCellIdentifier forIndexPath:indexPath];
        QHVCPhotoItem *item = self.videoLists[indexPath.row];
        item.thumbImageCacheSize = CGSizeMake(self.photoCellSize.width * 2, self.photoCellSize.height * 2);
        [cell updateCell:item];
        return cell;
    }
    else if (collectionView == _selectedCollectionView)
    {
        QHVCShortVideoPhotoSelectedCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectedCellIdentifier forIndexPath:indexPath];
        QHVCPhotoItem *item = self.selectedLists[indexPath.row];
        
        WEAK_SELF
        cell.deleteCompletion = ^(QHVCPhotoItem *item)
        {
            STRONG_SELF
            [self deleteSelectedPhoto:item];
        };
        [cell updateCell:item];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _videoCollectionView)
    {
        return self.photoCellSize;
    }
    else
    {
        return CGSizeMake(80, 80);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCPhotoItem *item = nil;
    if (collectionView == _videoCollectionView)
    {
        item = _videoLists[indexPath.row];
    }
    
    if (self.maxCount > 0 && ([self.selectedLists count] >= self.maxCount) && !item.isSelected)
    {
        return;
    }
    
    if (item)
    {
        [self updateSelectList:item];
        [_videoCollectionView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _videoCollectionView)
    {
        [self updateCachedAssets:self.videoCollectionView cacheList:self.videoCacheLists];
    }
}

#pragma mark - Photo Methods

- (void)updateSelectList:(QHVCPhotoItem *)item
{
    item.isSelected = !item.isSelected;
    if (item.isSelected)
    {
        [_selectedLists addObject:item];
    }
    else
    {
        [_selectedLists removeObject:item];
    }
    
    if (_selectedLists.count > 0)
    {
        [_selectedCollectionView reloadData];
        _selectedCollectionView.hidden = NO;
    }
    else
    {
        _selectedCollectionView.hidden = YES;
    }
}

- (void)deleteSelectedPhoto:(QHVCPhotoItem *)item
{
    [_selectedLists removeObject:item];
    item.isSelected = !item.isSelected;
    if (_selectedLists.count > 0)
    {
        [_selectedCollectionView reloadData];
    }
    else
    {
        _selectedCollectionView.hidden = YES;
    }
    [_videoCollectionView reloadData];
}

- (void)updateCachedAssets:(UICollectionView *)collectionView cacheList:(NSArray<PHAsset *>*)cacheList
{
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(collectionView.bounds) / 3.0f)
    {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect) {
                                NSArray *indexPaths = [self computeIndexPathsForElementsInRect:removedRect collectionView:collectionView];
                                [removedIndexPaths addObjectsFromArray:indexPaths];
                            }
                              addedHandler:^(CGRect addedRect) {
                                  NSArray *indexPaths = [self computeIndexPathsForElementsInRect:addedRect collectionView:collectionView];
                                  [addedIndexPaths addObjectsFromArray:indexPaths];
                              }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths cacheList:cacheList];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths cacheList:cacheList];
        
        // Update the assets the PHCachingImageManager is caching.
        CGSize photoCellSize = [self photoCellSize];
        CGSize cacheSize = CGSizeMake(photoCellSize.width * 2, photoCellSize.height * 2);
        [[QHVCPhotoManager manager] cacheImageForAssets:assetsToStartCaching targetSize:cacheSize];
        [[QHVCPhotoManager manager] stopImageCacheForAssets:assetsToStopCaching targetSize:[self photoCellSize]];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect
                             andRect:(CGRect)newRect
                      removedHandler:(void (^)(CGRect removedRect))removedHandler
                        addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)computeIndexPathsForElementsInRect:(CGRect)rect collectionView:(UICollectionView *)collectionView
{
    NSArray *allLayoutAttributes = [collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) {
        return nil;
    }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths cacheList:(NSArray<PHAsset *> *)cacheList
{
    if (indexPaths.count == 0)
    {
        return nil;
    }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths)
    {
        PHAsset* asset = [cacheList objectAtIndex:indexPath.row];
        [assets addObject:asset];
    }
    
    return assets;
}

@end
