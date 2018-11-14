//
//  QHVCEditOverlayTemplateCell.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayTemplateCell.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditOverlayTemplateCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation QHVCEditOverlayTemplateCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(UIImage *)image index:(NSInteger)index
{
    [self.imageView setImage:image];
    if ([QHVCEditPrefs sharedPrefs].overlayTemplateIndex == index)
    {
        [self.imageView setBackgroundColor:[QHVCEditPrefs colorHighlight]];
    }
}

@end
