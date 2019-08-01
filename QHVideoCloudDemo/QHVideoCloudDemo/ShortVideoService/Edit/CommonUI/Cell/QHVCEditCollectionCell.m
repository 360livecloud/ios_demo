//
//  QHVCEditCommonCell.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/5/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditCollectionCell.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end


@implementation QHVCEditCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(NSString *)title imageName:(NSString *)imageName
{
    self.label.text = title;
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)setSelected:(BOOL)selected
{
    if (selected)
    {
        self.layer.borderColor = [QHVCEditPrefs colorHighlight].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.masksToBounds = YES;
    }
    else
    {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
