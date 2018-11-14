//
//  QHVCPlayingTableViewCellThree.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/4.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPlayingTableViewCellThree.h"

@interface QHVCPlayingTableViewCellThree ()
{
    UIButton *softDecodButton;
    UIButton *hardDecodButton;
}

@end

@implementation QHVCPlayingTableViewCellThree

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
    CGFloat width = (CGRectGetWidth(self.frame) - 36)/3;
    NSNumber *wid = [NSNumber numberWithFloat:width];
    
    hardDecodButton = [self createButton];
    hardDecodButton.selected = YES;
    [hardDecodButton setTitle:@"硬解码" forState:UIControlStateNormal];
    [self addSubview:hardDecodButton];
    [hardDecodButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@38);
        make.top.bottom.equalTo(self);
        make.width.equalTo(wid);
    }];
    
    softDecodButton = [self createButton];
    [softDecodButton setTitle:@"软解码" forState:UIControlStateNormal];
    [self addSubview:softDecodButton];
    [softDecodButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-38);
        make.top.bottom.equalTo(self);
        make.width.equalTo(wid);
    }];
}

- (UIButton *)createButton
{
    UIButton *button = [UIButton new];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    button.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [button setImage:[UIImage imageNamed:@"select"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"unselect"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"select"] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];

    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)buttonAction:(UIButton *)button
{
    if (softDecodButton == button)
    {
        [softDecodButton setSelected:YES];
        [hardDecodButton setSelected:NO];
        if (_callback)
        {
            _callback(@"0");
        }
    }
    else
    {
        [softDecodButton setSelected:NO];
        [hardDecodButton setSelected:YES];
        if (_callback)
        {
            _callback(@"1");
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
