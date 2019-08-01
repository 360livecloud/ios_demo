//
//  QHVCGeneralPlayingViewController.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/4.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCGeneralPlayingViewController.h"
#import "QHVCPlayingTableViewCellOne.h"
#import "QHVCPlayingTableViewCellTwo.h"
#import "QHVCPlayingTableViewCellThree.h"
#import "QHVCPlayerViewController.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

static NSString *KCellTypeOne = @"IdenitiferCellOne";
static NSString *KCellTypeTwo = @"IdenitiferCellTwo";
static NSString *KCellTypeThree = @"IdenitiferCellThree";

@interface QHVCGeneralPlayingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, copy) NSString *bid;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *decode;

@end

@implementation QHVCGeneralPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = QHVC_COLOR_VIEW_WHITE;
    self.title = @"点播播放器";
    _decode = @"1";
    _bid = @"demo_bid";
    _cid = @"demo";
//    _url = @"http://static.s3.huajiao.com/Object.access/hj-video/NTg1NzY5ODgxNDgxNjM2MzM5OTUxMjcwNjg1MDUzNy5tcDQ=";
    _url = @"http://vod.che.360.cn/vod-car-bj/112470524_2-1523501461-dfd4df59-831e-4634.mp4";
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-120);
    }];
    
    UIButton *playButton = [UIButton new];
    [playButton setImage:[UIImage imageNamed:@"PLAY"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10);
        make.width.height.equalTo(@100);
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
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = _dataSource[section];
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSArray *array = _dataSource[0];
        QHVCPlayingTableViewCellOne *cell = [tableView dequeueReusableCellWithIdentifier:KCellTypeOne];
        __weak typeof(self) weakSelf = self;
        cell.callback = ^(NSString *string){
            [weakSelf updateDataSource:string indexPathRow:indexPath.row];
        };
        [cell updateCellDetail:array[indexPath.row]];
        
        return cell;
    }
    else
    {
        if (indexPath.row == 0)
        {
            QHVCPlayingTableViewCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:KCellTypeTwo];
            
            return cell;
        }
        else
        {
            QHVCPlayingTableViewCellThree *cell = [tableView dequeueReusableCellWithIdentifier:KCellTypeThree];
            __weak typeof(self) weakSelf = self;
            cell.callback = ^(NSString *string){
                weakSelf.decode = string;
            };
            
            return cell;
        }
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

- (void)updateDataSource:(NSString *)string indexPathRow:(NSInteger)row
{
    switch (row)
    {
        case 0:
            _bid = string;
            break;
        case 1:
            _cid = string;
            break;
        case 2:
            _url = string;
            break;
            
        default:
            break;
    }
    _dataSource = @[
                    @[
                        @{
                            @"image":@"Bid",
                            @"title":@"Bid 业务标识",
                            @"value":_bid
                            },
                        @{
                            @"image":@"Cid",
                            @"title":@"Cid 渠道标识",
                            @"value":_cid
                            },
                        @{
                            @"image":@"URL",
                            @"title":@"URL 播放地址",
                            @"value":_url
                            }
                        ],
                    @[
                        @"解码方式",
                        @[
                            @"硬解码",
                            @"软解码"
                            ]
                        ]
                    ];
}

- (NSArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = @[
                        @[
                            @{
                                @"image":@"Bid",
                                @"title":@"Bid 业务标识",
                                @"value":_bid
                                },
                            @{
                                @"image":@"Cid",
                                @"title":@"Cid 渠道标识",
                                @"value":_cid
                                },
                            @{
                                @"image":@"URL",
                                @"title":@"URL 播放地址",
                                @"value":_url
                                }
                            ],
                        @[
                            @"解码方式",
                            @[
                                @"硬解码",
                                @"软解码"
                                ]
                            ]
                        ];
    }
    
    return _dataSource;
}

- (UITableView *)tableView
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
    [_tableView registerClass: [QHVCPlayingTableViewCellOne class]
       forCellReuseIdentifier: KCellTypeOne];
    [_tableView registerClass: [QHVCPlayingTableViewCellTwo class]
       forCellReuseIdentifier: KCellTypeTwo];
    [_tableView registerClass: [QHVCPlayingTableViewCellThree class]
       forCellReuseIdentifier: KCellTypeThree];
    
    return _tableView;
}

- (void)playAction:(UIButton *)button
{
    if (![_bid isEqualToString:@"demo_bid"])
    {
        [self notifyAppStart];
    }
    NSDictionary *config = @{
                          @"bid":_bid,
                          @"cid":_cid,
                          @"url":_url,
                          @"decode":_decode
                          };
    QHVCPlayerViewController *pvc = [[QHVCPlayerViewController alloc] initWithPlayerConfig:config];
    pvc.title = @"如果寂寞了";
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)notifyAppStart
{
    NSString *bid = _bid;
    [QHVCCommonCoreEntry coreOnAppStart:bid
                                 appVer:@"3.0.0"
                               deviceId:@"deviceUDID-kdkkdkdkdkd333"
                                  model:@"iPhone x"
                         optionalParams:nil];
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
