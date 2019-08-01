//
//  QHVCGSRegisterViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/4/17.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSRegisterViewController.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCTool.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGVConfig.h"
#import "QHVCLiveMainCellOne.h"
#import "QHVCToast.h"
#import "QHVCHUDManager.h"
#import "QHVCGodViewHttpBusiness.h"
#import "QHVCGVDefine.h"

@interface QHVCGSRegisterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, nullable) NSMutableArray<NSMutableDictionary *> *registerConfigInfo;
@property (weak, nonatomic) IBOutlet UITableView *generalTableView;

@end

@implementation QHVCGSRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [QHVCTool setStatusBarBackgroundColor:[QHVCGlobalConfig getStatusBarColor]];
    [self loadRegisterConfigInfo];
}

- (void) loadRegisterConfigInfo
{
    NSString* path = [[NSBundle mainBundle] pathForResource:QHVCGV_GODSEES_REGISTER_PLIST_FILE ofType:@"plist"];
    _registerConfigInfo = [NSMutableArray arrayWithContentsOfFile:path];
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _registerConfigInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = _registerConfigInfo[indexPath.row];
    NSString* identifierName = @"QHVCLiveMainCellOne";
    QHVCLiveMainCellOne *cell = [tableView dequeueReusableCellWithIdentifier:identifierName];
    if (!cell)
    {
        [_generalTableView registerNib:[UINib nibWithNibName:identifierName
                                                      bundle:nil]
                forCellReuseIdentifier:identifierName];
        cell = [tableView dequeueReusableCellWithIdentifier:identifierName];
    }
    [cell updateCell:dict encryptProcesString:nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UI事件 -

- (IBAction)clickedBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickedRegisterAction:(id)sender
{
    NSInteger userNameMinLength = 4;
    NSInteger userNameMaxLength = 10;
    NSString* userName = nil;
    NSString* password = nil;
    NSString* passwordConfim = nil;
    for (int i = 0; i < 3; i++)
    {
        QHVCLiveMainCellOne *cell = [_generalTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSMutableDictionary* itemDict = [cell liveItem];
        NSString* value = [QHVCToolUtils getStringFromDictionary:itemDict key:@"value" defaultValue:nil];
        if (i == 0)
        {
            if ([QHVCToolUtils isNullString:value] || value.length < userNameMinLength)
            {
                [QHVCToast makeToast:[NSString stringWithFormat:@"用户名最少%zd位",userNameMinLength]];
                return;
            }
            if (value.length > userNameMaxLength)
            {
                [QHVCToast makeToast:[NSString stringWithFormat:@"用户名最多%zd位",userNameMaxLength]];
                return;
            }
            userName = value;
        }else if (i == 1)
        {
            if ([QHVCToolUtils isNullString:value])
            {
                [QHVCToast makeToast:@"请输入密码"];
                return;
            }
            password = value;
        }else if (i == 2)
        {
            if ([QHVCToolUtils isNullString:value])
            {
                [QHVCToast makeToast:@"请再次输入密码"];
                return;
            }
            passwordConfim = value;
        }
    }
    if (![password isEqualToString:passwordConfim])
    {
        [QHVCToast makeToast:@"两次输入的密码不一致"];
        return;
    }
    QHVCHUDManager *hud = [QHVCHUDManager new];
    [hud showLoadingProgressOnView:self.view message:@"Loading..."];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [QHVCToolUtils setStringToDictionary:params key:@"user_name" value:userName];
    [QHVCToolUtils setStringToDictionary:params key:@"pwd" value:password];
    [QHVCGodViewHttpBusiness registerWithParams:params complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        [hud hideHud];
        NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
        NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
        if (success) {
            NSDictionary *dataDict = [QHVCToolUtils getObjectFromDictionary:responseDict key:QHVCGV_KEY_DATA defaultValue:nil];
            BOOL ret = [QHVCToolUtils getBooleanFromDictionary:dataDict key:@"ret" defaultValue:NO];
            if (ret)
            {
                if (self.successBlock)
                {
                    self.successBlock(userName, password);
                }
                [QHVCToast makeToast:@"注册成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else
            {
                [QHVCToast makeToast:[NSString stringWithFormat:@"注册失败 errno:%zd errmsg:%@",errNo,errmsg]];
            }
        } else
        {
            [QHVCToast makeToast:[NSString stringWithFormat:@"注册失败 errno:%zd errmsg:%@",errNo,errmsg]];
        }
    }];
}

@end
