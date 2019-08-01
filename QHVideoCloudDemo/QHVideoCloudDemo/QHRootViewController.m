//
//  QHRootViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2017/6/14.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHRootViewController.h"
#import <UIKit/UIKit.h>
#import "QHVCTabTableViewCell.h"
#import "QHVCGlobalConfig.h"
#import "QHVCLogger.h"

#import "QHVCPushStreamViewController.h"
#import "QHVCPlayerServiceViewController.h"
#import "QHVCInteractiveViewController.h"
#import "QHVCUploadingViewController.h"
//#import "QHVCEditViewController.h"
#import "QHVCEditVC.h"
#import "QHVCLocalServerViewController.h"
#import "QHVCP2PViewController.h"
#import "QHVCVP8TableViewController.h"
#import "QHVCScreenCashServiceViewController.h"
#import "QHVCGodViewController.h"
#import "QHVCRecordViewController.h"
#import "QHVCLinkMicViewController.h"
#import "QHVCGlobalConfig.h"

static NSString *const itemCellIdentifier = @"QHRootCollectionCell";

typedef NS_ENUM(NSInteger,QHVCRootVCCellRow) {
    QHVCRootVCCellRowPushStream,    // 推流
    QHVCRootVCCellRowPlay,          // 播放
    QHVCRootVCCellRowInteractive,   // 互动直播
    QHVCRootVCCellRowUpload,        // 上传
    QHVCRootVCCellRowVideoEdit,     // 剪辑
    QHVCRootVCCellRowLocalServer,   // 本地缓存
    QHVCRootVCCellRowP2P,           // P2P
    QHVCRootVCCellRowRecord,        //拍摄
#if !QHVC_PROJECT_FOR_APPSTORE
    QHVCRootVCCellRowVP8,           // VP8合成
    QHVCRootVCCellRowScreenCash,    // 投屏
    QHVCRootVCCellRowGodSees,       // 帝视
    QHVCRootVCCellRowLinkmic,       // 连麦（花椒）
#endif
};


@interface QHRootViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UIView *_headerView;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation QHRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"playerbg"]];
    [QHVCGlobalConfig setStatusBarColor:self.view.backgroundColor];
    [self initHeaderView];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (UILabel *)labelWithTitle:(NSString *)title fontName:(NSString *)fontName fontSize:(NSInteger)fontSize
{
    UILabel *label = [UILabel new];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:fontName size:fontSize];
    
    return label;
}

- (void)initTableView
{
    _tableView = [UITableView new];
    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(_headerView.mas_bottom);
    }];
}

- (UITableView *)tableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass: [QHVCTabTableViewCell class]
       forCellReuseIdentifier:itemCellIdentifier];
    
    return _tableView;
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
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCTabTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCellIdentifier];
    [cell updateCellDetail:_dataSource[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController;
    if (indexPath.row == QHVCRootVCCellRowPushStream)
    {
        viewController = [QHVCPushStreamViewController new];
    }
    else if (indexPath.row == QHVCRootVCCellRowPlay)
    {
        viewController = [[QHVCPlayerServiceViewController alloc] initWithNibName:@"QHVCPlayerServiceViewController" bundle:nil];
    }
    else if (indexPath.row == QHVCRootVCCellRowInteractive)
    {
        viewController = [QHVCInteractiveViewController new];
    }
    else if (indexPath.row == QHVCRootVCCellRowUpload)
    {
        viewController = [QHVCUploadingViewController new];
    }
    else if (indexPath.row == QHVCRootVCCellRowVideoEdit)
    {
        viewController = [[QHVCEditVC alloc]initWithNibName:@"QHVCEditVC" bundle:nil];
    }
    else if (indexPath.row == QHVCRootVCCellRowLocalServer)
    {
        viewController = [QHVCLocalServerViewController new];
    }
    else if (indexPath.row == QHVCRootVCCellRowP2P)
    {
        viewController = [QHVCP2PViewController new];
    }
    else if (indexPath.row == QHVCRootVCCellRowRecord)
    {
        viewController = [QHVCRecordViewController new];
    }
#if !QHVC_PROJECT_FOR_APPSTORE
    else if (indexPath.row == QHVCRootVCCellRowVP8)
    {
        viewController = [QHVCVP8TableViewController new];
        ((QHVCVP8TableViewController *)viewController).titleString = [_dataSource[indexPath.row] objectForKey:@"title"];
    }
    else if (indexPath.row == QHVCRootVCCellRowScreenCash)
    {
        viewController = [QHVCScreenCashServiceViewController new];
    }
    else if (indexPath.row == QHVCRootVCCellRowGodSees)
    {
        viewController = [QHVCGodViewController new];
    } else if (indexPath.row == QHVCRootVCCellRowLinkmic)
    {
        viewController = [QHVCLinkMicViewController new];
    }
    
#endif
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 2.0;
}

- (NSArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = @[
                        @{
                            @"leftImage":@"tab_pushStream",
                            @"title":@"推流",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_play",
                            @"title":@"播放",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_interactive",
                            @"title":@"互动直播",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_upload",
                            @"title":@"上传",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_videoEdit",
                            @"title":@"剪辑",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_localServer",
                            @"title":@"本地缓存",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_p2p",
                            @"title":@"P2P",
                            @"rightImage":@"jiantou"
                            },
                        @{ @"leftImage":@"tab_pushStream",
                           @"title":@"拍摄",
                           @"rightImage":@"jiantou"
                           },
#if !(QHVC_PROJECT_FOR_APPSTORE)
                        @{
                            @"leftImage":@"tab_p2p",
                            @"title":@"VP8合成",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_tv",
                            @"title":@"投屏",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_interactive",
                            @"title":@"帝视",
                            @"rightImage":@"jiantou"
                            },
                        @{
                            @"leftImage":@"tab_interactive",
                            @"title":@"连麦（花椒版本）",
                            @"rightImage":@"jiantou"
                            }
#endif
                        ];
    }
    
    return _dataSource;
}

- (void)initHeaderView
{
    _headerView = [UIView new];
    [self.view addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(@20);
        make.height.equalTo(@270);
    }];
    
    UIImageView *imgView = [UIImageView new];
    imgView.image = [UIImage imageNamed:@"logo"];
    [_headerView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headerView);
        make.top.equalTo(@53);
        make.height.equalTo(@75);
        make.width.equalTo(@100);
    }];
    
    UILabel *titleLabel = [self labelWithTitle:@"视频云SDK DEMO" fontName:kBoldFontName fontSize:25];
    [_headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headerView);
        make.top.equalTo(imgView.mas_bottom).offset(18);
        make.width.equalTo(@210);
        make.height.equalTo(@25);
    }];
    
    UILabel *descriptionOne = [self labelWithTitle:@"本demo以最简单的代码展示视频云sdk的" fontName:kDefaultFontName fontSize:14];
    [_headerView addSubview:descriptionOne];
    [descriptionOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headerView);
        make.top.equalTo(titleLabel.mas_bottom).offset(18);
        make.width.equalTo(@270);
        make.height.equalTo(@20);
    }];
    
    UILabel *descriptionTwo = [self labelWithTitle:@"使用方法，各功能之间相互独立，可单独使用。" fontName:kDefaultFontName fontSize:14];
    [_headerView addSubview:descriptionTwo];
    [descriptionTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headerView);
        make.top.equalTo(descriptionOne.mas_bottom);
        make.width.equalTo(@300);
        make.height.equalTo(@20);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
