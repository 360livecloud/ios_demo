//
//  QHVCTabTableViewCell.m
//  QHVideoCloudDemo
//
//  Created by niezhiqiang on 2017/8/28.
//  Copyright © 2017年 qihoo360. All rights reserved.
//

#import "QHVCTabTableViewCell.h"

@interface QHVCTabTableViewCell ()
{
    UIImageView *_logoImageView;
    UILabel *_titleLabel;
    UIImageView *_rigitImage;
}

@end

@implementation QHVCTabTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    _logoImageView = [UIImageView new];
    [self addSubview:_logoImageView];
    [_logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@18);
        make.centerY.equalTo(self);
        make.height.width.equalTo(@20);
    }];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_logoImageView.mas_right).offset(15);
        make.centerY.equalTo(_logoImageView);
        make.height.equalTo(@20);
        make.width.equalTo(@100);
    }];
    
    _rigitImage = [UIImageView new];
    [self addSubview:_rigitImage];
    [_rigitImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-18);
        make.width.equalTo(@10);
        make.height.equalTo(@15);
        make.centerY.equalTo(self);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateCellDetail:(NSMutableDictionary *)item
{
    _logoImageView.image = [UIImage imageNamed:item[@"leftImage"]];
    _titleLabel.text = item[@"title"];
    _rigitImage.image = [UIImage imageNamed:item[@"rightImage"]];
}

@end
