//
//  QHVCLocalServerDownloadingCell.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/2.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerDownloadingCell.h"

@interface QHVCLocalServerDownloadingCell ()
{
    UILabel *titleLabel;
    UILabel *sizeLabel;
    UIProgressView *slider;
    UIButton *pauseResumeButton;
    UIButton *deleteButton;
}

@end

@implementation QHVCLocalServerDownloadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSubViews];
    }
    
    return self;
}

- (void)setDetails:(NSDictionary *)item
{
    [titleLabel setText:[item valueForKey:@"title"]];
    [slider setProgress:[[item valueForKey:@"progress"] floatValue]];
    [sizeLabel setText:[item valueForKey:@"completeScale"]];
}

- (void)setDownloading:(BOOL)isUpdating
{
    pauseResumeButton.selected = isUpdating;
}

- (void)initSubViews
{
    titleLabel = [UILabel new];
    titleLabel.text = @"国民大生活";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(@20);
        make.height.equalTo(@20);
        make.width.equalTo(@200);
    }];
    
    sizeLabel = [UILabel new];
    sizeLabel.text = @"40/120M";
    sizeLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:sizeLabel];
    [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).offset(-80);
        make.height.equalTo(@20);
    }];
    
    deleteButton = [UIButton new];
    [deleteButton setImage:[UIImage imageNamed:@"deleteDownload"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
        make.width.height.equalTo(@30);
    }];
    
    pauseResumeButton = [UIButton new];
    [pauseResumeButton setImage:[UIImage imageNamed:@"tab_play"] forState:UIControlStateNormal];
    [pauseResumeButton setImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateSelected];
    [pauseResumeButton addTarget:self action:@selector(pauseResumeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pauseResumeButton];
    [pauseResumeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(deleteButton.mas_left);
        make.centerY.equalTo(self);
        make.width.height.equalTo(@30);
    }];
    
    slider = [UIProgressView new];
    slider.progressTintColor = [UIColor colorWithRed:65/255.0 green:172/255.0 blue:251/255.0 alpha:1];
    slider.trackTintColor = QHVC_COLOR_VIEW_WHITE;
    [self addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.equalTo(pauseResumeButton.mas_left).offset(-10);
        make.centerY.equalTo(self);
        make.height.equalTo(@5);
    }];
}

- (void)deleteAction:(UIButton *)button
{
    if (_deleteAction)
    {
        _deleteAction();
    }
}

- (void)pauseResumeAction:(UIButton *)button
{
    button.selected = !button.selected;
    if (_pauseResumeAction)
    {
        _pauseResumeAction(button.selected);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
