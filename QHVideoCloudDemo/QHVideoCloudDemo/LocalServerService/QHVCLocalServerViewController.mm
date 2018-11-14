 //
//  QHVCLocalServerViewController.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/18.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLocalServerViewController.h"
#import "QHVCLocalServerPlayerCell.h"
#import "QHVCLocalServerPlayerView.h"
#import "QHVCHUDManager.h"
#import "AppDelegate.h"
#import <QHVCPlayerKit/QHVCPlayerKit.h>
#import <QHVCLocalServerKit/QHVCLocalServerKit.h>
#import "QHVCLocalServerSettingViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "QHVCLocalServerDownloadManager.h"

@interface QHVCLocalServerViewController ()<UITableViewDelegate, UITableViewDataSource, QHVCLocalServerPlayerViewDelegate, QHVCPlayerDelegate, QHVCPlayerAdvanceDelegate>
{
    BOOL isFullScreen;
    NSInteger currentPlayIndex;
    UIButton *settingButton;
   
    QHVCPlayer *_player;
    UIView *_playerView;
    BOOL isChangingItem;
    NSString *defaultPath;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) QHVCLocalServerPlayerView *currrentPlayerView;
@property (nonatomic, strong) NSMutableArray *preloadArray;
@property (nonatomic, strong) QHVCHUDManager *hudManager;
@property (nonatomic, assign) BOOL hasNet;

@end

@implementation QHVCLocalServerViewController

- (void)createPlayer:(NSDictionary *)item
{
    NSString *rid = [item valueForKey:@"rid"];
    NSString *url = [item valueForKey:@"playUrl"];
    NSLog(@"palyingRid:%@", rid);
    NSLog(@"playingUrl:%@", url);
    NSString *urlString;
    if ([[QHVCLocalServerKit sharedInstance] isStartLocalServer])
    {
        [[QHVCLocalServerKit sharedInstance] enableCache:YES];
        urlString = [[QHVCLocalServerKit sharedInstance] getPlayUrl:rid url:url];
        NSLog(@"playingUrl-localServer:%@", urlString);
    }
    else
    {
        urlString = url;
    }
    _player = [[QHVCPlayer alloc] initWithURL:urlString channelId:@"demo" userId:nil playType:QHVCPlayTypeVod];
    _player.playerDelegate = self;
    _player.playerAdvanceDelegate = self;
    _currrentPlayerView.player = _player;
    _playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.width * SCREEN_SCALE)];
    [_player createPlayerView:_playerView];
    [_currrentPlayerView insertSubview:_playerView atIndex:0];
    _currrentPlayerView.lspGLView = _playerView;
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_currrentPlayerView);
    }];
    [_player prepare];
    [QHVCPlayer setLogLevel:QHVCPlayerLogLevelInfo];//注意要在player初始化之后设置
}

- (void)stopPlayer
{
    [_player closeNetStats];
    [_player stop];
    _player = nil;
    currentPlayIndex = -1;
    [_currrentPlayerView unCurrentStyle];
    [_currrentPlayerView stop];
    _playerView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = QHVC_COLOR_VIEW_WHITE;
    currentPlayIndex = -1;
    [self layoutSubViews];
    // Do any additional setup after loading the view.
    [self startNotify];
    [self startSetting];
    _hudManager = [QHVCHUDManager new];
    defaultPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"downloadVideo"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:defaultPath])
    {
        [fileManager createDirectoryAtPath:defaultPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [[QHVCLocalServerKit sharedInstance] setLogLevel:QHVC_LOCALSERVER_LOG_LEVEL_DEBUG detailInfo:0 callback:^(const char *buf, size_t buf_size) {
        NSLog(@"-----:%@", [NSString stringWithUTF8String:buf]);
    }];
    __weak typeof(self) weakSelf = self;
    [[QHVCLocalServerDownloadManager sharedInstance] msgCallBack:^(NSString *msg) {
        [weakSelf.hudManager showTextOnlyAlertViewOnView:weakSelf.view message:msg hideFlag:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.title = @"视频列表";
    settingButton.hidden = NO;
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPlayer];
    settingButton.hidden = YES;
}

- (void)startNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignAction:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    __weak typeof(self) weakSelf = self;
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络");
                weakSelf.hasNet = NO;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                [weakSelf.currrentPlayerView showNoNetwork];
                weakSelf.hasNet = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"移动网络");
                weakSelf.hasNet = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                weakSelf.hasNet = YES;
                break;
        }
    }];
    [manager startMonitoring];
}

- (void)startSetting
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"localServerKey"] == nil)
    {
        [[QHVCLocalServerKit sharedInstance] setCacheSize:500];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:@"videoCache"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path])
        {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [[QHVCLocalServerKit sharedInstance] startServer:path deviceId:[self getUUIDString] appId:@"Demo" cacheSize:200];
        
        [defaults setBool:YES forKey:@"localServerKey"];
        [defaults synchronize];
    }
    else if ([defaults boolForKey:@"localServerKey"] == YES)
    {
        [[QHVCLocalServerKit sharedInstance] setCacheSize:500];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:@"videoCache"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path])
        {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [[QHVCLocalServerKit sharedInstance] startServer:path deviceId:[self getUUIDString] appId:@"Demo" cacheSize:200];
    }
    
    if ([defaults valueForKey:@"enableCache"] != nil )
    {
        BOOL enable = [defaults boolForKey:@"enableCache"];
        [[QHVCLocalServerKit sharedInstance] enableCache:enable];
    }
    else
    {
        [[QHVCLocalServerKit sharedInstance] enableCache:YES];
        [defaults setBool:YES forKey:@"enableCache"];
        [defaults synchronize];
    }
    
    if ([defaults valueForKey:@"mobilePreloadKey"] != nil )
    {
        BOOL enable = [defaults boolForKey:@"mobilePreloadKey"];
        [[QHVCLocalServerKit sharedInstance] enablePrecacheForMobileNetwork:enable];
    }
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

#pragma mark PlayerViewDelegate
- (void)back
{
    isFullScreen = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentPlayIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];

    _tableView.scrollEnabled = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)fullScreen
{
    isFullScreen = YES;
    [self.navigationController setNavigationBarHidden:YES];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentPlayIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];

    _tableView.scrollEnabled = NO;
}

- (void)playPause:(QHVCLocalServerPlayerView *)view
{
    if (!_player)
    {
        currentPlayIndex = view.index;
        _currrentPlayerView = view;
        [self createPlayer:_dataSource[currentPlayIndex]];
        return;
    }
    
    if (currentPlayIndex == view.index)
    {
        if ([_player playerStatus] == QHVCPlayerStatusPaused)
        {
            if ([[QHVCLocalServerKit sharedInstance] isStartLocalServer])
            {
                [[QHVCLocalServerKit sharedInstance] enableCache:YES];
            }
            [_player play];
        }
        else
        {
            if ([[QHVCLocalServerKit sharedInstance] isStartLocalServer] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"enableCache"])
            {
                [[QHVCLocalServerKit sharedInstance] enableCache:NO];
            }
            [_player pause];
        }
    }
    else
    {
        [self stopPlayer];
        currentPlayIndex = view.index;
        _currrentPlayerView = view;
        [self createPlayer:_dataSource[currentPlayIndex]];
    }
}

- (void)next
{
    if (currentPlayIndex == _dataSource.count - 1)
    {
        [_hudManager showTextOnlyAlertViewOnView:self.view message:@"已经是最后一个" hideFlag:YES];
        return;
    }
    [self changeItem:@(1)];
}

- (void)previous
{
    if (currentPlayIndex == 0)
    {
        [_hudManager showTextOnlyAlertViewOnView:self.view message:@"已经是第一个" hideFlag:YES];
        return;
    }
    [self changeItem:@(-1)];
}

- (void)download:(NSInteger)index
{
    if (!_hasNet)
    {
        [_hudManager showTextOnlyAlertViewOnView:self.view message:@"无网状态下无法下载" hideFlag:YES];
        return;
    }
    NSDictionary *item = _dataSource[index];
    NSString *title = [item valueForKey:@"title"];
    NSString *rid = [item valueForKey:@"rid"];
    NSString *url = [item valueForKey:@"playUrl"];
    NSString *path = [defaultPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", title]];
    [[QHVCLocalServerDownloadManager sharedInstance] startDownload:rid url:url path:path title:title];
}

- (void)changeItem:(NSNumber *)accumulate
{
    if (isChangingItem)
        return;
    
    isChangingItem = YES;
    NSInteger temp = currentPlayIndex + [accumulate integerValue];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:temp inSection:0] animated:YES scrollPosition:UITableViewScrollPositionBottom];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        isChangingItem = NO;
        QHVCLocalServerPlayerCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:temp inSection:0]];
        [cell.playerView play];
    });
}

- (void)settingAction:(UIButton *)button
{
    QHVCLocalServerSettingViewController * svc = [[QHVCLocalServerSettingViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)startPreload
{
    [_preloadArray removeAllObjects];
    _preloadArray = [[_tableView indexPathsForVisibleRows] mutableCopy];
    if (_preloadArray && _preloadArray.count > 0)
    {
        for (int i = 0; i < _preloadArray.count; i ++)
        {
            NSIndexPath *indexPath = _preloadArray[i];
            NSLog(@"isStartLocalServer = %i", [[QHVCLocalServerKit sharedInstance] isStartLocalServer]);
            NSLog(@"isEnableCache = %i", [[QHVCLocalServerKit sharedInstance] isEnableCache]);
            [[QHVCLocalServerKit sharedInstance] preloadCacheFile:[_dataSource[indexPath.row] valueForKey:@"rid"] url:[_dataSource[indexPath.row] valueForKey:@"playUrl"] preCacheSize:800];
            NSLog(@"preload:%@----url:%@", [_dataSource[indexPath.row] valueForKey:@"rid"], [_dataSource[indexPath.row] valueForKey:@"playUrl"]);
        }
    }
}

- (void)cancelPreload
{
    if (_preloadArray && _preloadArray.count > 0)
    {
        for (int i = 0; i < _preloadArray.count; i ++)
        {
            NSIndexPath *indexPath = _preloadArray[i];
            [[QHVCLocalServerKit sharedInstance] cancelPreCache:[_dataSource[indexPath.row] valueForKey:@"rid"]];
            NSLog(@"canclereload:%@", [_dataSource[indexPath.row] valueForKey:@"rid"]);
        }
    }
}

#pragma mark Layout
- (void)layoutSubViews
{
    settingButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width - 60, -5, 60, 55)];
    [settingButton setImage:[UIImage imageNamed:@"localServerSet"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:settingButton];

    [self.view addSubview:self.tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cancelPreload];
    [self startPreload];
}

#pragma mark PlayerDelegate
//@required
/**
 播放器准备成功回调,在此回调中调用play开始播放
 */
- (void)onPlayerPrepared:(QHVCPlayer *)player
{
    [_player play];
    [_player openNetStats:5];
}

/**
 播放器渲染第一帧
 */
- (void)onPlayerFirstFrameRender:(NSDictionary *)mediaInfo player:(QHVCPlayer *)player
{
    [_tableView reloadData];
}

/**
 播放结束回调
 */
- (void)onPlayerFinish:(QHVCPlayer *)player
{
    [_currrentPlayerView finish];
}

//@optional

/**
 * 视频大小变化通知
 *
 * @param width  视频宽度
 * @param height 视频高度
 */
- (void)onPlayerSizeChanged:(int)width height:(int)height player:(QHVCPlayer *)player
{
    
}

/**
 开始缓冲(buffer为空，触发loading)
 */
- (void)onPlayerBufferingBegin:(QHVCPlayer *)player
{
    [_currrentPlayerView beginBuffing];
}

/**
 * 缓冲进度(buffer loading进度)
 *
 * @param progress 缓冲进度，progress==0表示开始缓冲， progress==100表示缓冲结束
 */
- (void)onPlayerBufferingUpdate :(int)progress player:(QHVCPlayer *)player
{
    [_currrentPlayerView bufferingUpdate:progress];
}

/**
 缓冲完成(buffer loading完成，可以继续播放)
 */
- (void)onPlayerBufferingComplete:(QHVCPlayer *)player
{
    [_currrentPlayerView bufferingComplete];
}

/**
 * 拖动操作缓冲完成
 */
- (void)onPlayerSeekComplete:(QHVCPlayer *)player
{
    [_currrentPlayerView buffingSeekComplete];
}

/**
 播放进度回调
 */
- (void)onPlayerPlayingProgress:(CGFloat)progress player:(QHVCPlayer *)player
{
    [_currrentPlayerView updateplayProgress:progress];
}

- (void)onplayerPlayingUpdatingMediaInfo:(NSDictionary *)mediaInfo player:(QHVCPlayer *)player
{
    
}

/**
 * 播放器错误回调
 *
 * @param error       错误类型
 * @param extraInfo   额外的信息
 */
- (void)onPlayerError:(QHVCPlayerError) error extra:(QHVCPlayerErrorDetailedInfo)extraInfo player:(QHVCPlayer *)player
{
    NSLog(@"error:%ld", (long)extraInfo);//播放器初始化I/O错误要重新初始化player
}

/**
 * 播放状态回调
 *
 * @param info  参见状态信息枚举
 * @param extraInfo 扩展信息
 */
- (void)onPlayerInfo:(QHVCPlayerStatus)info extra:(NSString *)extraInfo player:(QHVCPlayer *)player
{
    [_currrentPlayerView setPlayStatus:extraInfo];
}

- (void)onPlayerSwitchResolutionSuccess:(int)index player:(QHVCPlayer *)player
{
    
}

- (void)onPlayerSwitchResolutionFailed:(NSString *)errorMsg player:(QHVCPlayer *)player
{
    [_hudManager showTextOnlyAlertViewOnView:_playerView message:[NSString stringWithFormat:@"切换分辨率失败:%@", errorMsg] hideFlag:YES];
}

#pragma mark TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isFullScreen)
    {
        return SCREEN_SIZE.height;
    }
    return SCREEN_SIZE.width * SCREEN_SCALE;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCLocalServerPlayerCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.playerView.index = indexPath.row;
    cell.playerView.delegate = self;
    cell.playerView.isFullScreen = isFullScreen;
    cell.playerView.player = nil;
    [cell.playerView setItemDetail:_dataSource[indexPath.row]];

    if (currentPlayIndex == indexPath.row)
    {
        cell.playerView.player = _player;
        [cell.playerView currentStyle];
        [cell.playerView insertSubview:_playerView atIndex:0];
        cell.playerView.lspGLView = _playerView;
        [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.playerView);
        }];
        _currrentPlayerView = cell.playerView;
    }
    else
    {
        if (currentPlayIndex >= 0 && abs((int)currentPlayIndex - (int)indexPath.row) > 3)
        {
            [self stopPlayer];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(200 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        [cell.playerView unCurrentStyle];
    }
    
    return cell;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass: [QHVCLocalServerPlayerCell class]
           forCellReuseIdentifier: @"cell"];
    }
    
    return _tableView;
}

- (void)willResignAction:(NSNotification *)notification
{
    
}

- (void)becomeActive:(NSNotification *)notification
{
    [_tableView reloadData];
    if (currentPlayIndex >= 0 && isFullScreen)
    {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentPlayIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (NSArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = @[@{
                            @"title":@"小视频(0)",
                            @"rid":@"QHVC_Demo_video0",
                            @"playUrl":@"http://q3.v.k.360kan.com/vod-xinxiliu-tv-q3-bj/15726_632071bae2f98-5190-4a82-be2a-23772d9583b0.mp4",
                            @"imageUrl":@"http://p2.qhimg.com/d/inn/59127791/img_0.png",
                            @"playCount":@"1.7万",
                            @"totalTime":@"03:17"
                            },
                        @{
                            @"title":@"小视频(1)",
                            @"rid":@"QHVC_Demo_video1",
                            @"playUrl":@"http://video.mp.sj.360.cn/vod_zhushou/vod-shouzhu-bj/93f5f7529bf85bb0ed7b156f7a24eaed.mp4",
                            @"imageUrl":@"http://p2.qhimg.com/d/inn/59127791/img_1.png",
                            @"playCount":@"1.2万",
                            @"totalTime":@"56:02"
                            },
                        @{
                            @"title":@"小视频(2)",
                            @"rid":@"QHVC_Demo_video2",
                            @"playUrl":@"http://video.mp.sj.360.cn/vod_zhushou/vod-shouzhu-bj/1f212d18f71c15a07414de5ae49acb22.mp4",
                            @"imageUrl":@"http://p6.qhimg.com/d/inn/59127791/img_2.png",
                            @"playCount":@"1.2万",
                            @"totalTime":@"04:25"
                            },
                        @{
                            @"title":@"小视频(3)",
                            @"rid":@"QHVC_Demo_video3",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNy8zNzY3MmYzYjhjMzYyNGVmZTdlYzdiZDMxMTQ0ZDkzMS5tcDQ%3D",
                            @"imageUrl":@"http://p0.qhimg.com/d/inn/59127791/img_3.png",
                            @"playCount":@"1.8万",
                            @"totalTime":@"00:13"
                            },
                        @{
                            @"title":@"小视频(4)",
                            @"rid":@"QHVC_Demo_video4",
                            @"playUrl":@"http://video.mp.sj.360.cn/vod_zhushou/vod-shouzhu-bj/b9d245e8e09cc0dd56f9b60152d09793.mp4",
                            @"imageUrl":@"http://p0.qhimg.com/d/inn/59127791/img_4.png",
                            @"playCount":@"1.6万",
                            @"totalTime":@"00:17"
                            },
                        @{
                            @"title":@"小视频(5)",                            @"rid":@"QHVC_Demo_video5",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNy9jYjc2NGE0Y2ViMjc2YjM0ZDc4YTFiY2ExYmY1ZWMxMy5tcDQ%3D",
                            @"imageUrl":@"http://p1.qhimg.com/d/inn/17bc0a81/img_5.png",
                            @"playCount":@"2.6万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(6)",                            @"rid":@"QHVC_Demo_video6",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNy8zZmViYWU4NzkzYzAzYzQyZjEzNjg2OTBhZjhiNmE2OC5tcDQ%3D",
                            @"imageUrl":@"http://p7.qhimg.com/d/inn/17bc0a81/img_6.png",
                            @"playCount":@"2.3万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(7)",                            @"rid":@"QHVC_Demo_video7",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9lMzEwMDNjOTUxZjJhOWNlNDNkNmUzZjg5MjVkNDcyZS5tcDQ%3D",
                            @"imageUrl":@"http://p1.qhimg.com/d/inn/17bc0a81/img_7.png",
                            @"playCount":@"2.3万",
                            @"totalTime":@"00:09"
                            },
                        @{
                            @"title":@"小视频(8)",                            @"rid":@"QHVC_Demo_video8",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNy84NTRkOGVmN2RjM2FlMGMzMTA0YTZhZmMwODAzZTZjMi5tcDQ%3D",
                            @"imageUrl":@"http://p2.qhimg.com/d/inn/17bc0a81/img_8.png",
                            @"playCount":@"2.8万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(9)",                            @"rid":@"QHVC_Demo_video9",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi8yZjI3MWMzNDAxNWE1MThiNDdkNzBiN2U0MmY4ZWNkNC5tcDQ%3D",
                            @"imageUrl":@"http://p2.qhimg.com/d/inn/17bc0a81/img_9.png",
                            @"playCount":@"2.7万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(10)",
                            @"rid":@"QHVC_Demo_video10",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9kODAyMmVmZTNlNGVhMjFlMjE2NDZhMWVlMjNiMmIwZi5tcDQ%3D",
                            @"imageUrl":@"http://p0.qhimg.com/d/inn/17bc0a81/img_10.png",
                            @"playCount":@"3.7万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(11)",
                            @"rid":@"QHVC_Demo_video11",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi84YjAwYmZjZDA4YTFhN2VkN2VmZmRiYWQ5M2YyMWY3YS5tcDQ%3D",
                            @"imageUrl":@"http://p5.qhimg.com/d/inn/cea3d896/img_11.png",
                            @"playCount":@"3.9万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(12)",
                            @"rid":@"QHVC_Demo_video12",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi83OWM5ZTk4ZGUxZjM2OTMwZGJmMDgxZDNjNDk5ODNkYS5tcDQ%3D",
                            @"imageUrl":@"http://p1.qhimg.com/d/inn/cea3d896/img_12.png",
                            @"playCount":@"5.6万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(13)",
                            @"rid":@"QHVC_Demo_video13",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9iMWFhMzNiYmZiNDYyNDJlN2QyZjMyZGFkMTE0ZjViYi5tcDQ%3D",
                            @"imageUrl":@"http://p3.qhimg.com/d/inn/cea3d896/img_13.png",
                            @"playCount":@"5.9万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(14)",
                            @"rid":@"QHVC_Demo_video14",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9iMDIyNzhkM2M0ZGU1NzBmNjZjZGYxMDViZGNlYmFmMC5tcDQ%3D",
                            @"imageUrl":@"http://p1.qhimg.com/d/inn/cea3d896/img_14.png",
                            @"playCount":@"5.9万",
                            @"totalTime":@"00:08"
                            },
                        @{
                            @"title":@"小视频(15)",
                            @"rid":@"QHVC_Demo_video15",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9kYjc3MzZlYmExMTJkODI4OWQ4OWUzYjhjZmY0MGQ2My5tcDQ%3D",
                            @"imageUrl":@"http://p7.qhimg.com/d/inn/cea3d896/img_15.png",
                            @"playCount":@"8.9万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(16)",
                            @"rid":@"QHVC_Demo_video16",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9iMGJlMmNmNThiZWEyYTIzODc0NDQxNWJkMGE2NzEwNS5tcDQ%3D",
                            @"imageUrl":@"http://p2.qhimg.com/d/inn/b2a8f96f/img_16.png",
                            @"playCount":@"15.2万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(17)",
                            @"rid":@"QHVC_Demo_video17",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9lYWI5ZTcxOGI2ZjZmMzQyMTA1M2YwZDg4MDZkZmE5Ni5tcDQ%3D",
                            @"imageUrl":@"http://p2.qhimg.com/d/inn/b2a8f96f/img_17.png",
                            @"playCount":@"1.2万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(18)",
                            @"rid":@"QHVC_Demo_video18",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi84ZWZlYzNlZjE3ZWFkNzBhYjZkOWJlZmMzY2Q4YmE2Ni5tcDQ%3D",
                            @"imageUrl":@"http://p9.qhimg.com/d/inn/b2a8f96f/img_18.png",
                            @"playCount":@"5.2万",
                            @"totalTime":@"00:15"
                            },
                        @{
                            @"title":@"小视频(19)",
                            @"rid":@"QHVC_Demo_video19",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi80MDE4MjA1ODIyZjU0ZjRjYjBiNzIzNTk3YTM1ZWMxNC5tcDQ%3D",
                            @"imageUrl":@"http://p5.qhimg.com/d/inn/b2a8f96f/img_19.png",
                            @"playCount":@"16.8万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(20)",
                            @"rid":@"QHVC_Demo_video20",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi8zMjhjZDliM2Y3OGU0NGIyYThkNjJmMGMyMjQ3OTc0Yy5tcDQ%3D",
                            @"imageUrl":@"http://p0.qhimg.com/d/inn/b2a8f96f/img_20.png",
                            @"playCount":@"2.3万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(21)",
                            @"rid":@"QHVC_Demo_video21",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi9lNGEyYjdjOGU0ZGYxZTIzNDdjYjVjMmMxNWRkMjU2NS5tcDQ%3D",
                            @"imageUrl":@"http://p6.qhimg.com/d/inn/b2a8f96f/img_21.png",
                            @"playCount":@"5.4万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(22)",
                            @"rid":@"QHVC_Demo_video22",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi85OTE0N2NkYmIxYTg2ZmI4ZGExNWExZTQ2NjA0MzI1Zi5tcDQ%3D",
                            @"imageUrl":@"http://p0.qhimg.com/d/inn/b2a8f96f/img_22.png",
                            @"playCount":@"3.4万",
                            @"totalTime":@"00:14"
                            },
                        @{
                            @"title":@"小视频(23)",
                            @"rid":@"QHVC_Demo_video23",
                            @"playUrl":@"http://tf.play.360kan.com/Object.access/toffee-source-src/L3JlbC92aWRlby9lbi8yMDE3MDYwNi80YjA3Njc0ZWFkMWExYjY2MzU5NGJmYTM4MDZmMmM4NC5tcDQ%3D",
                            @"imageUrl":@"http://p4.qhimg.com/d/inn/b2a8f96f/img_23.png",
                            @"playCount":@"13.6万",
                            @"totalTime":@"00:15"
                            }
                       ];
    }
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [settingButton removeFromSuperview];
    [self cancelPreload];
    NSLog(@"%s", __FUNCTION__);
}

@end
