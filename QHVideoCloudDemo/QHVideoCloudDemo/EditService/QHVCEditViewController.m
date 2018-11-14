//
//  QHVCEditViewController.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2017/8/15.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditViewController.h"
#import "QHVCEditPhotoItemCell.h"
#import "QHVCEditPhotoManager.h"
#import "QHVCEditPhotoItem.h"
#import "QHVCEditPhotoSelectedCell.h"
#import "QHVCEditReorderViewController.h"
#import "QHVCEditPrefs.h"

#define kNumsInLine 4
#define kLines 2
#define kVSpace 1
#define kHSpece 1

@interface QHVCEditViewController ()
{

}

@property (nonatomic, readwrite, strong) NSMutableArray<QHVCEditPhotoItem *> *selectedLists;
@property (nonatomic, strong) NSMutableArray<QHVCEditPhotoItem *> *photoLists;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *cacheLists;
@property (nonatomic, weak) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *selectedCollectionView;
@property (nonatomic, assign) CGSize photoCellSize;

@end

static NSString * const photoItemCellIdentifier = @"QHVCEditPhotoItemCell";
static NSString * const selectedCellIdentifier = @"QHVCEditPhotoSelectedCell";

@implementation QHVCEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"所有照片";
    
    [_photoCollectionView registerNib:[UINib nibWithNibName:photoItemCellIdentifier bundle:nil] forCellWithReuseIdentifier:photoItemCellIdentifier];
    [_selectedCollectionView registerNib:[UINib nibWithNibName:selectedCellIdentifier bundle:nil] forCellWithReuseIdentifier:selectedCellIdentifier];
    
    _photoLists = [NSMutableArray array];
    _cacheLists = [NSMutableArray array];
    _selectedLists = [NSMutableArray array];

    _photoCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    
    __weak typeof(self) weakSelf = self;
    [[QHVCEditPhotoManager manager] requestAuthorization:^(BOOL granted) {
        if (granted) {
            [[QHVCEditPhotoManager manager] fetchPhotos:^(NSArray<QHVCEditPhotoItem *> *photos,NSArray<PHAsset *> *caches) {
                [weakSelf initPhotoDatas:photos caches:caches];
            }];
        }
    }];
}

- (void)nextAction:(UIButton *)btn
{
    if (self.completion) {
        self.completion(_selectedLists);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if(_selectedLists.count > 0)
    {
        QHVCEditReorderViewController *vc = [[QHVCEditReorderViewController alloc]init];
        vc.resourceArray = _selectedLists;
        [QHVCEditPrefs sharedPrefs].photosList = _selectedLists;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _photoCollectionView) {
        return self.photoLists.count;
    }
    else if (collectionView == _selectedCollectionView)
    {
        return self.selectedLists.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _photoCollectionView) {
        QHVCEditPhotoItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoItemCellIdentifier forIndexPath:indexPath];
        QHVCEditPhotoItem *item = self.photoLists[indexPath.row];
        item.thumbImageCacheSize = [self photoCellSize];
        [cell updateCell:item];
        return cell;
    }
    else if (collectionView == _selectedCollectionView)
    {
        QHVCEditPhotoSelectedCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:selectedCellIdentifier forIndexPath:indexPath];
        QHVCEditPhotoItem *item = self.selectedLists[indexPath.row];
        __weak typeof(self) weakSelf =self;
        cell.deleteCompletion = ^(QHVCEditPhotoItem *item) {
            [weakSelf deleteSelectedPhoto:item];
        };
        [cell updateCell:item];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _photoCollectionView) {
        return self.photoCellSize;
    }
    else
    {
        return CGSizeMake(80, 80);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kVSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kHSpece;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _photoCollectionView)
    {
        QHVCEditPhotoItem *item = _photoLists[indexPath.row];
        if (self.maxCount > 0 && ([self.selectedLists count] >= self.maxCount) && !item.isSelected)
        {
            SAFE_BLOCK(self.fullAction, self.maxCount);
            return;
        }
        
        item.isSelected = !item.isSelected;
        if (item.isSelected) {
            [_selectedLists addObject:item];
        }
        else
        {
            [_selectedLists removeObject:item];
        }
        if (_selectedLists.count > 0) {
            [_selectedCollectionView reloadData];
            _selectedCollectionView.hidden = NO;
        }
        else
        {
            _selectedCollectionView.hidden = YES;
        }
        [_photoCollectionView reloadData];
    }
}

#pragma mark Private

- (void)deleteSelectedPhoto:(QHVCEditPhotoItem *)item
{
    [_selectedLists removeObject:item];
    item.isSelected = !item.isSelected;
    if (_selectedLists.count > 0) {
        [_selectedCollectionView reloadData];
    }
    else
    {
        _selectedCollectionView.hidden = YES;
    }
    [_photoCollectionView reloadData];
}

- (void)initPhotoDatas:(NSArray<QHVCEditPhotoItem *> *)photos caches:(NSArray<PHAsset *> *)caches
{
    [self.photoLists addObjectsFromArray:photos];
    [self.cacheLists addObjectsFromArray:caches];
    [[QHVCEditPhotoManager manager] startImageCache:self.cacheLists targetSize:[self photoCellSize]];
    [self.photoCollectionView reloadData];
}

- (CGSize)photoCellSize
{
    if(CGSizeEqualToSize(CGSizeZero, _photoCellSize)){
        CGFloat width = floorf((kScreenWidth - 3*kHSpece)/kNumsInLine);
        CGFloat height = width;
        _photoCellSize = CGSizeMake(width, height);
    }
    return _photoCellSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
