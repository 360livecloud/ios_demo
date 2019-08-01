//
//  QHVCRecordSegmentCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/11/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordSegmentCell.h"

@interface QHVCRecordSegmentCell()
{
    IBOutlet UILabel *_durationMs;
}
@end

@implementation QHVCRecordSegmentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSString *)item
{
    if (item.doubleValue > 0) {
        [_durationMs setBackgroundColor:[UIColor blueColor]];
        _durationMs.text = [NSString stringWithFormat:@"%@ s",item];
    }
    else
    {
        [_durationMs setBackgroundColor:[UIColor clearColor]];
        _durationMs.text = @"";
    }
}

@end
