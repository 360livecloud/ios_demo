//
//  QHVCEditMainNavView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditMainNavView.h"
#import "QHVCEditMainFunctionCell.h"

@interface QHVCEditMainNavView()
{
    __weak IBOutlet UICollectionView *_functionCollectionView;
}
@property (nonatomic, strong) NSArray<NSArray*> *functions;

@end

static NSString * const functionCellIdentifier = @"QHVCEditMainFunctionCell";

@implementation QHVCEditMainNavView

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
    [_functionCollectionView registerNib:[UINib nibWithNibName:functionCellIdentifier bundle:nil] forCellWithReuseIdentifier:functionCellIdentifier];
}

- (void)updateView:(NSArray<NSArray*> *)functions
{
    self.functions = functions;
    [_functionCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _functions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCEditMainFunctionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:functionCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_functions[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(55, 70);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCompletion) {
        self.selectedCompletion(indexPath.row);
    }
}

@end
