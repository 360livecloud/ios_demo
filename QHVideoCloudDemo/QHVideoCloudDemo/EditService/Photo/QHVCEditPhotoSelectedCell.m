//
//  QHVCEditPhotoSelectedCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditPhotoSelectedCell.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditPhotoSelectedCell()
{
    __weak IBOutlet UILabel *_duration;
    __weak IBOutlet UIImageView *_thumbImageView;
}
@property (nonatomic, strong) QHVCEditPhotoItem *photoItem;

@end

@implementation QHVCEditPhotoSelectedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(QHVCEditPhotoItem *)item
{
    self.photoItem = item;
    
    if (item.asset.duration > 0) {
        _duration.text = [QHVCEditPrefs timeFormatMs:item.durationMs];
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
