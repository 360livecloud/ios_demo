//
//  QHVCEditAuxFilterCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordAuxFilterCell.h"

@interface QHVCRecordAuxFilterCell()
{
    __weak IBOutlet UILabel *_title;
    __weak IBOutlet UIImageView *_selectedView;
    __weak IBOutlet UIImageView *_logoImageView;
}
@end

@implementation QHVCRecordAuxFilterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSDictionary *)item isHighlight:(BOOL)isHighlight
{
    _title.text = item[@"title"];
    if (_title.text.length > 0) {
        _title.hidden = NO;
    }
    else
    {
        _title.hidden = YES;
    }
    NSString *logoImage = item[@"image"];
    if (logoImage) {
        _logoImageView.image = [UIImage imageNamed:logoImage];
        _title.hidden = YES;
    }
    _selectedView.hidden = !isHighlight;
}

@end
