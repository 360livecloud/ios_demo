//
//  QHVCShortVideoPhotoItemCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/22.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCShortVideoPhotoItemCell.h"
#import <Photos/Photos.h>
#import "QHVCPhotoManager.h"
#import "QHVCEditPrefs.h"

@interface  QHVCShortVideoPhotoItemCell()
{
    __weak IBOutlet UILabel *_duration;
    __weak IBOutlet UIView *_selectView;
}
@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;

@end

@implementation QHVCShortVideoPhotoItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(QHVCPhotoItem *)item
{
    [_selectView setHidden:YES];
    _duration.text = @"";
    
    if(!item.thumbImage)
    {
        WEAK_SELF
        [[QHVCPhotoManager manager] fetchImageForAsset:item options:nil completion:^{
            STRONG_SELF
            if (item.thumbImage)
            {
                self.thumbImageView.image = item.thumbImage;
            }
        }];
    }
    else
    {
        self.thumbImageView.image = item.thumbImage;
    }
    
    if (item.isSelected)
    {
        [_selectView setHidden:NO];
    }
    
    if (item.asset.duration > 0)
    {
        _duration.text = [QHVCEditPrefs timeFormatMs:item.assetDurationMs];
    }
}

@end
