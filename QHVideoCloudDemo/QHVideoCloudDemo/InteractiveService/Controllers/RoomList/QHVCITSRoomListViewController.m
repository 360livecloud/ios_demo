//
//  QHVCITSRoomListViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSRoomListViewController.h"
#import "QHVCITSRoomListCell.h"
#import "QHVCITSProtocolMonitor.h"
#import "QHVCITSUserSystem.h"
#import "QHVCITSLog.h"
#import "QHVCITSCreateRoomViewController.h"
#import "QHVCITSLinkMicViewController.h"
#import "QHVCITSDefine.h"
#import "QHVCITSChatManager.h"
#import "QHVCToast.h"

static NSString *roomListCellIdentifier = @"QHVCITSRoomListCell";

@interface QHVCITSRoomListViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UITextField *_textField;
    IBOutlet UITableView *_generalTableView;
    NSMutableArray<NSDictionary *> *_dataArray;
    QHVCITSRoomType _serverRoomType;
}
@property (nonatomic, strong) QHVCITSHTTPSessionManager* httpManager;

@end

@implementation QHVCITSRoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_roomType == QHVCITFunctionTypeOwnerAndGuest) {
        _titleLabel.text = @"主播&嘉宾";
        _serverRoomType = QHVCITS_Room_Type_Guest;
    }
    else if (_roomType == QHVCITFunctionTypeOwnerVSOwner)
    {
        _titleLabel.text = @"主播vs主播";
        _serverRoomType = QHVCITS_Room_Type_PK;
    }
    else if (_roomType == QHVCITFunctionTypeHongpa)
    {
        _titleLabel.text = @"开趴大厅";
        _serverRoomType = QHVCITS_Room_Type_Party;
    }
    _dataArray = [NSMutableArray array];
    _httpManager = [QHVCITSHTTPSessionManager new];
    
    [self connectIM];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchRoomList];
}

- (void)connectIM
{
    [QHVCITSChatManager connect:^(NSString *userId) {
        
    } error:^(QHVCIMConnectErrorCode status) {
        
    }];
}

- (void)disconnectIM
{
    [QHVCITSChatManager disconnect];
}

- (void)fetchRoomList
{
    NSMutableDictionary* roomListDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:roomListDict key:QHVCITS_KEY_USER_ID value:[QHVCITSUserSystem sharedInstance].userInfo.userId];
    [QHVCToolUtils setIntToDictionary:roomListDict key:QHVCITS_KEY_ROOM_TYPE value:_serverRoomType];
    
    __weak typeof(self) weakSelf = self;
    [QHVCITSProtocolMonitor getRoomList:_httpManager
                                   dict:roomListDict
                               complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                   [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"getRoomList" dict:dict];
                                   [weakSelf handleRoomListResponse:success dict:dict];
                               }];
}

- (void)handleRoomListResponse:(BOOL)success dict:(NSDictionary *)dict
{
    if (success) {
        NSArray *data = dict[@"data"];
        if (_dataArray.count > 0) {
            [_dataArray removeAllObjects];
        }
        [_dataArray addObjectsFromArray:data];
        [_generalTableView reloadData];
    }
}

#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = _dataArray[indexPath.row];
    
    QHVCITSRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:roomListCellIdentifier];
    if (!cell) {
        [_generalTableView registerNib:[UINib nibWithNibName:roomListCellIdentifier
                                                     bundle:nil]
               forCellReuseIdentifier:roomListCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:roomListCellIdentifier];
    }
    [cell updateCell:dic];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary* currentRoomDict = _dataArray[indexPath.row];
    [self startLinkMicViewController:currentRoomDict];
}

- (IBAction)gotoRoom:(UIButton *)sender
{
    NSString* roomId = _textField.text;
    if ([QHVCToolUtils isNullString:roomId] || ![QHVCToolUtils isPureInt:roomId])
    {
        [QHVCToast makeToast:@"请输入有效的房间Id"];
        
        return;
    }
    //TODO:添加菊花动画
    
    NSMutableDictionary* roomInfoDict = [NSMutableDictionary dictionary];
    NSString* userId = [[QHVCITSUserSystem sharedInstance] userInfo].userId;
    [QHVCToolUtils setStringToDictionary:roomInfoDict key:QHVCITS_KEY_USER_ID value:userId];
    [QHVCToolUtils setStringToDictionary:roomInfoDict key:QHVCITS_KEY_ROOM_ID value:roomId];
    [QHVCToolUtils setIntToDictionary:roomInfoDict key:QHVCITS_KEY_ROOM_TYPE value:QHVCITS_Room_Type_Guest];
    WEAK_SELF_LINKMIC
    [QHVCITSProtocolMonitor getRoomInfo:_httpManager
                                   dict:roomInfoDict
                               complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                   [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"getRoomInfo" dict:dict];
                                   STRONG_SELF_LINKMIC
                                   //TODO:取消菊花
                                   if (success)
                                   {
                                       [self startLinkMicViewController:dict[@"data"]];
                                   }else
                                   {
                                       [QHVCToast makeToast:dict[@"errmsg"]];
                                   }
                               }];
}

- (void) startLinkMicViewController:(NSDictionary*)roomDict
{
    QHVCITSRoomModel* roomInfo = [QHVCITSRoomModel new];
    [roomInfo parseServerData:roomDict];
    [[QHVCITSUserSystem sharedInstance] setRoomInfo:roomInfo];
    
    [[QHVCITSUserSystem sharedInstance] userInfo].identity = QHVCITS_Identity_Audience;
    
    QHVCITSLinkMicViewController *vc = [[QHVCITSLinkMicViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    [_textField resignFirstResponder];
}

- (IBAction)createRoom:(UIButton *)sender
{
    QHVCITSCreateRoomViewController *vc = [[QHVCITSCreateRoomViewController alloc] init];
    vc.roomType = _serverRoomType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickedBack:(id)sender
{
    [self disconnectIM];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
