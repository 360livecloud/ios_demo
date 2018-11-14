//
//  QHVCLocalServerCachedCell.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/2.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerCachedCell.h"

@interface QHVCLocalServerCachedCell ()
{
    UILabel *titleLabel;
    UILabel *sizeLabel;
    UIButton *deleteButton;
}

@end

@implementation QHVCLocalServerCachedCell

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
    
    NSString *size = [[item valueForKey:@"completeScale"] lastPathComponent];
    [sizeLabel setText:size];
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
    sizeLabel.text = @"120M";
    sizeLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:sizeLabel];
    [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.left.equalTo(@20);
        make.height.equalTo(@20);
    }];
    
    deleteButton = [UIButton new];
    [deleteButton setImage:[UIImage imageNamed:@"deleteFile"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
        make.width.height.equalTo(@30);
    }];
}

- (void)deleteAction:(UIButton *)button
{
    if (_deleteFile)
    {
        _deleteFile();
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
