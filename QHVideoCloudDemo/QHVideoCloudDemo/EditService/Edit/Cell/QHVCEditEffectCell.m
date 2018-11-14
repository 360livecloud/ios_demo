//
//  QHVCEditEffectCell.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditEffectCell.h"

@interface QHVCEditEffectCell ()
{
    __weak IBOutlet UIImageView *effectLogoImageView;
    __weak IBOutlet UILabel *titleLabel;
}
@end

@implementation QHVCEditEffectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSArray *)item
{
    titleLabel.text = item[0];
    effectLogoImageView.image = [UIImage imageNamed:item[1]];
}

- (void)setTitleColor:(UIColor *)color
{
    titleLabel.textColor = color;
}

@end
