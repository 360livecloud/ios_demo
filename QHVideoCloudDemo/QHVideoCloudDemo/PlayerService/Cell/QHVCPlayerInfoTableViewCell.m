//
//  QHVCPlayerInfoTableViewCell.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/11.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPlayerInfoTableViewCell.h"
#import "QHVCPlayerInfoTextView.h"

@interface QHVCPlayerInfoTableViewCell ()<UITextViewDelegate>
{
    UILabel *_nameLabel;
    QHVCPlayerInfoTextView *_title;
}

@end

@implementation QHVCPlayerInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.text = @"播放url:";
        [self addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@14);
            make.top.with.equalTo(self);
            make.height.equalTo(@22);
        }];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _title  = [QHVCPlayerInfoTextView new];
        _title.font = [UIFont systemFontOfSize:16];
        _title.backgroundColor = [UIColor clearColor];
        _title.editable = NO;
        [self addSubview:_title];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(-5);
            make.bottom.equalTo(self);
            make.left.equalTo(_nameLabel.mas_right).offset(5);
            make.right.equalTo(self).offset(-10);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title.text = title;
}

- (void)setTitleColor:(UIColor *)color
{
    _title.textColor = color;
    _nameLabel.textColor = color;
}

- (void)setTitleEnable:(BOOL)enable
{
    _title.userInteractionEnabled = enable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
