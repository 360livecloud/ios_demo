//
//  QHVCEditAuxFilterCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAuxFilterCell.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditAuxFilterCell()
{
    __weak IBOutlet UIView *_maskView;
    __weak IBOutlet UILabel *_title;
    __weak IBOutlet UIImageView *_selectedView;
}
@end

@implementation QHVCEditAuxFilterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSDictionary *)item filterIndex:(NSInteger)index
{
    _title.text = item[@"title"];
    NSInteger type = [item[@"type"] integerValue];
    if (type == 0)
    {
        _maskView.backgroundColor = [QHVCEditPrefs colorHex:item[@"color"]];
    }
    else
    {
        _maskView.backgroundColor = [UIColor clearColor];
    }
    
    if (index == [QHVCEditPrefs sharedPrefs].filterIndex) {
        _selectedView.hidden = NO;
    }
    else
    {
        _selectedView.hidden = YES;
    }
}

@end
