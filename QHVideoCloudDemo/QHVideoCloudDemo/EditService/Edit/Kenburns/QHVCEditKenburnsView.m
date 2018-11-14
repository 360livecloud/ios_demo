//
//  QHVCEditKenburnsView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/9/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditKenburnsView.h"
#import "QHVCEditEffectCell.h"

static NSString * const kenburnsCellIdentifier = @"QHVCEditEffectCell";

@interface QHVCEditKenburnsView () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSIndexPath *_currentIndex;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, retain) NSArray* effectArray;
@property (nonatomic, assign) CGFloat intensity;

@end

@implementation QHVCEditKenburnsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_collectionView registerNib:[UINib nibWithNibName:kenburnsCellIdentifier bundle:nil] forCellWithReuseIdentifier:kenburnsCellIdentifier];
    _effectArray = @[@[@"无", @"effect_1"],
                     @[@"推近", @"effect_1"],
                     @[@"拉远", @"effect_1"],
                     @[@"上移", @"effect_1"],
                     @[@"下移", @"effect_1"],
                     @[@"左移", @"effect_1"],
                     @[@"右移", @"effect_1"]];
    self.intensity = 1.25;
}

- (IBAction)onSliderValueChanged:(UISlider *)sender
{
    self.intensity = sender.value;
    if (self.selectComplete)
    {
        self.selectComplete(_currentIndex.row, self.intensity);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _effectArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditEffectCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kenburnsCellIdentifier forIndexPath:indexPath];
    if (indexPath.row < [_effectArray count])
    {
        [cell updateCell:_effectArray[indexPath.row]];
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(45, 65);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentIndex && (_currentIndex.row == indexPath.row))
    {
        return;
    }
    
    if (self.selectComplete)
    {
        self.selectComplete(indexPath.row, self.intensity);
    }

    if (_currentIndex)
    {
        QHVCEditEffectCell * cell1 = (QHVCEditEffectCell *)[collectionView cellForItemAtIndexPath:_currentIndex];
        [cell1 setTitleColor:[UIColor whiteColor]];
    }

    QHVCEditEffectCell * cell2 = (QHVCEditEffectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell2 setTitleColor:[UIColor redColor]];

    _currentIndex = indexPath;
}

@end
