//
//  QHVCLivePlayingViewController.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/4.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLivePlayingViewController.h"
#import "QHVCSegmentView.h"
#import "QHVCPlayingTableViewCellOne.h"
#import "QHVCPlayingTableViewCellTwo.h"
#import "QHVCPlayingTableViewCellThree.h"
#import "QHVCPlayerViewController.h"
#import "QHVCLiveListViewController.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCInterfaceRequest.h"
#import <MJRefresh.h>

static NSString *KCellTypeOne = @"IdenitiferCellOne";
static NSString *KCellTypeTwo = @"IdenitiferCellTwo";
static NSString *KCellTypeThree = @"IdenitiferCellThree";
static NSString *KCellTypeFour= @"IdenitiferCellFour";

@interface QHVCLivePlayingViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL hasAddress;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSMutableArray *liveList;
@property (nonatomic, copy) NSString *bid;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *decode;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *nick;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

@end

@implementation QHVCLivePlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = QHVC_COLOR_VIEW_WHITE;
    _decode = @"1";
    _bid = @"demo";
    _cid = @"demo_cid";
    _url = @"http://static.s3.huajiao.com/Object.access/hj-video/NTg1NzY5ODgxNDgxNjM2MzM5OTUxMjcwNjg1MDUzNy5tcDQ=";
    _sn = @"";
    _nick = @"";
    _liveList = [[NSMutableArray alloc] initWithObjects:@"直播列表", nil];
    
    [self initItemView];
    
    [self.view addSubview:self.tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@60);
        make.left.right.equalTo(self.view);
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
    [_tableView.mj_header beginRefreshing];
}

- (void)updateSNList
{
    [QHVCInterfaceRequest snListRequestWithsuccess:^(NSDictionary * _Nullable object, NSError * _Nullable error) {
        NSArray *snList = (NSArray *)object;
        if ([snList isKindOfClass:[NSArray class]])
        {
            [_liveList removeAllObjects];
            [_liveList addObject:@"直播列表"];
            [_liveList addObjectsFromArray:snList];
            _sn = [[snList firstObject] valueForKey:@"SN"];
            _nick = [[snList firstObject] valueForKey:@"nick"];
        }
        [_tableView reloadData];
        [_tableView.mj_header endRefreshing];
        NSLog(@"sn:%@", _sn);
    } fail:^(NSError * _Nullable error) {
        NSLog(@"%@", error);
        [_tableView.mj_header endRefreshing];
    }];
}

- (void)initItemView
{
    UIView *itemView = [UIView new];
    itemView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"playerbg"]];
    [self.view addSubview:itemView];
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@60);
    }];
    
    UIButton *backBtn = [UIButton new];
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [itemView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@30);
        make.left.equalTo(itemView);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    QHVCSegmentView *segment = [[QHVCSegmentView alloc] initWithSectionTitles:@[@"无地址", @"有地址"]];
    [segment setFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 130) * 0.5, 20, 130, 40)];
    [segment addTarget:self action:@selector(tab:) forControlEvents:UIControlEventValueChanged];
    [segment setTextColor:[UIColor colorWithWhite:1 alpha:0.5]];
    [segment setSelectedTextColor:[UIColor colorWithWhite:1 alpha:1.0]];
    segment.height = 40;
    [segment setSelectionIndicatorColor:[UIColor redColor]];
    [segment setSelectionIndicatorHeight:3.0f];
    [segment setSelectionIndicatorMode:DDDSelectionIndicatorNone];
    
    segment.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"playerbg"]];
    [itemView addSubview:segment];
}

- (void)backBtnAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tab:(QHVCSegmentView *)segment
{
    hasAddress = segment.selectedIndex;
    _dataSource = nil;
    [_tableView reloadData];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        if (hasAddress)
        {
            return 2;
        }
        if (_liveList.count < 3)
        {
            return _liveList.count;
        }
        return 4;
    }
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
    else if (indexPath.section == 1 && !hasAddress)
    {
        if (indexPath.row == 0)
        {
            QHVCPlayingTableViewCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:KCellTypeTwo];
            [cell setRigthButtonHidden:NO withTarget:self action:@selector(expansionButtonAction:)];
            [cell setTitle:_liveList[0]];
            
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KCellTypeFour];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            NSDictionary *dic = _liveList[indexPath.row];
            cell.textLabel.text = [dic valueForKey:@"SN"];
            
            return cell;
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            QHVCPlayingTableViewCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:KCellTypeTwo];
            [cell setRigthButtonHidden:YES];
            [cell setTitle:@"解码方式"];
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && !hasAddress)
    {
        NSDictionary *dic = _liveList[indexPath.row];
        if ([dic isKindOfClass:[NSDictionary class]])
        {
            _sn = [dic valueForKey:@"SN"];
            _nick = [dic valueForKey:@"nick"];
            [tableView reloadData];
        }
    }
}

- (void)updateDataSource:(NSString *)string indexPathRow:(NSInteger)row
{
    if (hasAddress)
    {
        _url = string;
        _dataSource = @[
                        @[
                            @{
                                @"image":@"URL",
                                @"title":@"Url",
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
    else
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
            _sn = string;
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
                                @"value":_sn
                                }
                            ],
                        _liveList,
                        @[
                            @"解码方式",
                            @[
                                @"硬解码",
                                @"软解码"
                                ]
                            ]
                        ];
    }
}

- (NSArray *)dataSource
{
    if (hasAddress)
    {
        if (!_dataSource)
        {
            _dataSource = @[
                            @[
                                @{
                                    @"image":@"URL",
                                    @"title":@"Url",
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
    }
    else
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
                                @"image":@"sn",
                                @"title":@"sn 直播流标识",
                                @"value":_sn
                                }
                            ],
                        _liveList,
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
    if (@available(iOS 11.0, *))
    {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.tableFooterView = [UIView new];
    __weak typeof(self) weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updateSNList];
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView registerClass: [QHVCPlayingTableViewCellOne class]
       forCellReuseIdentifier: KCellTypeOne];
    [_tableView registerClass: [QHVCPlayingTableViewCellTwo class]
       forCellReuseIdentifier: KCellTypeTwo];
    [_tableView registerClass: [QHVCPlayingTableViewCellThree class]
       forCellReuseIdentifier: KCellTypeThree];
    [_tableView registerClass: [UITableViewCell class]
       forCellReuseIdentifier: KCellTypeFour];
    
    return _tableView;
}

- (void)playAction:(UIButton *)button
{
    if ((hasAddress && [_url isEqualToString:@""]) || (!hasAddress && [_sn isEqualToString:@""]))
        return;
    
    if (![_bid isEqualToString:@"huajiao"])
    {
        [self notifyAppStart];
    }
    NSDictionary *config = @{
                             @"bid":_bid,
                             @"cid":_cid,
                             @"url":hasAddress ? _url : [NSString stringWithFormat:@"sn:%@", _sn],
                             @"decode":_decode,
                             @"sn":_sn
                             };
    QHVCPlayerViewController *pvc = [[QHVCPlayerViewController alloc] initWithLivePlayerConfig:config hasAddress:hasAddress];
    if (!hasAddress)
    {
        pvc.title = _nick;
    }
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)expansionButtonAction:(UIButton *)button
{
    NSDictionary *config = @{
                             @"bid":_bid,
                             @"cid":_cid,
                             @"url":_url,
                             @"decode":_decode,
                             @"snList":_liveList
                             };
    if (_liveList.count <= 1)
        return;
    QHVCLiveListViewController *lvc = [[QHVCLiveListViewController alloc] initWithLivePlayerConfig:config];
    [self.navigationController pushViewController:lvc animated:YES];
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
