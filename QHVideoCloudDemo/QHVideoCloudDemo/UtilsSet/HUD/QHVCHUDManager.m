//
//  QHVCHUDManager.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/6.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCHUDManager.h"

@interface QHVCHUDManager ()

@property (nonatomic, strong) MBProgressHUD *textOnlyHUD;

@end

@implementation QHVCHUDManager

- (void)showLoadingProgressOnView:(UIView *)view message:(NSString *)message
{
    if (_textOnlyHUD)
    {
        _textOnlyHUD.delegate = nil;
        if ([_textOnlyHUD isDescendantOfView:view])
        {
            [_textOnlyHUD removeFromSuperview];
        }
    }
    
    self.textOnlyHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    _textOnlyHUD.mode = MBProgressHUDModeIndeterminate;
    _textOnlyHUD.bezelView.backgroundColor = [UIColor blackColor];
    _textOnlyHUD.contentColor = [UIColor whiteColor];
    _textOnlyHUD.label.text = message;
    _textOnlyHUD.label.textColor = [UIColor whiteColor];
    _textOnlyHUD.margin = 10.0f;
    _textOnlyHUD.layer.cornerRadius = 3.0f;
    _textOnlyHUD.removeFromSuperViewOnHide = YES;
}

- (void)showTextOnlyAlertViewOnView:(UIView *)view message:(NSString *)message hideFlag:(BOOL)hideFlag
{
    if (_textOnlyHUD)
    {
        _textOnlyHUD.delegate = nil;
        if ([_textOnlyHUD isDescendantOfView:view])
        {
            [_textOnlyHUD removeFromSuperview];
        }
    }
    
    self.textOnlyHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    _textOnlyHUD.mode = MBProgressHUDModeText;
    _textOnlyHUD.bezelView.backgroundColor = [UIColor blackColor];
    _textOnlyHUD.label.text = message;
    _textOnlyHUD.label.textColor = [UIColor whiteColor];
    _textOnlyHUD.margin = 10.0f;
    _textOnlyHUD.layer.cornerRadius = 3.0f;
    _textOnlyHUD.removeFromSuperViewOnHide = YES;
    
    if (hideFlag)
    {
        [_textOnlyHUD hideAnimated:YES afterDelay:1.5f];
    }
}

- (void)showTextOnlyAlertViewOnWindow:(NSString *)message hideFlag:(BOOL)hideFlag
{
    if (_textOnlyHUD)
    {
        _textOnlyHUD.delegate = nil;
        [_textOnlyHUD removeFromSuperview];
    }
    
    self.textOnlyHUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    _textOnlyHUD.mode = MBProgressHUDModeText;
    _textOnlyHUD.bezelView.backgroundColor = [UIColor blackColor];
    _textOnlyHUD.label.text = message;
    _textOnlyHUD.label.textColor = [UIColor whiteColor];
    _textOnlyHUD.margin = 10.0f;
    _textOnlyHUD.layer.cornerRadius = 3.0f;
    _textOnlyHUD.removeFromSuperViewOnHide = YES;
    
    if (hideFlag)
    {
        [_textOnlyHUD hideAnimated:YES afterDelay:1.5f];
    }
}

- (void)hideHud
{
    [_textOnlyHUD hideAnimated:NO];
}

@end
