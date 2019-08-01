//
//  QHVCGSLANDeviceAuthAlert.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/21.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSLANDeviceAuthAlert.h"

@interface QHVCGSLANDeviceAuthAlert ()<UITextFieldDelegate>
{
    IBOutlet UITextField *verificationCode;
    IBOutlet UILabel *deviceIdLabel;
    IBOutlet UIButton *cancel;
    IBOutlet UIButton *confirm;
}

@end

@implementation QHVCGSLANDeviceAuthAlert

-(void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setdID:(NSString *)dID
{
    deviceIdLabel.text = dID;
}

- (IBAction)btnCancel:(id)sender
{
    [self hide];
}

- (IBAction)btnOk:(id)sender
{
    [self hide];
}

- (void)hide
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
