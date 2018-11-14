//
//  QHVCPlayingTableViewCellTwo.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/4.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPlayingTableViewCellTwo.h"

@interface QHVCPlayingTableViewCellTwo ()
{
    UILabel *_titleLabel;
    UIButton *_expansionButton;
    SEL sel;
}

@end

@implementation QHVCPlayingTableViewCellTwo

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    _titleLabel.text = @"解码方式";
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@16);
        make.centerY.equalTo(self);
        make.height.equalTo(@20);
        make.width.equalTo(@100);
    }];
    
    _expansionButton = [UIButton new];
    _expansionButton.hidden = YES;
    [_expansionButton setTitle:@"展开" forState:UIControlStateNormal];
    _expansionButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    [_expansionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview: _expansionButton];
    [_expansionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(self);
        make.height.equalTo(@20);
        make.width.equalTo(@40);
    }];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setRigthButtonHidden:(BOOL)hide
{
    _expansionButton.hidden = hide;
}

- (void)setRigthButtonHidden:(BOOL)hide withTarget:(id)target action:(SEL)action
{
    _expansionButton.hidden = hide;
    if (sel)
    {
        [_expansionButton removeTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    sel = action;
    [_expansionButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
