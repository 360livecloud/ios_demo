//
//  QHVCSettingCellStyleThree.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/4/12.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVSettingCellStyleThree.h"
#import "QHVCITSConfig.h"

@interface QHVCGVSettingCellStyleThree()
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UITextField *_textField;
    IBOutlet UILabel *_arrowLabel;

    NSString *_currentKey;
}

@end

@implementation QHVCGVSettingCellStyleThree

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSMutableDictionary *)dict videoProfileIndex:(NSInteger)index
{
    _titleLabel.text = dict[@"title"];
    
    NSString *key = dict[@"key"];
    _currentKey = key;
    
    NSDictionary *videoProfile = [QHVCITSConfig sharedInstance].videoProfiles[index];
    
    _textField.text = videoProfile[key];
    _textField.enabled = NO;
    
    if([dict[@"enableSelect"] boolValue])
    {
        _arrowLabel.hidden = NO;
        _textField.borderStyle = UITextBorderStyleRoundedRect;
    }
    else
    {
        _arrowLabel.hidden = YES;
        _textField.borderStyle = UITextBorderStyleNone;
    }
    if(index == [QHVCITSConfig sharedInstance].videoProfiles.count - 1)
    {
        if(![key isEqualToString:@"name"])
        {
            _arrowLabel.hidden = YES;
            _textField.borderStyle = UITextBorderStyleRoundedRect;
            _textField.enabled = YES;
        }
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    NSMutableDictionary *videoProfile = [QHVCITSConfig sharedInstance].videoProfiles.lastObject;
    if(textField.text.length > 0)
    {
        [videoProfile setObject:textField.text forKey:_currentKey];
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
