//
//  QHVCEditCommonCell.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/5/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditCommonCell.h"

@interface QHVCEditCommonCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end


@implementation QHVCEditCommonCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(NSString *)title imageName:(NSString *)imageName
{
    self.label.text = title;
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end
