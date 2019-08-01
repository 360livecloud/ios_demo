//
//  QHVCGVDeviceListViewController.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVDeviceListViewController.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGodViewLocalManager.h"
#import "QHVCGVDefine.h"
#import "QHVCGVWatchLivingViewController.h"
#import "QHVCGVUserSystem.h"
#import "QHVCGVDeviceModel.h"
#import "QHVCGSDeviceListCell.h"
#import "QHVCGVConfig.h"
#import "QHVCGSBindDeviceViewController.h"
#import "QHVCHUDManager.h"
#import "QHVCToast.h"
#import "QHVCGVStreamSecureManager.h"
#import "QHVCGVAlertView.h"
#import "QHVCGVSignallingManager.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGodViewHttpBusiness.h"

#define kQHVCGVDeviceListCellSeparateHeight   7.0f

// 常量
static NSString *kQHVCGSDeviceListCellIdentifier = @"QHVCGSDeviceListCell";

@interface QHVCGVDeviceListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *generalTableView;
@property (nonatomic,strong) NSMutableArray *deviceListArray;

@end

@implementation QHVCGVDeviceListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDeviceListData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setGodSeesConfigurationParameters];
}

#pragma mark - 私有方法 -
- (void)setGodSeesConfigurationParameters
{
    NSMutableArray *userSettings = [QHVCGVConfig sharedInstance].userSettings;
    NSArray *configs = [QHVCToolUtils getObjectFromDictionary:userSettings[0] key:@"config" defaultValue:nil];
    // 连接方式,此处需要重新设计修改
//    BOOL enableP2P = [QHVCToolUtils getBooleanFromDictionary:configs[1] key:@"index" defaultValue:YES];
//    [[QHVCGodViewLocalManager sharedInstance] enableGodSeesP2P:enableP2P];//?????可以调用连接方式接口
//    [[QHVCGodViewLocalManager sharedInstance] enableGodSeesVideoStateMonitor:[[QHVCGVConfig sharedInstance] shouldShowPerformanceInfo]];
}

#pragma mark - UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _deviceListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCGSDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:kQHVCGSDeviceListCellIdentifier];
    if (!cell)
    {
        [_generalTableView registerNib:[UINib nibWithNibName:kQHVCGSDeviceListCellIdentifier
                                                      bundle:nil]
                forCellReuseIdentifier:kQHVCGSDeviceListCellIdentifier];
        cell = [_generalTableView dequeueReusableCellWithIdentifier:kQHVCGSDeviceListCellIdentifier];
    }
    QHVCGVDeviceModel *model = _deviceListArray[indexPath.section];
    [cell updateCell:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QHVCGVDeviceModel *deviceModel = _deviceListArray[indexPath.section];
    // 更新房间信息
    QHVCGVRoomModel *roomInfo = [QHVCGVRoomModel new];
    roomInfo.roomId = deviceModel.bindedSN;
    roomInfo.roomName = deviceModel.name;
    roomInfo.deviceTalkId = deviceModel.talkId;
    [QHVCGVUserSystem sharedInstance].roomInfo = roomInfo;
    
    UIViewController *viewController = nil;
    if (deviceModel.isPublic == 0)
    {
        QHVCGVWatchLivingViewController *watchLivingVC = [QHVCGVWatchLivingViewController new];
        watchLivingVC.deviceModel = deviceModel;
        viewController = watchLivingVC;
    }
    
    [[QHVCGVStreamSecureManager sharedManager] setCurrentWatchingSN:deviceModel.bindedSN];
    
    // 检测密码是否过期 如果过期 立刻从服务器拉取
    if ([[QHVCGVStreamSecureManager sharedManager] isPasswordExpireWithSN:deviceModel.bindedSN])
    {
        QHVCHUDManager *hud = [QHVCHUDManager new];
        [hud showLoadingProgressOnView:self.view message:@"Loading..."];
        QHVC_WEAK_SELF
        [[QHVCGVStreamSecureManager sharedManager] updatePwdsFromServerWithSN:deviceModel.bindedSN completion:^(BOOL success,NSDictionary *responseDict) {
            QHVC_STRONG_SELF
            [hud hideHud];
            if (success)
            {
                [self.navigationController pushViewController:viewController animated:YES];
            } else
            {
                NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
                NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
                [QHVCToast makeToast:[NSString stringWithFormat:@"获取流秘钥失败 errno:%zd errmsg:%@",errNo,errmsg]];
            }
        }];
    } else
    {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *separateView = [UIView new];
    separateView.backgroundColor = [QHVCToolUtils colorWithHexString:@"F0F0F0"];
    separateView.frame = CGRectMake(0, 0, kQHVCScreenWidth, kQHVCGVDeviceListCellSeparateHeight);
    return separateView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kQHVCGVDeviceListCellSeparateHeight;
}

#pragma mark - 滑动删除代理 -

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view setNeedsLayout];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCGVDeviceModel *model = _deviceListArray[indexPath.section];
    QHVCGVAlertView *alertView = [QHVCGVAlertView alertWithMsg:@"确定要移除设备吗？" icon:kQHVCGetImageWithName(@"godview_alert_warning") clickHandler:^(NSInteger index) {
        if (index == 0)
        {
            [self unbindDeviceSN:model.bindedSN indexPath:indexPath];
        }
    }];
    [alertView showInView:[UIApplication sharedApplication].keyWindow];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除设备";
}

#pragma mark - Others


/**
 * 预连设备
 */
- (void)preConnectDevices:(NSArray<QHVCGVDeviceModel *> *)devices
{
    for (QHVCGVDeviceModel *device in devices)
    {
        [[QHVCGodViewLocalManager sharedInstance] preConnectGodSeesDevice:device.bindedSN deviceChannelNumber:1];
    }
}

- (void)updateStreamPwdsFromDeviceList:(NSArray<QHVCGVDeviceModel *> *)lists {
    NSMutableArray *pwds = [[NSMutableArray alloc] initWithCapacity:lists.count];
    for (QHVCGVDeviceModel *device in lists) {
        QHVCGVStreamPasswordModel *pwdModel = [QHVCGVStreamPasswordModel new];
        pwdModel.sn = device.bindedSN;
        pwdModel.lastPwdDate = [NSDate date];
        pwdModel.refreshInterval = device.pwdFetchInterval;
        pwdModel.pwds = device.pwds;
        [pwds addObject:pwdModel];
    }
    [[QHVCGVStreamSecureManager sharedManager] updatePwdsByDevicelist:pwds];
}

#pragma mark - UI事件 -

- (IBAction)clickedBackAction:(id)sender
{
    [[QHVCGVSignallingManager sharedInstance] disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickedBindDeviceAction:(id)sender
{
    QHVCGSBindDeviceViewController *bindDeviceVC = [QHVCGSBindDeviceViewController new];
    [self.navigationController pushViewController:bindDeviceVC animated:YES];
}

- (void)unbindDeviceSN:(NSString *)sn indexPath:(NSIndexPath *)indexPath
{
    QHVCHUDManager *hud = [QHVCHUDManager new];
    [hud showLoadingProgressOnView:self.view message:@"Loading..."];
    QHVC_WEAK_SELF
    [self unbindDeviceSN:sn completion:^(BOOL isSuccess) {
        [hud hideHud];
        QHVC_STRONG_SELF
        if (isSuccess)
        {
            [_generalTableView beginUpdates];
            [_generalTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
            [_deviceListArray removeObjectAtIndex:indexPath.row];
            [_generalTableView endUpdates];
            [[QHVCGVStreamSecureManager sharedManager] removeSecureManagerWithSN:sn];
            self.emptyView.hidden = _deviceListArray.count > 0;
        }
    }];
}

#pragma mark - 服务器协议交互 -

- (void)refreshDeviceListData
{
    QHVC_WEAK_SELF
    QHVCHUDManager *hud = [QHVCHUDManager new];
    [hud showLoadingProgressOnView:self.view message:@"Loading..."];
    [QHVCGodViewHttpBusiness getBindListComplete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        [hud hideHud];
        QHVC_STRONG_SELF
        if (success)
        {
            NSDictionary *dataDict = [QHVCToolUtils getObjectFromDictionary:responseDict key:QHVCGV_KEY_DATA defaultValue:nil];
            NSArray *list = [QHVCToolUtils getObjectFromDictionary:dataDict key:@"list" defaultValue:nil];
            NSMutableArray *deviceLists = [NSMutableArray new];
            for (NSDictionary * dict in list)
            {
                if (![QHVCToolUtils dictionaryIsNull:dict])
                {
                    QHVCGVDeviceModel *deviceModel = [[QHVCGVDeviceModel alloc] initWithDict:dict];
                    [deviceLists addObject:deviceModel];
                }
            }
            self.deviceListArray = [deviceLists mutableCopy];
            [self.generalTableView reloadData];
            [self preConnectDevices:self.deviceListArray];
            [self updateStreamPwdsFromDeviceList:self.deviceListArray];
            self.emptyView.hidden = self.deviceListArray.count > 0;
        } else
        {
            NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
            NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
            [QHVCToast makeToast:[NSString stringWithFormat:@"刷新列表失败 errno:%zd errmsg:%@",errNo,errmsg]];
        }
    }];
}

- (void)refreshDeviceListWithCompletion:(void(^)(NSArray<QHVCGVDeviceModel *> *lists))completion
{
    [QHVCGodViewHttpBusiness getBindListComplete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        if (success) {
            NSDictionary *dataDict = [QHVCToolUtils getObjectFromDictionary:responseDict key:QHVCGV_KEY_DATA defaultValue:nil];
            NSArray *list = [QHVCToolUtils getObjectFromDictionary:dataDict key:@"list" defaultValue:nil];
            NSMutableArray *deviceLists = [NSMutableArray new];
            for (NSDictionary * dict in list) {
                if (![QHVCToolUtils dictionaryIsNull:dict]) {
                    QHVCGVDeviceModel *deviceModel = [[QHVCGVDeviceModel alloc] initWithDict:dict];
                    [deviceLists addObject:deviceModel];
                }
            }
            if (completion) {
                completion(deviceLists);
            }
        }
        else {
            if (completion) {
                completion(nil);
            }
            NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
            NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
            [QHVCToast makeToast:[NSString stringWithFormat:@"刷新列表失败 errno:%zd errmsg:%@",errNo,errmsg]];
        }
    }];
}

- (void)unbindDeviceSN:(NSString *)deviceSN completion:(void(^)(BOOL isSuccess))completion
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [QHVCToolUtils setStringToDictionary:dict key:@"binded_sn" value:deviceSN];
    [QHVCGodViewHttpBusiness unbindDeviceWithParams:dict complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable responseDict) {
        if (success)
        {
            if (completion)
            {
                completion(success);
            }
        } else
        {
            NSString *errmsg = [QHVCToolUtils getStringFromDictionary:responseDict key:QHVCGV_KEY_ERROR_MESSAGE defaultValue:@""];
            NSInteger errNo = [QHVCToolUtils getIntFromDictionary:responseDict key:QHVCGV_KEY_ERROR_NUMBER defaultValue:0];
            [QHVCToast makeToast:[NSString stringWithFormat:@"刷新列表失败 errno:%zd errmsg:%@",errNo,errmsg]];
        }
    }];
}

@end
