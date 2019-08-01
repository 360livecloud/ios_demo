//
//  QHVCRecordBGMCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/11/29.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordBGMCell.h"

@interface QHVCRecordBGMCell()
{
    IBOutlet UILabel *_titleLabel;
}
@end

@implementation QHVCRecordBGMCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSString *)item isHighlight:(BOOL)isHighlight
{
    _titleLabel.text = item;
    _titleLabel.backgroundColor = isHighlight?[UIColor greenColor]:[UIColor redColor];
}

@end
