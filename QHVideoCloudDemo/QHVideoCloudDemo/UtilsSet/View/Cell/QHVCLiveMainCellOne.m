//
//  QHVCLiveMainCellOne.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/6/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLiveMainCellOne.h"
#import "QHVCGlobalConfig.h"
#import "QHVCITSDefine.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@interface QHVCLiveMainCellOne ()<UITextFieldDelegate>
{
    IBOutlet UIImageView *_logoImageView;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UITextField *_textField;
    NSString* _encryptString;
}

@end

@implementation QHVCLiveMainCellOne

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(NSMutableDictionary *)item encryptProcesString:(NSString *)encryptString
{
    self.liveItem = item;
    _encryptString = encryptString;
    
    _logoImageView.image = [UIImage imageNamed:item[QHVCITS_KEY_IMAGE]];
    _titleLabel.text = item[QHVCITS_KEY_TITLE];
    _textField.text = item[QHVCITS_KEY_VALUE];
    _textField.enabled = YES;
    
    [self processTextFieldEncrypt:_textField];
    
    if ([[item allKeys] containsObject:@"edit"]) {
        BOOL isEdit = [[item valueForKey:@"edit"] boolValue];
        _textField.enabled = isEdit;
    }
}

- (void) processTextFieldEncrypt:(UITextField *)textField
{
    if (![QHVCToolUtils isNullString:_encryptString])
    {
        if ([textField.text isEqualToString:_encryptString])
        {
            textField.secureTextEntry = YES;
        } else
        {
            textField.secureTextEntry = NO;
        }
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![QHVCToolUtils isNullString:_encryptString])
    {
        if (textField.isSecureTextEntry && [textField.text isEqualToString:_encryptString])
        {
            textField.text = string;
            textField.secureTextEntry = NO;
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.liveItem setObject:textField.text forKey:QHVCITS_KEY_VALUE];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
