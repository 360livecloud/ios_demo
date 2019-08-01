//
//  QHVCEditStickerView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditStickerView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditStickerFunctionView.h"
#import "QHVCEditMainContentView.h"

static NSString* const cellIdentifier = @"QHVCEditFrameCell";

@interface QHVCEditStickerView()
{
    IBOutlet UICollectionView *_stickerCollectionView;
    
    NSArray* _dataArray;
    QHVCEditStickerItemView* _currentStickerItemView;
}

@end

@implementation QHVCEditStickerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _dataArray = [NSArray arrayWithObjects:@"sticker1.png",
                                           @"sticker2.png",
                                           @"sticker3.png",
                                           @"sticker4.png",
                                           @"sticker5.png",
                                           @"sticker6.png",
                                           @"sticker7.png",
                                           nil];
    
    [_stickerCollectionView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStickerItemNotify:) name:QHVCEDIT_DEFINE_NOTIFY_SHOW_STICKER_FUNCTION object:nil];
}

- (void)confirmAction
{
    SAFE_BLOCK(self.confirmBlock, self);
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImage *image = [UIImage imageNamed:_dataArray[indexPath.row]];
    [cell updateCell:image highlightViewType:QHVCEditFrameHighlightViewTypeNone];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage* sticker = [UIImage imageNamed:_dataArray[indexPath.row]];
    if (sticker)
    {
        _currentStickerItemView = [self.playerContentView addSticker:sticker];
    }
}

#pragma mark - Sticker Notification

- (void)onStickerItemNotify:(NSNotification *)notification
{
    QHVCEditStickerItemView* item = notification.object;
    QHVCEditStickerFunctionView* functionView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditStickerFunctionView class] description] owner:self options:nil][0];
    [functionView setFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 80, CGRectGetWidth(self.frame), 80)];
    [functionView setStickerItemView:item];
    [self addSubview:functionView];
}

@end
