//
//  QHVCPlayingTableViewCellOne.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/4.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPlayingTableViewCellOne.h"

@interface QHVCPlayingTableViewCellOne ()<UITextFieldDelegate>
{
    UIImageView *_logoImageView;
    UILabel *_titleLabel;
    UITextField *_textField;
}

@end

@implementation QHVCPlayingTableViewCellOne

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
    _logoImageView = [UIImageView new];
    [self addSubview:_logoImageView];
    [_logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@18);
        make.centerY.equalTo(self);
        make.height.width.equalTo(@20);
    }];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_logoImageView.mas_right).offset(5);
        make.centerY.equalTo(_logoImageView);
        make.height.equalTo(@20);
        make.width.equalTo(@100);
    }];
    
    _textField = [UITextField new];
    _textField.delegate = self;
    _textField.layer.cornerRadius = 4;
    _textField.layer.masksToBounds = YES;
    _textField.layer.borderWidth = 0.7;
    _textField.textAlignment = NSTextAlignmentLeft;
    _textField.adjustsFontSizeToFitWidth = YES;
    _textField.placeholder = @"点击输入";
    _textField.leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self addSubview:_textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).offset(70);
        make.right.equalTo(self).offset(-18);
        make.height.equalTo(@30);
        make.centerY.equalTo(self);
    }];
}

#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (_callback)
    {
        _callback(_textField.text);
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateCellDetail:(NSMutableDictionary *)item
{
    _logoImageView.image = [UIImage imageNamed:item[@"image"]];
    _titleLabel.text = item[@"title"];
    _textField.text = item[@"value"];
}

@end
