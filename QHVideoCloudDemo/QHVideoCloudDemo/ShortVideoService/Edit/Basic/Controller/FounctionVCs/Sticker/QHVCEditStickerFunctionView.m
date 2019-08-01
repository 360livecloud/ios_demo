//
//  QHVCEditStickerFunctionView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/9/3.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditStickerFunctionView.h"
#import "QHVCEditMainFunctionCell.h"

static NSString* const functionIdentifier = @"QHVCEditStickerFunctionCell";

@interface QHVCEditStickerFunctionView ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) NSArray* functionArray;
@property (nonatomic, retain) QHVCEditStickerItemView* itemView;
@end

@implementation QHVCEditStickerFunctionView

- (void)setStickerItemView:(QHVCEditStickerItemView *)itemView
{
    _itemView = itemView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _functionArray = [NSArray arrayWithObjects:
                      @[@"淡入淡出", @"edit_overlay_fade"],
                      @[@"滑入滑出", @"edit_overlay_fade"],
                      @[@"弹入弹出", @"edit_overlay_fade"],
                      @[@"旋入旋出", @"edit_overlay_fade"], nil];
    [_collectionView registerNib:[UINib nibWithNibName:@"QHVCEditMainFunctionCell" bundle:nil] forCellWithReuseIdentifier:functionIdentifier];
}

- (IBAction)onBackBtnClicked:(id)sender
{
    [self removeFromSuperview];
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_functionArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditMainFunctionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:functionIdentifier forIndexPath:indexPath];
    [cell updateCell:_functionArray[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_itemView addAnimationOfIndex:indexPath.row];
    [self onBackBtnClicked:nil];
}

@end
