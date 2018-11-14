//
//  QHVCEditEffectView.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditEffectView.h"
#import "QHVCEditEffectCell.h"

@interface QHVCEditEffectView ()
{
    NSArray<NSArray*> * _effectArray;
    __weak IBOutlet UICollectionView *_effectCollectionView;
    NSIndexPath *_currentIndex;
}
@end

static NSString * const effectCellIdentifier = @"QHVCEditEffectCell";

@implementation QHVCEditEffectView

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
    [_effectCollectionView registerNib:[UINib nibWithNibName:effectCellIdentifier bundle:nil] forCellWithReuseIdentifier:effectCellIdentifier];
}

- (void)updateView:(NSArray<NSArray*> *)effectArray
{
    _effectArray = effectArray;
    [_effectCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _effectArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCEditEffectCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:effectCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_effectArray[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(45, 65);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_currentIndex.row == indexPath.row) {
        return;
    }
    if (self.selectedCompletion) {
        self.selectedCompletion(indexPath.row);
    }
    if (_currentIndex) {
        QHVCEditEffectCell * cell1 = (QHVCEditEffectCell *)[collectionView cellForItemAtIndexPath:_currentIndex];
        [cell1 setTitleColor:[UIColor whiteColor]];
    }
    
    QHVCEditEffectCell * cell2 = (QHVCEditEffectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell2 setTitleColor:[UIColor redColor]];
    
    _currentIndex = indexPath;
}

@end
