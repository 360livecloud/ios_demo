//
//  QHVCITSCreateRoomViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSCreateRoomViewController.h"
#import "QHVCITSLinkMicViewController.h"
#import "QHVCITSProtocolMonitor.h"
#import "QHVCITSLog.h"
#import "QHVCITSUserSystem.h"
#import "QHVCToast.h"

@interface QHVCITSCreateRoomViewController ()<UITextFieldDelegate>
{
    IBOutlet UITextField *_nameTextField;
    IBOutlet UITextField *_numTextField;
    QHVCITSTalkType _talkType;
    NSInteger _numLimit;
}
@property (nonatomic, strong) QHVCITSHTTPSessionManager* httpManager;

@end

@implementation QHVCITSCreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _httpManager = [QHVCITSHTTPSessionManager new];
    _talkType = QHVCITS_Talk_Type_Normal;
    _numLimit = 6;
}

- (IBAction)clickedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)audioAction:(UISwitch *)sender
{
    if (sender.on) {
        _talkType = QHVCITS_Talk_Type_Audio;
        _numLimit = 100;
    }
    else
    {
        _talkType = QHVCITS_Talk_Type_Normal;
        _numLimit = 6;
    }
}

- (IBAction)confirm:(UIButton *)sender
{
    [self sendCreateRoomRequest];
}

- (void)sendCreateRoomRequest
{
    NSMutableDictionary* createRoomDict = [NSMutableDictionary dictionary];
    [QHVCToolUtils setStringToDictionary:createRoomDict key:QHVCITS_KEY_USER_ID value:[QHVCITSUserSystem sharedInstance].userInfo.userId];
    [QHVCToolUtils setStringToDictionary:createRoomDict key:QHVCITS_KEY_ROOM_NAME value:_nameTextField.text];
    [QHVCToolUtils setIntToDictionary:createRoomDict key:QHVCITS_KEY_ROOM_TYPE value:_roomType];
    [QHVCToolUtils setIntToDictionary:createRoomDict key:QHVCITS_KEY_TALK_TYPE value:_talkType];
    [QHVCToolUtils setIntToDictionary:createRoomDict key:QHVCITS_KEY_ROOM_LIFE_TYPE value:(_roomType == QHVCITS_Room_Type_Party)?2:1];//1、绑定到主播    2、绑定到房间
    [QHVCToolUtils setIntToDictionary:createRoomDict key:QHVCITS_KEY_MAX_NUMBER value:_numTextField.text.intValue];
    
    WEAK_SELF_LINKMIC
    [QHVCITSProtocolMonitor createRoom:_httpManager
                                  dict:createRoomDict
                              complete:^(NSURLSessionDataTask * _Nullable taskData, BOOL success, NSDictionary * _Nullable dict) {
                                  [QHVCITSLog printLogger:QHVCITS_LOG_LEVEL_DEBUG content:@"createRoom" dict:dict];
                                  STRONG_SELF_LINKMIC
                                  [self handleCreateRoomResponse:success dict:dict];
                              }];
}

- (void)handleCreateRoomResponse:(BOOL)sucess dict:(NSDictionary *)dict
{
    if (sucess)
    {
        [self clickedBack:nil];
        //数据准备
        NSDictionary* roomDataDict = [QHVCToolUtils getObjectFromDictionary:dict key:QHVCITS_KEY_DATA defaultValue:nil];
        QHVCITSRoomModel* roomInfo = [QHVCITSRoomModel new];
        [roomInfo parseServerData:roomDataDict];
        roomInfo.roomType = self.roomType;
        [[QHVCITSUserSystem sharedInstance] setRoomInfo:roomInfo];
        [[QHVCITSUserSystem sharedInstance] userInfo].identity = QHVCITS_Identity_Anchor;
        //页面跳转
        QHVCITSLinkMicViewController *vc = [[QHVCITSLinkMicViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else
    {
        NSString *errorMsg = [NSString stringWithFormat:@"%@,%@",dict[@"errno"],dict[@"errmsg"]];
        [QHVCToast makeToast:errorMsg];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _nameTextField) {
        NSString *roomName = _nameTextField.text;
        NSString *temp = [roomName stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (temp.length <= 0) {
            [QHVCToast makeToast:@"请输入有效的房间名称"];
            return NO;
        }
        if ([roomName containsString:@"&"]) {
            [QHVCToast makeToast:@"房间名称不支持&字符"];
            return NO;
        }
        if(roomName.length > 20)
        {
            [QHVCToast makeToast:@"房间名称长度（1-20）"];
            return NO;
        }
    }
    else if(textField == _numTextField)
    {
        if (_numTextField.text.intValue <= 0||
            _numTextField.text.intValue > _numLimit) {
            [QHVCToast makeToast:@"输入正确互动人数"];
            return NO;
        }
    }
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
