//
//  QHVCRecordFunctionCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/11/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordFunctionCell.h"

@interface QHVCRecordFunctionCell()
{
    IBOutlet UIImageView *_imageView;
}

@end

@implementation QHVCRecordFunctionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSString *)item
{
    _imageView.image = [UIImage imageNamed:item];
}

@end
