//
//  QHVCEditOverlayBgColorCell.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayBgColorCell.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditOverlayBgColorCell ()
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@end

@implementation QHVCEditOverlayBgColorCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.selectedImageView setHidden:YES];
}

- (void)updateCell:(UIColor *)color index:(NSInteger)index
{
    [self setBackgroundColor:color];
    if ([QHVCEditPrefs sharedPrefs].overlayBgColorIndex == index)
    {
        [self.selectedImageView setHidden:NO];
    }
    else
    {
        [self.selectedImageView setHidden:YES];
    }
}

@end
