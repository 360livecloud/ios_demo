//
//  QHVCLocalServerDownloadViewController.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/2.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerDownloadViewController.h"
#import "QHVCLocalServerDownloadingCell.h"
#import "QHVCLocalServerCachedCell.h"
#import "QHVCLocalServerDownloadManager.h"
#import "QHVCLocalServerLocalFileManager.h"

@interface QHVCLocalServerDownloadViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sectionTitleArray;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *cacheArray;

@end

@implementation QHVCLocalServerDownloadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = QHVC_COLOR_VIEW_WHITE;
    self.title = @"下载管理";
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    _dataSource = [[QHVCLocalServerDownloadManager sharedInstance] tasksArray];
    _cacheArray = [[QHVCLocalServerLocalFileManager sharedInstance] loadAllFiles];
    
    __weak typeof(self) weakSelf = self;
    [[QHVCLocalServerDownloadManager sharedInstance] reloadData:^(NSUInteger index) {
        [weakSelf reloadData:index];
    }];
    [[QHVCLocalServerDownloadManager sharedInstance] reloadTable:^(NSUInteger index) {
        weakSelf.cacheArray = [[QHVCLocalServerLocalFileManager sharedInstance] loadAllFiles];
        [weakSelf.tableView reloadData];
    }];
}

- (void)reloadData:(NSInteger)index
{
    if (index >= _dataSource.count)
        return;
    
    NSDictionary *dic = _dataSource[index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    QHVCLocalServerDownloadingCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    [cell setDownloading:YES];
    [cell setDetails:dic];
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitleArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (section == 0)
    {
        count = _dataSource.count;
    }
    else
    {
        count = _cacheArray.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        QHVCLocalServerDownloadingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"downloadingCell"];
        
        [cell setDetails:_dataSource[indexPath.row]];
        
        cell.pauseResumeAction = ^(BOOL selected) {
            if (selected)
            {
                [[QHVCLocalServerDownloadManager sharedInstance] resumeDownload:indexPath.row];
            }
            else
            {
                [[QHVCLocalServerDownloadManager sharedInstance] pauseDownload:indexPath.row];
            }
        };
        
        cell.deleteAction = ^{
            [[QHVCLocalServerDownloadManager sharedInstance] cancelDownload:indexPath.row deleteFile:NO];
        };
        
        return cell;
    }
    else
    {
        QHVCLocalServerCachedCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CachedCell"];
        
        [cell setDetails:_cacheArray[indexPath.row]];
        __weak typeof(self) weakSelf = self;
        cell.deleteFile = ^{
            {
                [[QHVCLocalServerLocalFileManager sharedInstance] deleteFile:indexPath.row];
                weakSelf.cacheArray = [[QHVCLocalServerLocalFileManager sharedInstance] loadAllFiles];
                [weakSelf.tableView reloadData];
            }
        };
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass: [QHVCLocalServerDownloadingCell class]
           forCellReuseIdentifier: @"downloadingCell"];
        [_tableView registerClass: [QHVCLocalServerCachedCell class]
           forCellReuseIdentifier: @"CachedCell"];
    }
    
    return _tableView;
}

- (NSArray *)sectionTitleArray
{
    if (!_sectionTitleArray)
    {
        _sectionTitleArray = @[
                               @"正在缓存",
                               @"已缓存"
                               ];
    }
    return _sectionTitleArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
