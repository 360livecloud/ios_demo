//
//  QHVCLIveListViewController.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/11.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLiveListViewController.h"
#import "QHVCInterfaceRequest.h"
#import "QHVCPlayerViewController.h"
#import <MJRefresh.h>

@interface QHVCLiveListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *bid;
    NSString *cid;
    BOOL isHardDecode;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *allSNList;

@end

@implementation QHVCLiveListViewController

- (instancetype)initWithLivePlayerConfig:(NSDictionary *)config
{
    if (self == [super init])
    {
        bid = [config valueForKey:@"bid"];
        cid = [config valueForKey:@"cid"];
        isHardDecode = [[config valueForKey:@"decode"] boolValue];
        _allSNList = [[config valueForKey:@"snList"] mutableCopy];
        [_allSNList removeObjectAtIndex:0];
        NSUInteger position = 20;
        if (_allSNList.count < 20)
        {
            position = _allSNList.count;
        }
        NSRange range = NSMakeRange(0, position);
        _dataSource = [[_allSNList subarrayWithRange:range] mutableCopy];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"花椒热播榜";
    [self initSubViews];
    // Do any additional setup after loading the view.
    
}

- (void)initSubViews
{
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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *item = _dataSource[indexPath.row];
    cell.textLabel.text = [item valueForKey:@"nick"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *config = @{
                             @"bid":bid,
                             @"cid":cid,
                             @"url":[NSString stringWithFormat:@"sn:%@", [_dataSource[indexPath.row] valueForKey:@"SN"]],
                             @"decode":@(isHardDecode),
                             @"sn":[_dataSource[indexPath.row] valueForKey:@"SN"]
                             };
    QHVCPlayerViewController *pvc = [[QHVCPlayerViewController alloc] initWithLivePlayerConfig:config hasAddress:NO];
    pvc.title = [_dataSource[indexPath.row] valueForKey:@"nick"];
    [self.navigationController pushViewController:pvc animated:YES];
}

- (UITableView *)tableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updateSNList];
    }];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf moreData];
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:236/255.0 alpha:1.0];
    [_tableView registerClass: [UITableViewCell class]
       forCellReuseIdentifier: @"cell"];
    
    return _tableView;
}

- (void)moreData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUInteger position = _dataSource.count + 20;
        if (position > _allSNList.count)
        {
            position = _allSNList.count;
            [_tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [_tableView.mj_footer endRefreshing];
        }
        [_dataSource removeAllObjects];
        _dataSource = [[_allSNList subarrayWithRange:NSMakeRange(0, position)] mutableCopy];
        [_tableView reloadData];
    });
}

- (void)updateSNList
{
    [QHVCInterfaceRequest snListRequestWithsuccess:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
        NSArray *snList = (NSArray *)object;
        if ([snList isKindOfClass:[NSArray class]])
        {
            [_allSNList removeAllObjects];
            [_allSNList addObjectsFromArray:snList];
            NSUInteger position = 20;
            if (_allSNList.count < 20)
            {
                position = _allSNList.count;
            }
            NSRange range = NSMakeRange(0, position);
            [_dataSource removeAllObjects];
            _dataSource = [[_allSNList subarrayWithRange:range] mutableCopy];
        }
        [_tableView reloadData];
        [_tableView.mj_header endRefreshing];
    } fail:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
        [_tableView.mj_header endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

@end
