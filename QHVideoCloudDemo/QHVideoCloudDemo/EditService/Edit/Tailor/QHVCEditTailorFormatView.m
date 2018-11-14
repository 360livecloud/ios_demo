//
//  QHVCEditTailorFormatView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTailorFormatView.h"
#import "QHVCEditTailorFillCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditFrameCell.h"

static NSString * const fillCellIdentifier = @"QHVCEditTailorFillCell";
static NSString * const colorCellIdentifier = @"QHVCEditFrameCell";

@interface  QHVCEditTailorFormatView()
{
    __weak IBOutlet UIButton *_fillBtn;
    __weak IBOutlet UIButton *_colorBtn;
    __weak IBOutlet UICollectionView *_collectionView;
    NSInteger _selectedTabIndex;
    NSInteger _fillIndex;
    NSInteger _colorIndex;
}

@property (nonatomic, strong) NSArray *fillsArray;
@property (nonatomic, strong) NSArray *colorsArray;

@end

@implementation QHVCEditTailorFormatView

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
    
    [_collectionView registerNib:[UINib nibWithNibName:fillCellIdentifier bundle:nil] forCellWithReuseIdentifier:fillCellIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:colorCellIdentifier bundle:nil] forCellWithReuseIdentifier:colorCellIdentifier];
    
    _selectedTabIndex = 0;
    _fillIndex = [QHVCEditPrefs sharedPrefs].fillIndex;
    _colorIndex = [QHVCEditPrefs sharedPrefs].colorIndex;
}

- (void)updateView:(NSArray *)fillArray colors:(NSArray *)colorsArray
{
    self.fillsArray = fillArray;
    self.colorsArray = colorsArray;
    [_collectionView reloadData];
}

- (IBAction)formatAction:(UIButton *)sender
{
    if (sender.tag == _selectedTabIndex) {
        return;
    }
    _selectedTabIndex = sender.tag;
    if (sender.tag == 0) {
        [_fillBtn setImage:[UIImage imageNamed:@"edit_format_fill_h"] forState:UIControlStateNormal];
        [_fillBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
        
        [_colorBtn setImage:[UIImage imageNamed:@"edit_format_color"] forState:UIControlStateNormal];
        [_colorBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
    }
    else
    {
        [_fillBtn setImage:[UIImage imageNamed:@"edit_format_fill"] forState:UIControlStateNormal];
        [_fillBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_colorBtn setImage:[UIImage imageNamed:@"edit_format_color_h"] forState:UIControlStateNormal];
        [_colorBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
    }
    [_collectionView reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selectedTabIndex == 0) {
        return _fillsArray.count;
    }
    else if (_selectedTabIndex == 1)
    {
        return _colorsArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedTabIndex == 0) {
        QHVCEditTailorFillCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:fillCellIdentifier forIndexPath:indexPath];
        [cell updateCell:_fillsArray[indexPath.row] isSelected:(indexPath.row == _fillIndex)];
        return cell;
    }
    else if(_selectedTabIndex == 1)
    {
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:colorCellIdentifier forIndexPath:indexPath];
        [cell updateCell:[UIImage imageNamed:_colorsArray[indexPath.row][0]] highlightViewType:indexPath.row == _colorIndex?QHVCEditFrameHighlightViewTypeSquare:QHVCEditFrameHighlightViewTypeNone];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedTabIndex == 0) {
        return CGSizeMake(kScreenWidth, 35);
    }
    return CGSizeMake(52, 52);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedTabIndex == 0) {
        if (_fillIndex != indexPath.row) {
            _fillIndex = indexPath.row;
            [_collectionView reloadData];
            if (self.fillSelectedCompletion) {
                self.fillSelectedCompletion(_fillIndex);
            }
        }
    }
    else if (_selectedTabIndex == 1)
    {
        if (_colorIndex != indexPath.row) {
            _colorIndex = indexPath.row;
            [_collectionView reloadData];
            if (self.colorSelectedCompletion) {
                self.colorSelectedCompletion(_colorIndex);
            }
        }
    }
}

@end
