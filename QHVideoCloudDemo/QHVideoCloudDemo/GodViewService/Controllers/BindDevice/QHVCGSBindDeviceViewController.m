//
//  QHVCGSBindDeviceViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/4/22.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSBindDeviceViewController.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCToast.h"
#import "QHVCHUDManager.h"
#import "QHVCGodViewHttpBusiness.h"
#import "QHVCGVDefine.h"
#import "QHVCGlobalConfig.h"

@interface QHVCGSBindDeviceViewController ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextField *inputTextField;
    __weak IBOutlet UISegmentedControl *deviceTypeSegmented;
    
    NSInteger deviceType;
}

@end

@implementation QHVCGSBindDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    deviceType = 0;
}

#pragma mark - UI Action -

- (IBAction)clickedBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickedDeviceTypeAction:(id)sender
{
    UISegmentedControl* segmentControl = (UISegmentedControl *)sender;
    deviceType = segmentControl.selectedSegmentIndex;
}

- (IBAction)clickedCommitDeviceAction:(id)sender
{
    NSString* SN = inputTextField.text;
    if ([QHVCToolUtils isNullString:SN])
    {
        [QHVCToast makeToast:@"请输入设备SN"];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [QHVCToolUtils setStringToDictionary:dict key:@"binded_sn" value:SN];
    [QHVCToolUtils setLongToDictionary:dict key:@"is_public" value:deviceType];
    
    QHVCHUDManager *hud = [QHVCHUDManager new];
    [hud showLoadingProgressOnView:self.view message:@"Loading..."];
    QHVC_WEAK_SELF
    [QHVCGodViewHttpBusiness bindDeviceWithParams:dict complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        [hud hideHud];
       QHVC_STRONG_SELF
        if (success)
        {
            [QHVCToast makeToast:@"添加成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else
        {
            NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
            NSString *errMsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:nil];
            [QHVCToast makeToast:[NSString stringWithFormat:@"添加失败,errno:%zd  errms:%@",errNo,errMsg]];
        }
    }];
}

#pragma mark - 

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
