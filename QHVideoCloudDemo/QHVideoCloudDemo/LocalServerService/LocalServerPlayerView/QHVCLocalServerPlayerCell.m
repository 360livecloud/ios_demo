//
//  QHVCLocalServerPlayerCell.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/20.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerPlayerCell.h"
#import "QHVCLocalServerPlayerView.h"

@implementation QHVCLocalServerPlayerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _playerView = [[QHVCLocalServerPlayerView alloc] initWithSize:CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width * SCREEN_SCALE)];
        [self addSubview:_playerView];
        [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
