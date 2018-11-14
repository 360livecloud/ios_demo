//
//  QHVCEditPhotoItemCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditPhotoItemCell.h"
#import <Photos/Photos.h>
#import "QHVCEditPhotoManager.h"
#import "QHVCEditPrefs.h"

@interface  QHVCEditPhotoItemCell()
{
    __weak IBOutlet UILabel *_duration;
    __weak IBOutlet UIView *_selectView;
}
@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;

@end

@implementation QHVCEditPhotoItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(QHVCEditPhotoItem *)item
{
    _selectView.hidden = YES;
    _duration.text = @"";
    
    if(!item.thumbImage)
    {
        __weak typeof(self) weakSelf =self;
        [[QHVCEditPhotoManager manager] fetchImageForAsset:item options:nil completion:^{
            if (item.thumbImage) {
                weakSelf.thumbImageView.image = item.thumbImage;
            }
        }];
    }
    else
    {
        self.thumbImageView.image = item.thumbImage;
    }
    if (item.isSelected) {
        _selectView.hidden = NO;
    }
    if (item.asset.duration > 0) {
        _duration.text = [QHVCEditPrefs timeFormatMs:item.durationMs];
    }
}

@end
