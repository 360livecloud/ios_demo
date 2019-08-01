//
//  QHVCGSViewController.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/7.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSCloudRecordListViewController.h"
#import "QHVCGSCloudRecordFlowLayout.h"
#import "QHVCGSCloudRecordCell.h"
#import "QHVCGVCloudRecordModel.h"
#import "QHVCPlayerViewController.h"
#import "QHVCGVConfig.h"
#import "QHVCHUDManager.h"
#import "QHVCGVCloudRecordViewModel.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGVDeviceModel.h"
#import "QHVCToast.h"

#define kQHVCGSCloudRecordListVC_CollectionViewMarginTop     10

static NSString *const kQHVCGVVideoListVCCellIdentifier     = @"QHVCGVVideoListVCCell";
static NSString *const kQHVCGVVideoListVC_Loading           = @"Loading...";


@interface QHVCGSCloudRecordListViewController () <UICollectionViewDelegate, UICollectionViewDataSource,QHVCGSCloudRecordCellDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic,strong) QHVCGVCloudRecordViewModel *viewModel;

@end

@implementation QHVCGSCloudRecordListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setupBackBarButton];
    self.viewModel = [QHVCGVCloudRecordViewModel new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"云录像";
    
    QHVCGSCloudRecordFlowLayout *flowLayout = [QHVCGSCloudRecordFlowLayout new];
    // collectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[QHVCGSCloudRecordCell class] forCellWithReuseIdentifier:kQHVCGVVideoListVCCellIdentifier];
    if (@available(iOS 11, *))
    {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kQHVCGSCloudRecordListVC_CollectionViewMarginTop);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
}

- (void)onBack
{
    [super onBack];
}
#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCGSCloudRecordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQHVCGVVideoListVCCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    QHVCGVCloudRecordModel *recordModel = self.dataSource[indexPath.row];
    [cell setupWithImageName:recordModel.thumbnail indexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    QHVCGVCloudRecordModel *model = _dataSource[indexPath.row];
    NSDictionary *config = @{
                             kQHVCPlayerConfigKeyBid:[QHVCGlobalConfig sharedInstance].appId,
                             kQHVCPlayerConfigKeyCid:[QHVCGlobalConfig sharedInstance].appId,
                             kQHVCPlayerConfigKeyUrl:model.url ?: @"",
                             kQHVCPlayerConfigKeyDecodeType:@0,
                             kQHVCPlayerConfigKeyIsOutputPacket:@1,
                             kQHVCPlayerConfigKeyEncryptKey:model.encryptKey
                             };
    
    QHVCPlayerViewController *pvc = [[QHVCPlayerViewController alloc] initWithPlayerConfig:config];
    [self.navigationController pushViewController:pvc animated:YES];
}

#pragma mark - QHVCGSCloudRecordCellDelegate
- (void)cloudRecordCell:(QHVCGSCloudRecordCell *)cloudRecordCell didClickDeleteAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCGVCloudRecordModel *model = _dataSource[indexPath.row];
    QHVC_WEAK_SELF
    
    QHVCHUDManager *hud = [QHVCHUDManager new];
    [hud showLoadingProgressOnView:self.view message:kQHVCGVVideoListVC_Loading];
    [_viewModel deleteCloudRecordWithSerialNumber:_deviceModel.bindedSN recordId:model.recordId completion:^(BOOL isSuccess) {
        [hud hideHud];
        if (isSuccess)
        {
            QHVC_STRONG_SELF
            NSMutableArray *tmpArray = [_dataSource mutableCopy];
            [tmpArray removeObjectAtIndex:indexPath.row];
            self.dataSource = [tmpArray copy];
            [self.collectionView reloadData];
        }
    }];
}


- (void)cloudRecordCell:(QHVCGSCloudRecordCell *)cloudRecordCell didClickMenuIndexPath:(NSIndexPath *)indexPath
{
    // 点击单元格的菜单时，消除其他单元格上的菜单
    NSArray *cells = _collectionView.visibleCells;
    for (QHVCGSCloudRecordCell *cell in cells)
    {
        if (cell != cloudRecordCell)
        {
            [cell hideMenu];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
