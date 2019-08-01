//
//  QHVCEditAuxFilterView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordAuxFilterView.h"
#import "QHVCRecordAuxFilterCell.h"

static NSString * const filterCellIdentifier = @"QHVCRecordAuxFilterCell";

@interface  QHVCRecordAuxFilterView()
{
    __weak IBOutlet UICollectionView *_filterCollectionView;
    NSInteger _selectedIndex;
}
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *filters;

@end

@implementation QHVCRecordAuxFilterView

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
    _selectedIndex = 0;
    
    _filters = [NSMutableArray array];
    [_filters addObject:@{@"title":@"原图",@"color":@""}];
    for (int i = 1; i <=16; i++) {
        [_filters addObject:@{@"title":[NSString stringWithFormat:@"滤镜_%@",@(i)],
                              @"color":[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"lut_%@",@(i)] ofType:@"png"]}];
    }
}

- (IBAction)closeBtnAction:(id)sender
{
    self.hidden = YES;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCRecordAuxFilterCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:filterCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_filters[indexPath.row] isHighlight:indexPath.row == _selectedIndex];
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
    _selectedIndex = indexPath.row;
    [_filterCollectionView reloadData];
    if (self.filterAction) {
        self.filterAction(item);
    }
}

@end
