//
//  QHVCEditTailorFillCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTailorFillCell.h"

@interface QHVCEditTailorFillCell()
{
    __weak IBOutlet UILabel *_fillLabel;
    __weak IBOutlet UIImageView *_fillImageView;
}
@end

@implementation QHVCEditTailorFillCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSString *)title isSelected:(BOOL)isSelected
{
    _fillLabel.text = title;
    if (isSelected) {
        _fillImageView.image = [UIImage imageNamed:@"edit_format_fill_cell_h"];
    }
    else
    {
        _fillImageView.image = [UIImage imageNamed:@"edit_format_fill_cell"];
    }
}

@end
 
