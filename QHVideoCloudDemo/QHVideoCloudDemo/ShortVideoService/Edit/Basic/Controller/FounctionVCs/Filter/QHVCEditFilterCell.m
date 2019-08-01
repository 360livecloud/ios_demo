//
//  QHVCEditFilterCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/11.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditFilterCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditorConfig.h"

@interface QHVCEditFilterCell()
{
    __weak IBOutlet UILabel *_title;
    __weak IBOutlet UIImageView *_selectedView;
}
@end

@implementation QHVCEditFilterCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(NSDictionary *)item filterIndex:(NSInteger)index
{
    _title.text = item[@"title"];
    if (index == [QHVCEditMediaEditorConfig sharedInstance].filterIndex)
    {
        _selectedView.hidden = NO;
    }
    else
    {
        _selectedView.hidden = YES;
    }
}

@end
