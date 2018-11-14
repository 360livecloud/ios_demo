//
//  QHVCEditTailorMainView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTailorMainView.h"
#import "QHVCEditFrameCell.h"

@interface QHVCEditTailorMainView()
{
    __weak IBOutlet UICollectionView *_collectionView;
    NSArray<NSString *> *_tabsArray;
}
@end

static NSString * const tabCellIdentifier = @"QHVCEditFrameCell";

@implementation QHVCEditTailorMainView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_collectionView registerNib:[UINib nibWithNibName:tabCellIdentifier bundle:nil] forCellWithReuseIdentifier:tabCellIdentifier];
    
    _tabsArray = @[@"edit_tailor_restore",@"edit_tailor_rotate",@"edit_tailor_u_d",@"edit_tailor_format",@"edit_tailor_l_r",@"edit_tailor_rate"];
    [_collectionView reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tabsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:tabCellIdentifier forIndexPath:indexPath];
    [cell updateCell:[UIImage imageNamed:_tabsArray[indexPath.row]] highlightViewType:QHVCEditFrameHighlightViewTypeNone];
    [cell setImageFillMode:UIViewContentModeScaleToFill];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCompletion) {
        self.selectedCompletion(indexPath.row);
    }
}

@end
