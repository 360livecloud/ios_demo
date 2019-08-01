//
//  QHVCInteractiveViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/1/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCInteractiveViewController.h"
#import "QHVCLiveMainCellOne.h"
#import "QHVCITSRoomListViewController.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <QHVCInteractiveKit/QHVCInteractiveKit.h>

#import "QHVCITSUserSystem.h"
#import "QHVCITSConfig.h"
#import "QHVCITSHTTPSessionManager.h"
#import "QHVCITSProtocolMonitor.h"
#import "QHVCITSUserSystem.h"
#import "QHVCITSUserModel.h"
#import "QHVCITSSettingViewController.h"
#import "QHVCGlobalConfig.h"
#import "QHVCToast.h"
#import "QHVCITSModelListViewController.h"
#import "QHVCITSChatManager.h"
#import "QHVCLogger.h"
#import "QHVCTool.h"

#define kNum 4

static NSString *mainCellIdenitifer = @"QHVCLiveMainCellOne";

@interface QHVCInteractiveViewController ()<UITableViewDelegate,UITableViewDataSource,QHVCITSChatMessageDelegate>
{
    IBOutlet UITableView *generalTableView;
    NSMutableArray<NSMutableDictionary *> *_configsArray;
    __weak IBOutlet NSLayoutConstraint *loginContraintBottom;
}

@property (nonatomic, strong) QHVCITSHTTPSessionManager* httpManager;

@end

@implementation QHVCInteractiveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [QHVCTool setStatusBarBackgroundColor:[QHVCGlobalConfig getStatusBarColor]];
    
    [[QHVCITSConfig sharedInstance] setSessionId:[NSString stringWithFormat:@"session_yk_test_%lld",[QHVCToolUtils getCurrentDateBySecond]]];
    [[QHVCITSConfig sharedInstance] setDeviceId:[QHVCToolDeviceModel getDeviceUUID]];
    
    _httpManager = [QHVCITSHTTPSessionManager new];
    
    //输入业务标识、服务标识、AK、SK等配置信息，请在QHVCITLMain.plist中配置
    //优先读取本地保存的配置文件，如果有配置文件，优先读取本地保存文件；如果无配置文件，读取默认配置文件。该处文件包括QHVCITLMain和InteractiveSetting的内容
    [[QHVCITSConfig sharedInstance] readAccountSetting];
    [[QHVCITSConfig sharedInstance] readUserSetting];
    _configsArray = [[QHVCITSConfig sharedInstance] accountSettings];
}

#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _configsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = _configsArray[indexPath.row];
    
    QHVCLiveMainCellOne *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdenitifer];
    if (!cell) {
        [generalTableView registerNib:[UINib nibWithNibName:mainCellIdenitifer
                                                     bundle:nil]
               forCellReuseIdentifier:mainCellIdenitifer];
        cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdenitifer];
    }
    NSString* encryptString = nil;
    if (indexPath.row == 2)
    {
        encryptString = kQHVCInteractiveAppKey;
    }else if (indexPath.row == 3)
    {
        encryptString = kQHVCInteractiveAppSecret;
    }
    [cell updateCell:dic encryptProcesString:encryptString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark Action

- (IBAction)clickedBackAction:(id)sender
{
    [[QHVCITSChatManager sharedManager] disconnectChatServer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickedSettingAction:(id)sender
{
    QHVCITSSettingViewController *vc = [[QHVCITSSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickedLoginAction:(UIButton *)sender
{
    for (NSInteger i = 0; i < kNum; i++) {
        NSString *value = _configsArray[i][QHVCITS_KEY_VALUE];
        if (value.length <= 0) {
            [QHVCToast makeToast:[NSString stringWithFormat:@"请输入有效的%@",_configsArray[i][QHVCITS_KEY_TITLE]]];
            return;
        }
    }
    
    [QHVCITSConfig sharedInstance].businessId = _configsArray[0][QHVCITS_KEY_VALUE];
    [QHVCITSConfig sharedInstance].channelId = _configsArray[1][QHVCITS_KEY_VALUE];
    [QHVCITSConfig sharedInstance].appKey = _configsArray[2][QHVCITS_KEY_VALUE];
    [QHVCITSConfig sharedInstance].appSecret = _configsArray[3][QHVCITS_KEY_VALUE];
    //启动长链服务
    [[QHVCITSChatManager sharedManager] setDelegate:self];
    [[QHVCITSChatManager sharedManager] connectChatServer];
}

#pragma mark - QHVCITSChatMessageDelegate -
- (void)onChatDidRegisterClient:(NSString *)clientId
{
    NSString* tmpClientId = nil;
    NSRange range = [clientId rangeOfString:[NSString stringWithFormat:@"@%@",QHVCITS_QHPUSH_APPKEY]];
    if (range.location == NSNotFound)
    {
        tmpClientId = clientId;
    }else
    {
        tmpClientId = [clientId substringToIndex:range.location];
    }
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_INFO content:[NSString stringWithFormat:@"QHVCITSChatDidRegisterClient, clientId:%@",tmpClientId]];
    [QHVCITSConfig sharedInstance].clientId = tmpClientId;
    WEAK_SELF_LINKMIC
    [QHVCITSProtocolMonitor getUserLogin:_httpManager
                                    dict:nil
                                complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                    STRONG_SELF_LINKMIC
                                    [self handleLoginResponse:success dict:dict];
                                }];
}

- (void)onChatDidOccurError:(NSError *)error
{
    [QHVCToast makeToast:[NSString stringWithFormat:@"登录失败，长链错误：%@",error.description]];
}

- (void)handleLoginResponse:(BOOL)success dict:(NSDictionary *)dict
{
    if (success) {
        QHVCITSUserModel *user = [[QHVCITSUserModel alloc] init];
        NSDictionary *data = dict[@"data"];
        user.userId = data[@"userId"];
        user.nickName = data[@"nickname"];
        if (user.nickName.length <= 0) {
            user.nickName = user.userId;
        }
        user.portraint = data[@"portraint"];
        user.imContext = data[@"imContext"];
        [QHVCITSUserSystem sharedInstance].userInfo = user;
        
        [self gotoModelListViewController];
    }
    else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"%@,%@",dict[@"errno"],dict[@"errmsg"]];
        [QHVCToast makeToast:errorMsg];
    }
}

- (void)gotoModelListViewController
{
    QHVCITSModelListViewController *vc = [[QHVCITSModelListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
