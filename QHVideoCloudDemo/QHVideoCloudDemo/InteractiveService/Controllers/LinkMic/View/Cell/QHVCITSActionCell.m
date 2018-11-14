//
//  QHVCITSActionCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/22.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSActionCell.h"

@interface QHVCITSActionCell()
{
    IBOutlet UIImageView *_iconImageView;
}
@end

@implementation QHVCITSActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSDictionary *)item
{
    BOOL isNormal = [[item valueForKey:@"status"] boolValue];
    BOOL isDisable = [[item valueForKey:@"disable"] boolValue];
    if (!isNormal||isDisable) {
        _iconImageView.image = [UIImage imageNamed:item[@"switch"]];
    }
    else
    {
        _iconImageView.image = [UIImage imageNamed:item[@"normal"]];
    }
}

@end
