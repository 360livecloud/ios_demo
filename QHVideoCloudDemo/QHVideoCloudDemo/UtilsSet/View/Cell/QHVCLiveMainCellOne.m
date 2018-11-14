//
//  QHVCLiveMainCellOne.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/6/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLiveMainCellOne.h"

@interface QHVCLiveMainCellOne ()<UITextFieldDelegate>
{
    IBOutlet UIImageView *_logoImageView;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UITextField *_textField;
}

@property (nonatomic, strong) NSMutableDictionary *liveItem;

@end

@implementation QHVCLiveMainCellOne

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSMutableDictionary *)item
{
    self.liveItem = item;
    
    _logoImageView.image = [UIImage imageNamed:item[@"image"]];
    _titleLabel.text = item[@"title"];
    _textField.text = item[@"value"];
    _textField.enabled = YES;
    
    if ([[item allKeys] containsObject:@"edit"]) {
        BOOL isEdit = [[item valueForKey:@"edit"] boolValue];
        _textField.enabled = isEdit;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.liveItem setObject:textField.text forKey:@"value"];
    
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
