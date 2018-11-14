//
//  QHVCEditTransferView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTransferView.h"
#import "QHVCEditSegmentCell.h"
#import "QHVCEditMainFunctionCell.h"
#import "QHVCEditSegmentItem.h"

static NSString * const effectCellIdentifier = @"QHVCEditMainFunctionCell";
static NSString * const segmentCellIdentifier = @"QHVCEditSegmentCell";

@interface QHVCEditTransferView()
{
    __weak IBOutlet UICollectionView *_effectCollectionView;
    __weak IBOutlet UICollectionView *_segmentCollectionView;
    NSInteger _segmentIndex;
}
@property (nonatomic, strong) NSArray<NSArray *> *effects;
@property (nonatomic, strong) NSArray<QHVCEditSegmentItem *> *segments;

@end

@implementation QHVCEditTransferView

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
    _segmentIndex = -1;
    [_effectCollectionView registerNib:[UINib nibWithNibName:effectCellIdentifier bundle:nil] forCellWithReuseIdentifier:effectCellIdentifier];
    [_segmentCollectionView registerNib:[UINib nibWithNibName:segmentCellIdentifier bundle:nil] forCellWithReuseIdentifier:segmentCellIdentifier];
}

- (void)updateView:(NSArray<NSArray *> *)effects segments:(NSArray<QHVCEditSegmentItem *> *)segments
{
    self.effects = effects;
    self.segments = segments;
    [_effectCollectionView reloadData];
    [_segmentCollectionView reloadData];
}

- (void)updateSegmentIndex:(QHVCEditSegmentItem *)item
{
    if (item.transferIndex > 0) {
        if (self.addCompletion) {
            self.addCompletion();
        }
        return;
    }
    if (item.segmentIndex != _segmentIndex) {
        _segmentIndex = item.segmentIndex;
        [_segmentCollectionView reloadData];
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _effectCollectionView) {
        return _effects.count;
    }
    else if (collectionView == _segmentCollectionView)
    {
        return _segments.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _effectCollectionView) {
        QHVCEditMainFunctionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:effectCellIdentifier forIndexPath:indexPath];
        [cell updateCell:_effects[indexPath.row]];
        return cell;
    }
    else if (collectionView == _segmentCollectionView)
    {
        QHVCEditSegmentCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:segmentCellIdentifier forIndexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        cell.selectedCompletion = ^(QHVCEditSegmentItem *item) {
            [weakSelf updateSegmentIndex:item];
        };
        QHVCEditSegmentItem *item = _segments[indexPath.row];
        if (indexPath.row == _segments.count - 1) {
//            item.transferType = QHVCEditTransferTypeAdd;
        }
        [cell updateCell:item isHighlight:_segmentIndex == indexPath.row];
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
    if (collectionView == _effectCollectionView) {
        if (_segmentIndex >= 0) {
            QHVCEditSegmentItem *item = _segments[_segmentIndex];
            if (item.transferIndex != indexPath.row) {
                item.transferIndex = indexPath.row;
                item.transferName = _effects[indexPath.row][2];
                [_segmentCollectionView reloadData];
                if (self.transferCompletion) {
                    self.transferCompletion();
                }
            }
        }
    }
}

@end
