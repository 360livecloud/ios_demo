//
//  QHVCEditSelectPhotoAlbumVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSelectPhotoAlbumVC.h"
#import "QHVCShortVideoPhotoItemCell.h"
#import "QHVCPhotoManager.h"
#import "QHVCPhotoItem.h"
#import "QHVCShortVideoPhotoSelectedCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditSetOutputParamsVC.h"
#import "UIView+Toast.h"

#define kNumsInLine 4
#define kLines 2
#define kVSpace 1
#define kHSpece 1

static NSString * const videoItemCellIdentifier = @"QHVCEditVideoItemCell";
static NSString * const photoItemCellIdentifier = @"QHVCShortVideoPhotoItemCell";
static NSString * const selectedCellIdentifier = @"QHVCShortVideoPhotoSelectedCell";

@interface QHVCEditSelectPhotoAlbumVC () <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIView *urlView;
@property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *selectedCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@property (nonatomic, retain) UIView* videoBtnLine;
@property (nonatomic, retain) UIView* photoBtnLine;
@property (nonatomic, retain) UIView* urlBtnLine;
@property (nonatomic, readwrite, strong) NSMutableArray<QHVCPhotoItem *>* selectedLists;
@property (nonatomic, strong) NSMutableArray<QHVCPhotoItem *>* videoLists;
@property (nonatomic, strong) NSMutableArray<PHAsset *>* videoCacheLists;
@property (nonatomic, strong) NSMutableArray<QHVCPhotoItem *>* photoLists;
@property (nonatomic, strong) NSMutableArray<PHAsset *>* photoCacheLists;
@property (nonatomic, assign) CGSize photoCellSize;
@property (nonatomic, assign) CGRect previousPreheatRect;

@end

@implementation QHVCEditSelectPhotoAlbumVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //custom top view
    UIView* customTopBarView = [[UIView alloc] initWithFrame:CGRectMake(70,
                                                                        CGRectGetHeight(self.topBarView.frame) - 40,
                                                                        kScreenWidth - 160, 40)];
    [customTopBarView setBackgroundColor:[UIColor clearColor]];
    [self.topBarView addSubview:customTopBarView];
    
    //video button view
    UIView* videoBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(customTopBarView.frame)/3.0, 40)];
    self.videoBtnLine = [[UIView alloc] initWithFrame:CGRectMake(0, 38, CGRectGetWidth(videoBtnView.frame), 1)];
    [self.videoBtnLine setBackgroundColor:[QHVCEditPrefs colorHighlight]];
    UIButton* videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(videoBtnView.frame), 38)];
    [videoBtn setTitle:@"视频" forState:UIControlStateNormal];
    [videoBtn setTintColor:[UIColor whiteColor]];
    [videoBtn addTarget:self action:@selector(clickedVideoTab) forControlEvents:UIControlEventTouchUpInside];
    [videoBtnView addSubview:videoBtn];
    [videoBtnView addSubview:self.videoBtnLine];
    [customTopBarView addSubview:videoBtnView];
    
    //photo button view
    UIView* photoBtnView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(customTopBarView.frame)/3.0, 0,
                                                                    CGRectGetWidth(customTopBarView.frame)/3.0, 40)];
    self.photoBtnLine = [[UIView alloc] initWithFrame:CGRectMake(0, 38, CGRectGetWidth(photoBtnView.frame), 1)];
    [self.photoBtnLine setBackgroundColor:[QHVCEditPrefs colorHighlight]];
    UIButton* photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(photoBtnView.frame), 38)];
    [photoBtn setTitle:@"图片" forState:UIControlStateNormal];
    [photoBtn setTintColor:[UIColor whiteColor]];
    [photoBtn addTarget:self action:@selector(clickedPhotoTab) forControlEvents:UIControlEventTouchUpInside];
    [photoBtnView addSubview:photoBtn];
    [photoBtnView addSubview:self.photoBtnLine];
    [customTopBarView addSubview:photoBtnView];
    
    //url button view
    UIView* urlBtnView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(customTopBarView.frame)*2.0/3.0, 0,
                                                                  CGRectGetWidth(customTopBarView.frame)/3.0, 40)];
    self.urlBtnLine = [[UIView alloc] initWithFrame:CGRectMake(0, 38, CGRectGetWidth(urlBtnView.frame), 1)];
    [self.urlBtnLine setBackgroundColor:[QHVCEditPrefs colorHighlight]];
    UIButton* urlBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(urlBtnView.frame), 38)];
    [urlBtn setTitle:@"URL" forState:UIControlStateNormal];
    [urlBtn setTintColor:[UIColor whiteColor]];
    [urlBtn addTarget:self action:@selector(clickedUrlTab) forControlEvents:UIControlEventTouchUpInside];
    [urlBtnView addSubview:urlBtn];
    [urlBtnView addSubview:self.urlBtnLine];
    [customTopBarView addSubview:urlBtnView];
    
    //content view
    [self.topConstraint setConstant:[self topBarHeight]];
    [self clickedVideoTab];
    
    [_videoCollectionView registerNib:[UINib nibWithNibName:photoItemCellIdentifier bundle:nil] forCellWithReuseIdentifier:videoItemCellIdentifier];
    [_photoCollectionView registerNib:[UINib nibWithNibName:photoItemCellIdentifier bundle:nil] forCellWithReuseIdentifier:photoItemCellIdentifier];
    [_selectedCollectionView registerNib:[UINib nibWithNibName:selectedCellIdentifier bundle:nil] forCellWithReuseIdentifier:selectedCellIdentifier];
    _videoCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    _photoCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    
    //fetch data
    _videoLists = [NSMutableArray array];
    _videoCacheLists = [NSMutableArray array];
    _photoLists = [NSMutableArray array];
    _photoCacheLists = [NSMutableArray array];
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
             [[QHVCPhotoManager manager] fetchAllPhotos:^(NSArray<QHVCPhotoItem *> *items, NSArray<PHAsset *> *caches)
             {
                 [self.photoLists addObjectsFromArray:items];
                 [self.photoCacheLists addObjectsFromArray:caches];
                 [self.photoCollectionView reloadData];
             }];
         }
    }];
}

- (void)backAction:(UIButton *)btn
{
    if (self.completion)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)nextAction:(UIButton *)btn
{
    if (self.completion)
    {
        //画中画等弹出页面用
        SAFE_BLOCK(self.completion, _selectedLists);
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if(_selectedLists.count > 0)
    {
        QHVCEditSetOutputParamsVC *vc = [[QHVCEditSetOutputParamsVC alloc] initWithItems:_selectedLists];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)clickedVideoTab
{
    [self.videoBtnLine setHidden:NO];
    [self.photoBtnLine setHidden:YES];
    [self.urlBtnLine setHidden:YES];
    
    [self.videoView setHidden:NO];
    [self.photoView setHidden:YES];
    [self.urlView setHidden:YES];
    
    CGRect preheatRect = self.videoCollectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    self.previousPreheatRect = preheatRect;
}

- (void)clickedPhotoTab
{
    [self.videoBtnLine setHidden:YES];
    [self.photoBtnLine setHidden:NO];
    [self.urlBtnLine setHidden:YES];
    
    [self.videoView setHidden:YES];
    [self.photoView setHidden:NO];
    [self.urlView setHidden:YES];
    
    CGRect preheatRect = self.photoCollectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    self.previousPreheatRect = preheatRect;
}

- (void)clickedUrlTab
{
    [self.videoBtnLine setHidden:YES];
    [self.photoBtnLine setHidden:YES];
    [self.urlBtnLine setHidden:NO];
    
    [self.videoView setHidden:YES];
    [self.photoView setHidden:YES];
    [self.urlView setHidden:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)clickedAddUrlBtn:(UIButton *)sender
{
    NSString* url = self.urlTextField.text;
    QHVCEditFileInfo* info = [QHVCEditTools getFileInfo:url];
    if (info)
    {
        QHVCPhotoItem* item = [[QHVCPhotoItem alloc] init];
        item.isLocalFile = NO;
        item.filePath = url;
        item.assetType = info.isPicture ? QHVCAssetType_Image : QHVCAssetType_Video;
        item.assetWidth = info.width;
        item.assetHeight = info.height;
        item.assetDurationMs = info.durationMs;
        item.thumbImage = [UIImage imageNamed:@"edit_play"];
        [self updateSelectList:item];
    }
    else
    {
        [self.view makeToast:@"请求URL文件信息失败"];
    }
}

#pragma mark - UICollectionView

- (CGSize)photoCellSize
{
    if(CGSizeEqualToSize(CGSizeZero, _photoCellSize))
    {
        CGFloat width = floorf((kScreenWidth - 3*kHSpece)/kNumsInLine);
        CGFloat height = width;
        _photoCellSize = CGSizeMake(width, height);
    }
    return _photoCellSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _photoCollectionView)
    {
        return self.photoLists.count;
    }
    else if (collectionView == _videoCollectionView)
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
    else if (collectionView == _photoCollectionView)
    {
        QHVCShortVideoPhotoItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoItemCellIdentifier forIndexPath:indexPath];
        QHVCPhotoItem *item = self.photoLists[indexPath.row];
        item.thumbImageCacheSize = CGSizeMake(self.photoCellSize.width * 2, self.photoCellSize.height * 2);
        [cell updateCell:item];
        return cell;
    }
    else if (collectionView == _selectedCollectionView)
    {
        QHVCShortVideoPhotoSelectedCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectedCellIdentifier forIndexPath:indexPath];
        QHVCPhotoItem *item = self.selectedLists[indexPath.row];
        __weak typeof(self) weakSelf =self;
        cell.deleteCompletion = ^(QHVCPhotoItem *item)
        {
            [weakSelf deleteSelectedPhoto:item];
        };
        [cell updateCell:item];
        return cell;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _photoCollectionView || collectionView == _videoCollectionView)
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
    if (collectionView == _photoCollectionView)
    {
         item = _photoLists[indexPath.row];
    }
    else if (collectionView == _videoCollectionView)
    {
        item = _videoLists[indexPath.row];
    }
    
    if (self.maxCount > 0 && ([self.selectedLists count] >= self.maxCount) && !item.isSelected)
    {
        SAFE_BLOCK(self.fullAction, self.maxCount);
        return;
    }
    
    if (item)
    {
        [self updateSelectList:item];
        [_photoCollectionView reloadData];
        [_videoCollectionView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _photoCollectionView)
    {
        [self updateCachedAssets:self.photoCollectionView cacheList:self.photoCacheLists];
    }
    else if (scrollView == _videoCollectionView)
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
    [_photoCollectionView reloadData];
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
