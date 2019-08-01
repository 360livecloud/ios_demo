//
//  QHVCEditMainFunctionCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditMainFunctionCell.h"

@interface QHVCEditMainFunctionCell()
{
    __weak IBOutlet UIImageView *_logoImageView;
    __weak IBOutlet UILabel *_titleLabel;
}
@end

@implementation QHVCEditMainFunctionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSArray *)item
{
    _titleLabel.text = item[0];
    _logoImageView.image = [UIImage imageNamed:item[1]];
}

@end
