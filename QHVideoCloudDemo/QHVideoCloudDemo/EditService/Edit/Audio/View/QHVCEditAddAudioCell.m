//
//  QHVCEditAddAudioCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAddAudioCell.h"

@interface QHVCEditAddAudioCell()
{
    __weak IBOutlet UIImageView *_coverImageView;
    __weak IBOutlet UIImageView *_selectedImageView;
}
@end

@implementation QHVCEditAddAudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSArray *)item isSelected:(BOOL)isSelected
{
    _coverImageView.image = [UIImage imageNamed:item[0]];
    _selectedImageView.hidden = !isSelected;
}

@end
