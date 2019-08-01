//
//  QHVCRecordEffectNavView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/11/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordEffectNavView.h"
#import "QHVCRecordFunctionCell.h"

@interface QHVCRecordEffectNavView()
{
    IBOutlet UICollectionView *_functionCollectionView;
}
@property (nonatomic, strong) NSArray<NSString*> *functions;

@end

static NSString * const functionCellIdentifier = @"QHVCRecordFunctionCell";

@implementation QHVCRecordEffectNavView

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
    _functions = @[@"edit_filter",@"record_music"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _functions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCRecordFunctionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:functionCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_functions[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(30, 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedCompletion) {
        self.selectedCompletion(indexPath.row);
    }
}

@end
