//
//  QHVCGVLoginViewController.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <QHVCCommonKit/QHVCCommonKit.h>

#import "QHVCGodViewController.h"
#import "QHVCLiveMainCellOne.h"
#import "QHVCGVConfig.h"
#import "QHVCGVDeviceListViewController.h"
#import "QHVCGSLANDeviceListViewController.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGVUserSystem.h"
#import "QHVCGVSignallingManager.h"
#import "QHVCGodViewHttpBusiness.h"
#import "QHVCToast.h"
#import "QHVCHUDManager.h"
#import "QHVCGSSettingViewController.h"
#import "QHVCGSRegisterViewController.h"
#import "QHVCGodViewLocalManager.h"
#import "QHVCGVDefine.h"
#import "QHVCGSLANDeviceListViewController.h"
#import "QHVCLogger.h"
#import "QHVCTool.h"
//#import "AudioPlayLibrary.h"

@interface QHVCGodViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,QHVCToolLifeCycleDelegate>

@property (weak, nonatomic) IBOutlet UITableView *generalTableView;
@property (nonatomic, strong, nullable) NSMutableArray<NSMutableDictionary *> *accountSettings;

@end


@implementation QHVCGodViewController
{
    AFHTTPSessionManager *manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [QHVCTool setStatusBarBackgroundColor:[QHVCGlobalConfig getStatusBarColor]];
    [self initConfiguration];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)initConfiguration
{
    [[QHVCGVConfig sharedInstance] readAccountSetting];
    [[QHVCGVConfig sharedInstance] readUserSettings];
    _accountSettings = [[QHVCGVConfig sharedInstance] accountSettings];
}

#pragma mark - UITableView -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _accountSettings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = _accountSettings[indexPath.row];
    NSString* identifierName = @"QHVCLiveMainCellOne";
    QHVCLiveMainCellOne *cell = [tableView dequeueReusableCellWithIdentifier:identifierName];
    if (!cell)
    {
        [_generalTableView registerNib:[UINib nibWithNibName:identifierName
                                                      bundle:nil]
                forCellReuseIdentifier:identifierName];
        cell = [tableView dequeueReusableCellWithIdentifier:identifierName];
    }
    NSString* encryptString = nil;
    if (indexPath.row == 1)
    {
        encryptString = kQHVCGodSeesAppKey;
    }else if (indexPath.row == 2)
    {
        encryptString = kQHVCGodSeesAppSecret;
    }
    [cell updateCell:dict encryptProcesString:encryptString];
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

- (IBAction)clickedSettingAction:(id)sender
{
    QHVCGSSettingViewController *settingVC = [QHVCGSSettingViewController new];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (IBAction)clickedRegisterAction:(id)sender
{
    QHVCGSRegisterViewController *registerVC = [QHVCGSRegisterViewController new];
    registerVC.successBlock = ^(NSString *userName, NSString* password) {
        NSInteger userNameRow = 3;
        NSInteger passwordRow = 4;
        [QHVCToolUtils setStringToDictionary:_accountSettings[userNameRow] key:@"value" value:userName];
        [QHVCToolUtils setStringToDictionary:_accountSettings[passwordRow] key:@"value" value:password];
        [[QHVCGVConfig sharedInstance] updateAccountSettings:_accountSettings];
        [_generalTableView reloadData];
    };
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)clickedLoginAction:(id)sender
{
    NSString* appName = nil;
    NSString* appKey = nil;
    NSString* appSecret = nil;
    NSString* userName = nil;
    NSString* password = nil;
    for (int i = 0; i < 5; i++)
    {
        QHVCLiveMainCellOne *cell = [_generalTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        NSDictionary* dict = [cell liveItem];
        NSString* value = [QHVCToolUtils getStringFromDictionary:dict key:@"value" defaultValue:nil];
        switch (i) {
            case 0:
                if ([QHVCToolUtils isNullString:value])
                {
                    [QHVCToast makeToast:@"请输入应用名称"];
                    return;
                }
                appName = value;
                break;
            case 1:
                if ([QHVCToolUtils isNullString:value])
                {
                    [QHVCToast makeToast:@"请输入AppKey"];
                    return;
                }
                appKey = value;
                break;
            case 2:
                if ([QHVCToolUtils isNullString:value])
                {
                    [QHVCToast makeToast:@"请输入AppSecret"];
                    return;
                }
                appSecret = value;
                break;
            case 3:
                if ([QHVCToolUtils isNullString:value])
                {
                    [QHVCToast makeToast:@"请输入用户名"];
                    return;
                }
                userName = value;
                break;
            case 4:
                if ([QHVCToolUtils isNullString:value])
                {
                    [QHVCToast makeToast:@"请输入密码"];
                    return;
                }
                password = value;
                break;
        }
    }
    //保存最后一次输入
    [QHVCToolUtils setStringToDictionary:_accountSettings[0] key:@"value" value:appName];
    [QHVCToolUtils setStringToDictionary:_accountSettings[1] key:@"value" value:appKey];
    [QHVCToolUtils setStringToDictionary:_accountSettings[2] key:@"value" value:appSecret];
    [QHVCToolUtils setStringToDictionary:_accountSettings[3] key:@"value" value:userName];
    [QHVCToolUtils setStringToDictionary:_accountSettings[4] key:@"value" value:password];
    [[QHVCGVConfig sharedInstance] updateAccountSettings:_accountSettings];
    
    QHVCHUDManager *hud = [QHVCHUDManager new];
    [hud showLoadingProgressOnView:self.view message:@"努力加载中..."];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [QHVCToolUtils setStringToDictionary:params key:@"user_name" value:userName];
    [QHVCToolUtils setStringToDictionary:params key:@"pwd" value:password];
    
    [QHVCGodViewHttpBusiness loginWithParams:params complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict)
    {
        if (success)
        {
            NSDictionary *dataDict = [QHVCToolUtils getObjectFromDictionary:responseDict key:QHVCGV_KEY_DATA defaultValue:nil];
            NSString *uid = [QHVCToolUtils getStringFromDictionary:dataDict key:QHVCGV_KEY_USER_ID defaultValue:@""];
            NSString *token = [QHVCToolUtils getStringFromDictionary:dataDict key:QHVCGV_KEY_TOKEN defaultValue:@""];
            NSString *talkId = [QHVCToolUtils getStringFromDictionary:dataDict key:QHVCGV_KEY_TALK_ID defaultValue:@""];
            // 更新用户信息
            QHVCGVUserModel *userInfo = [QHVCGVUserModel new];
            userInfo.token = token;
            userInfo.userId = uid;
            userInfo.talkId = talkId;
            userInfo.nickName = [QHVCGVConfig sharedInstance].userName;
            [QHVCGVUserSystem sharedInstance].userInfo = userInfo;
            // 建立信令连接
            [[QHVCGVSignallingManager sharedInstance] connectToHost:[QHVCGVConfig sharedInstance].signallingServerAddress userId:userInfo.talkId handler:^(BOOL isConnected)
            {
                [hud hideHud];
                if (isConnected == NO)
                {
                    [QHVCToast makeToast:@"信令链接失败"];
                    return;
                }
                // 跳转设备列表页
                QHVCGVDeviceListViewController* deviceList = [QHVCGVDeviceListViewController new];
                [self.navigationController pushViewController:deviceList animated:YES];
            }];
        } else
        {
            [hud hideHud];
            NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
            [QHVCToast makeToast:errmsg];
        }
    }];
}

- (IBAction)clickedLanModelAction:(id)sender
{
    QHVCGSLANDeviceListViewController *deviceListVC = [QHVCGSLANDeviceListViewController new];
    [self.navigationController pushViewController:deviceListVC animated:YES];
}

- (void)clickedSoundWaveButton:(id)send
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:dict key:@"wifiName" value:@"wifiName1234"];
    [QHVCToolUtils setStringToDictionary:dict key:@"userName" value:@"test12345"];
    [QHVCToolUtils setStringToDictionary:dict key:@"password" value:@"password9876!#$%"];
    NSData* dictData = [QHVCToolUtils createJsonDataWithDictionary:dict];
    NSString* dictString = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
    NSString* savePath = [NSTemporaryDirectory() stringByAppendingString:@"soundWave"];
    //    int result = [AudioPlayLibrary createWav:dictString toPath:savePath];
    
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:@"clickedSoundWaveButton" dict:nil];
}

@end

