//
//  QHVCEditAuxFilterView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAuxFilterView.h"
#import "QHVCEditAuxFilterCell.h"
#import "QHVCEditPrefs.h"

static NSString * const filterCellIdentifier = @"QHVCEditAuxFilterCell";

@interface  QHVCEditAuxFilterView()
{
    __weak IBOutlet UICollectionView *_filterCollectionView;
    NSInteger _selectedIndex;
}
@end

@implementation QHVCEditAuxFilterView

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
    
    [_filterCollectionView registerNib:[UINib nibWithNibName:filterCellIdentifier bundle:nil] forCellWithReuseIdentifier:filterCellIdentifier];
    _selectedIndex = [QHVCEditPrefs sharedPrefs].filterIndex;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCEditAuxFilterCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:filterCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_filters[indexPath.row] filterIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70, 90);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex == indexPath.row) {
        return;
    }
    NSDictionary *item = _filters[indexPath.row];
    [QHVCEditPrefs sharedPrefs].filterIndex = indexPath.row;
    _selectedIndex = indexPath.row;
    [_filterCollectionView reloadData];
    if (self.selectedCompletion) {
        self.selectedCompletion(item);
    }
}

@end
