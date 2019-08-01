//
//  QHVCShortVideoPhotoSelectedCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCShortVideoPhotoSelectedCell.h"
#import "QHVCEditPrefs.h"

@interface QHVCShortVideoPhotoSelectedCell()
{
    __weak IBOutlet UILabel *_duration;
    __weak IBOutlet UIImageView *_thumbImageView;
}
@property (nonatomic, strong) QHVCPhotoItem *photoItem;

@end

@implementation QHVCShortVideoPhotoSelectedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(QHVCPhotoItem *)item
{
    self.photoItem = item;
    
    if (item.assetDurationMs > 0)
    {
        _duration.text = [QHVCEditPrefs timeFormatMs:item.assetDurationMs];
    }
    else
    {
        _duration.text = @"";
    }
    _thumbImageView.image = item.thumbImage;
}

- (IBAction)deleteAction:(UIButton *)sender
{
    if (_deleteCompletion) {
        _deleteCompletion(self.photoItem);
    }
}

@end
