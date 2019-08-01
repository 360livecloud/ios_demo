//
//  QHVCGSLANDeviceListViewController.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/15.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSLANDeviceListViewController.h"
#import "QHVCGSLANDeviceModel.h"
#import "QHVCGVDeviceListCell.h"
#import "QHVCGSLANDeviceManager.h"
#import "QHVCGSLANDeviceListCell.h"
#import "QHVCGSLANDeviceListHeaderView.h"
#import "QHVCToast.h"
#import "QHVCGSLANDeviceAuthAlert.h"
#import "QHVCGVWatchLivingViewController.h"
#import "QHVCGVDeviceModel.h"
#import "QHVCGVUserSystem.h"

static NSString *const kQHVCGSLANDeviceListCellReuseIdentifier = @"QHVCGSLANDeviceListCell";
static NSString *const kQHVCGSLANDeviceListHeaderReuseIdentifier = @"QHVCGSLANDeviceListHeader";

@interface QHVCGSLANDeviceListViewController () <QHVCGSLANDeviceManagerDelegate,UITableViewDataSource,UITableViewDelegate>
/// 已认证的设备
@property (nonatomic,strong) NSArray *authedDevices;
/// 新发现的设备
@property (nonatomic,strong) NSArray *unAuthedDevices;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation QHVCGSLANDeviceListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupBackBarButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"局域网设备";
    [QHVCGSLANDeviceManager sharedManager].delegate = self;
    [[QHVCGSLANDeviceManager sharedManager] startDiscover];
    [self.tableView registerNib:[UINib nibWithNibName:@"QHVCGSLANDeviceListCell" bundle:nil] forCellReuseIdentifier:kQHVCGSLANDeviceListCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"QHVCGSLANDeviceListHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:kQHVCGSLANDeviceListHeaderReuseIdentifier];
}

- (void)showAuthAlertWithDeviceModel:(QHVCGSLANDeviceModel *)model
{
    QHVCGSLANDeviceAuthAlert *alert = [[[NSBundle mainBundle] loadNibNamed:@"QHVCGSLANDeviceAuthAlert" owner:self options:nil] firstObject];
    [alert setFrame:self.view.bounds];
    [self.view addSubview:alert];
    [alert setdID:@"1234567890"];
    alert.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        alert.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UI事件
- (void)onBack
{
    [super onBack];
    [[QHVCGSLANDeviceManager sharedManager] stopDiscover];
}

#pragma mark - QHVCGSLANDeviceManagerDelegate
- (void)lanDeviceManager:(QHVCGSLANDeviceManager *)manager
          didUpdateAuthedDevices:(NSArray *)authedDevices
                 unauthedDevices:(NSArray *)unauthedDevices
{
    self.authedDevices = authedDevices;
    self.unAuthedDevices = unauthedDevices;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCGSLANDeviceModel *model = nil;
    if (indexPath.section == 0)
    {
        model = self.authedDevices.count > 0 ? self.authedDevices[indexPath.row] : self.unAuthedDevices[indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        model = self.unAuthedDevices[indexPath.row];
    }
    QHVCGSLANDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:kQHVCGSLANDeviceListCellReuseIdentifier];
    [cell setupWithModel:model];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.authedDevices.count == 0)
    {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self isShowingAuthedDevice] ? self.authedDevices.count  : self.unAuthedDevices.count;
    }
    else if (section == 1)
    {
        return self.unAuthedDevices.count;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    BOOL isSelectAuthedDevice = [self isShowingAuthedDevice] && indexPath.section == 0;
//    if (isSelectAuthedDevice) {
//        [QHVCToast makeToast:@"功能未对接"];
//    }
//    else
//    {
//        QHVCGSLANDeviceModel *deviceModel = self.unAuthedDevices[indexPath.row];
//        [self showAuthAlertWithDeviceModel:deviceModel];
//    }
    QHVCGVDeviceModel *model = [[QHVCGVDeviceModel alloc] init];
    model.bindedSN = @"360H0700079";
    
    QHVCGVUserModel *userModel = [[QHVCGVUserModel alloc] init];
    userModel.token = @"abc";
    [QHVCGVUserSystem sharedInstance].userInfo = userModel;
    NSString *aa = [QHVCGVUserSystem sharedInstance].userInfo.token;
    QHVCGVWatchLivingViewController *wvc = [[QHVCGVWatchLivingViewController alloc] init];
    wvc.deviceModel = model;
    wvc.isLocal = YES;
    [self.navigationController pushViewController:wvc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    QHVCGSLANDeviceListHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kQHVCGSLANDeviceListHeaderReuseIdentifier];
    headerView.loadingView.hidden = NO;
    [headerView.loadingView startAnimating];
    if (section == 0)
    {
        headerView.labDeviceType.text = [self isShowingAuthedDevice] ? @"我的设备" : @"发现本地设备";
        headerView.loadingView.hidden = [self isShowingAuthedDevice] ? YES : NO;
    }
    else
    {
        headerView.labDeviceType.text = @"发现本地设备";
    }
    return headerView;
}

- (BOOL)isShowingAuthedDevice
{
    return self.authedDevices.count > 0;
}

@end
