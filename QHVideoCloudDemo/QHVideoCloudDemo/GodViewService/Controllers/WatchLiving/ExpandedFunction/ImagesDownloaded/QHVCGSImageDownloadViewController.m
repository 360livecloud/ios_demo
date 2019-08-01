//
//  QHVCGSImageDownloadViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/6.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSImageDownloadViewController.h"
#import "QHVCGSImageDownloadModel.h"
#import "QHVCGSImageDownloadTableViewCell.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <QHVCNetKit/QHVCNetKit.h>
#import "QHVCToast.h"
#import "QHVCGodViewLocalManager.h"
#import "QHVCLogger.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGVUserSystem.h"

// 常量
static NSString *kQHVCGSImageDownloadCellIdentifier = @"QHVCGSImageDownloadTableViewCell";

@interface QHVCGSImageDownloadViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serialNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *taskNumberTextField;
@property (weak, nonatomic) IBOutlet UITableView *generalTableView;

@property (nonatomic, strong) QHVCURLSessionManager* urlSessionManager;
@property (nonatomic, strong) NSMutableArray<QHVCGSImageDownloadModel *>* imageDownloadArray;

@property (nonatomic, assign) NSInteger taskNumber;

@end

@implementation QHVCGSImageDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _serialNumberTextField.text = _deviceModel.bindedSN;
    _taskNumberTextField.text = @"1";
    _imageDownloadArray = [NSMutableArray arrayWithCapacity:5];
    _urlSessionManager = [QHVCURLSessionManager new];
}

#pragma mark - UI 事件 -

- (IBAction)clickedBackAction:(id)sender {
    [self stopAllDownloadTask];
    _urlSessionManager = nil;
    _imageDownloadArray = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickedStartDownloadAction:(id)sender {
    [self downloadImageFromServer];
}

- (IBAction)clickedCleanTaskAction:(id)sender {
    [self stopAllDownloadTask];
    [_generalTableView reloadData];
}

#pragma mark - UITableView 代理回调 -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _imageDownloadArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QHVCGSImageDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQHVCGSImageDownloadCellIdentifier];
    if (!cell) {
        [_generalTableView registerNib:[UINib nibWithNibName:kQHVCGSImageDownloadCellIdentifier
                                                      bundle:nil]
                forCellReuseIdentifier:kQHVCGSImageDownloadCellIdentifier];
        cell = [_generalTableView dequeueReusableCellWithIdentifier:kQHVCGSImageDownloadCellIdentifier];
    }
    QHVC_WEAK_SELF
    QHVCGSImageDownloadModel *imageDownloadModel = _imageDownloadArray[indexPath.section];
    [cell updateCell:imageDownloadModel];
    [cell setDeleteBlock:^(QHVCGSImageDownloadModel * _Nonnull model) {
        QHVC_STRONG_SELF
        [[self imageDownloadArray] removeObject:model];
        [[self generalTableView] reloadData];
    }];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == _taskNumberTextField) {
        return [self validateNumber:string];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 私有方法 -
- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void)downloadImageFromServer {
    NSString* serialNumber = [_serialNumberTextField text];
    if ([QHVCToolUtils isNullString:serialNumber]) {
        [QHVCToast makeToast:@"序列号不能为空！"];
        return;
    }
    NSInteger number = ((NSNumber *)[QHVCToolUtils valueToNumber:[_taskNumberTextField text]]).integerValue;
    if (number <= 0) {
        [QHVCToast makeToast:@"任务数量需要>=1"];
        return;
    }
    if (number > 64) {
        [QHVCToast makeToast:@"任务数量需要<=64"];
        return;
    }
    for (int i = 0; i<number; i++) {
        QHVCGSImageDownloadModel* model = [QHVCGSImageDownloadModel new];
        model.imageName = [NSString stringWithFormat:@"image%d.jpg",i+1];
        [_imageDownloadArray addObject:model];
    }
    [_generalTableView reloadData];
    QHVCGVUserModel* userInfo = [QHVCGVUserSystem sharedInstance].userInfo;
    QHVCGlobalConfig* globalConfig = [QHVCGlobalConfig sharedInstance];
    NSString* businessSign = [QHVCGlobalConfig generateBusinessSubscriptionSignWithAppId:globalConfig.appId
                                                                      serialNumber:serialNumber
                                                                          deviceId:globalConfig.deviceId
                                                                            appKey:globalConfig.appKey];
    //请求任务
    for (int i = 0; i <number ; i++) {
        QHVCGSImageDownloadModel* model = _imageDownloadArray[i];
        NSString* resultString = nil;
        [[QHVCGodViewLocalManager sharedInstance] getDeviceFileDownloadUrlWithFileKey:model.imageName
                                                                             clientId:globalConfig.deviceId
                                                                                appId:globalConfig.appId
                                                                               userId:userInfo.userId
                                                                         serialNumber:serialNumber
                                                                         businessSign:businessSign
                                                                                token:@"业务验证码"
                                                                           rangeStart:0
                                                                             rangeEnd:0
                                                                      resultUrlString:&resultString];
        model.url = resultString;
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"download path:%@",resultString]];
        NSURL* requestUrl = [NSURL URLWithString:resultString];
        QHVC_WEAK_SELF
        NSURLSessionDownloadTask* downloadTask
        = [_urlSessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:requestUrl]
                                             progress:^(NSProgress * _Nonnull downloadProgress) {
                                                 model.currentSize = downloadProgress.completedUnitCount;
                                                 model.totalSize = downloadProgress.totalUnitCount;
                                                 NSString* tmp = [NSString stringWithFormat:@"download progress:%f,fileName:%@",model.currentSize * 1.0 / model.totalSize,resultString];
                                                 [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:tmp];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     QHVC_STRONG_SELF
                                                     [[self generalTableView] reloadData];
                                                 });
                                             }
                                          destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                              NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",model.imageName]];
                                              return [NSURL fileURLWithPath:path];
                                          }
                                    completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                        NSString* tmp = [NSString stringWithFormat:@"download finish:%@,error=%@",filePath.absoluteString,error];
                                        [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:tmp];
                                        if (error) {
                                            [QHVCToast makeToast:tmp];
                                        }
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            QHVC_STRONG_SELF
                                            [[self generalTableView] reloadData];
                                        });
                                    }];
        model.downloadTask = downloadTask;
        [downloadTask resume];
    }
}

- (void) stopAllDownloadTask {
    for (int i = 0; i < _imageDownloadArray.count; i++) {
        QHVCGSImageDownloadModel* model = _imageDownloadArray[i];
        [[model downloadTask] cancel];
    }
    [[_urlSessionManager operationQueue] cancelAllOperations];
    [_imageDownloadArray removeAllObjects];
}

@end
