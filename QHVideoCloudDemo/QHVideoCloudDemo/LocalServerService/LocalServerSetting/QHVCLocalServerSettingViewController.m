//
//  QHVCLocalServerSettingViewController.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/26.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerSettingViewController.h"
#import "QHVCLocalServerSettingCell.h"
#import <QHVCLocalServerKit/QHVCLocalServerKit.h>
#import "QHVCLocalServerDownloadViewController.h"

@interface QHVCLocalServerSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation QHVCLocalServerSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = QHVC_COLOR_VIEW_WHITE;
    self.title = @"设置";
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCLocalServerSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    cell.textLabel.text = _dataSource[indexPath.row];
    [cell setSwitchHidden:NO];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    QHVCLocalServerKit *localServer = [QHVCLocalServerKit sharedInstance];
    if (indexPath.row == 0)
    {
        BOOL selected = [[QHVCLocalServerKit sharedInstance] isStartLocalServer];
        [cell setSwitchSelected:selected];
        cell.switchAction = ^(BOOL on){
            if (on)
            {
                [localServer setCacheSize:500];
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                path = [path stringByAppendingPathComponent:@"videoCache"];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if (![fileManager fileExistsAtPath:path])
                {
                    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                }
                [localServer startServer:path deviceId:[weakSelf getUUIDString] appId:@"Demo" cacheSize:200];
            }
            else
            {
                [localServer stopServer];
            }
            [defaults setBool:on forKey:@"localServerKey"];
            [defaults synchronize];
            [tableView reloadData];
        };
    }
    else if (indexPath.row == 1)
    {
        BOOL selected = [[QHVCLocalServerKit sharedInstance] isEnableCache];
        [cell setSwitchSelected:selected];
        cell.switchAction = ^(BOOL on){
            [localServer enableCache:on];
            [defaults setBool:on forKey:@"enableCache"];
            [defaults synchronize];
            [tableView reloadData];
        };
    }
    else if (indexPath.row == 2)
    {
        BOOL selected = [[QHVCLocalServerKit sharedInstance] isEnablePrecacheForMobileNetwork];
        [cell setSwitchSelected:selected];
        cell.switchAction = ^(BOOL on){
            [localServer enablePrecacheForMobileNetwork:on];
            [defaults setBool:on forKey:@"mobilePreloadKey"];
            [defaults synchronize];
            [tableView reloadData];
        };
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        [cell setSwitchHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 3)
    {
        [self cacheManagerAction];
    }
    else if (indexPath.row == 4)
    {
        [self deleteAction];
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [UIView new];
        if (@available(iOS 11.0, *))
        {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        else
        {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass: [QHVCLocalServerSettingCell class]
           forCellReuseIdentifier: @"settingCell"];
    }
    
    return _tableView;
}

- (NSArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = @[
                        @"localServer",
                        @"暂停时继续缓存",
                        @"非WIFI网络预缓存",
                        @"下载管理",
                        @"清理缓存"
                        ];
    }
    
    return _dataSource;
}

- (NSString *)getUUIDString
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault , uuidRef);
    NSString *uuidString = [(__bridge NSString*)strRef stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(strRef);
    CFRelease(uuidRef);
    
    return uuidString;
}

- (void)deleteAction
{
    UIAlertController *alertOne = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认清除视频缓存吗?" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertOne animated:YES completion:nil];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertOne addAction:cancel];
    
    UIAlertAction *certain = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[QHVCLocalServerKit sharedInstance] clearCache];
    }];
    [alertOne addAction:certain];
}

- (void)cacheManagerAction
{
    QHVCLocalServerDownloadViewController *sdvc = [[QHVCLocalServerDownloadViewController alloc] init];
    [self.navigationController pushViewController:sdvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

@end
