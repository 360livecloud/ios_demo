//
//  QHVCUploadingViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2017/6/16.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCUploadingViewController.h"
#import "QHVCLiveMainCellOne.h"
#import "md5.h"
#import "QHVCUploadProgressView.h"
#import "QHVCUploadFinishView.h"
#import <QHVCUploadKit/QHVCUploader.h>

static NSString * const FILE_NAME = @"upVideo";
static NSString * const FILE_EXT = @"mp4";

static NSString *LiveMainCellOneCellIdenitifer = @"QHVCLiveMainCellOne";

@interface QHVCUploadingViewController ()<UITableViewDelegate,UITableViewDataSource,QHVCUploaderDelegate,QHVCRecorderDelegate>
{
    __weak IBOutlet UITableView *generalTableView;
    NSMutableArray *_dataArray;
    
    QHVCUploadFinishView *_finish;
}
@property (nonatomic, strong) NSString *accessKey;
@property (nonatomic, strong) NSString *secretKey;
@property (nonatomic, strong) NSString *bucket;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) QHVCUploader *uploader;
@property (nonatomic, strong) QHVCUploader *logsUploader;
@property (nonatomic, strong) QHVCUploadProgressView *progress;
@end

@implementation QHVCUploadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //注：直播云sdk需要在app启动时调用coreOnAppStart方法，sdk才可正常执行，可参考demo中AppDelegate.m中的实现
    NSString* path = [[NSBundle mainBundle] pathForResource:@"uploadMain" ofType:@"plist"];
    _dataArray = [NSMutableArray arrayWithContentsOfFile:path];
    
    NSLog(@"sdk ver %@",[QHVCUploader sdkVersion]);
    
    //设置有效的业务相关id
    [QHVCUploader setStatisticsInfo:@{@"channelId":@"demo_1",
                                      @"userId":@"110"
                                      }];
    NSLog(@"sdk ver %@",[QHVCUploader sdkVersion]);
    
//    业务根据在官网申请bucket时选择的地区设置，上传前设置(必填)
//     （选择北京地区上传地址：up-beijing.oss.yunpan.360.cn
//      选择上海地区上传地址：up-shanghai.oss.yunpan.360.cn）
    [QHVCUploader setUploadDomain:@"up-beijing.oss.yunpan.360.cn"];
    
#ifdef DEBUG
    //debug阶段辅助开发调试，根据实际情况使用
    [QHVCUploader openLogWithLevel:QHVCUploadLogLevelDebug];
    [QHVCUploader setLogOutputCallBack:^(int loggerID, QHVCUploadLogLevel level, const char * _Nonnull data) {
        NSLog(@"log %@", [NSString stringWithUTF8String:data]);
    }];
#endif
}

- (void)dealloc
{
    if (self.uploader) {
        [self.uploader cancel];
        self.uploader = nil;
    }
    if (self.logsUploader) {
        [self.logsUploader cancel];
        self.logsUploader = nil;
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
    NSMutableDictionary *dic = _dataArray[indexPath.row];
    
    QHVCLiveMainCellOne *cell = [tableView dequeueReusableCellWithIdentifier:LiveMainCellOneCellIdenitifer];
    if (!cell) {
        [generalTableView registerNib:[UINib nibWithNibName:LiveMainCellOneCellIdenitifer
                                                     bundle:nil]
               forCellReuseIdentifier:LiveMainCellOneCellIdenitifer];
        cell = [tableView dequeueReusableCellWithIdentifier:LiveMainCellOneCellIdenitifer];
    }
    [cell updateCell:dic encryptProcesString:nil];
    return cell;
}

#pragma mark Action
- (IBAction)clickedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)uploadLogs:(id)sender
{
    if (self.logsUploader) {
        [self.logsUploader cancel];
        self.logsUploader = nil;
    }
    _logsUploader =  [[QHVCUploader alloc]init];
    [_logsUploader setUploaderDelegate:self];
    [_logsUploader uploadLogs];
    
    [self showProgressView];
}

- (IBAction)start:(UIButton *)sender
{
    if (![self fetchUploadInfo]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"请输入正确的AK、SK,如无该信息官网注册申请" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = (self.fileUrl.length > 0)?self.fileUrl:[[NSBundle mainBundle] pathForResource:FILE_NAME ofType:FILE_EXT];
    if (filePath) {
        BOOL isExist = [fileManager fileExistsAtPath:filePath];
        if (!isExist) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"文件不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    NSDictionary *fileAtt = [fileManager attributesOfItemAtPath:filePath error:nil];
    NSNumber *fileSizeNum = [fileAtt objectForKey:NSFileSize];
    uint64_t fileSize = fileSizeNum.unsignedLongLongValue;
    NSLog(@"file size %@",fileSizeNum);
    if (fileSize > 0) {
        [self upload:fileSize filePath:filePath];
        [self showProgressView];
    }
}

- (void)upload:(uint64_t)size filePath:(NSString *)filePath
{
    if (_uploader) {
        [_uploader cancel];
        _uploader = nil;
    }
    _uploader =  [[QHVCUploader alloc]init];
    [_uploader setUploaderDelegate:self];
//    [_uploader setRecorderDelegate:self];//分片断点续传，根据实际业务需求选择使用
    QHVCUploadTaskType type = [_uploader uploadTaskType:size];
    if (type == QHVCUploadTaskTypeUnknow) {
        NSLog(@"invalid file");
        return;
    }
    NSString *token;
    if (type == QHVCUploadTaskTypeParallel) {
        NSInteger num = [_uploader parallelQueueNum];
        token = [self generateParallelTaskToken:num filesize:size fileName:[filePath lastPathComponent]];//token在服务器计算（此处仅供demo层模拟）
    }
    else if(type == QHVCUploadTaskTypeForm)
    {
        token = [self generateFormTaskToken:[filePath lastPathComponent]];//filename 唯一
    }
//    NSString *recorderKey = [self generateRecorderKey:[filePath lastPathComponent]];
//    if (recorderKey) {
//        [_uploader setUploadRecorderKey:recorderKey];
//    }
    [_uploader uploadFile:filePath fileName:[filePath lastPathComponent] token:token];
}


- (void)showProgressView
{
    if (!_progress) {
        _progress = [[NSBundle mainBundle] loadNibNamed:[[QHVCUploadProgressView class] description] owner:self options:nil][0];
        _progress.frame = self.view.bounds;
        __weak typeof(self) wself = self;
        _progress.onCancelBlock = ^{
            if (wself.uploader) {
                [wself.uploader cancel];
            }
            if (wself.progress) {
                [wself.progress removeFromSuperview];
            }
        };
    }
    [self.view addSubview:_progress];
}

- (void)showFinishView:(BOOL)result
{
    if (_progress) {
        [_progress removeFromSuperview];
        _progress = nil;
    }
    if (!_finish) {
        _finish = [[NSBundle mainBundle] loadNibNamed:[[QHVCUploadFinishView class] description] owner:self options:nil][0];
        _finish.frame = self.view.bounds;
    }
    [self.view addSubview:_finish];
    [_finish updateFinish:result];
}

- (BOOL)fetchUploadInfo
{
    self.accessKey = [_dataArray[0] valueForKey:@"value"];
    self.secretKey = [_dataArray[1] valueForKey:@"value"];
    self.bucket = [_dataArray[4] valueForKey:@"value"];
    self.fileUrl = [_dataArray[5] valueForKey:@"value"];
    if (self.accessKey.length<= 0||
        self.secretKey.length<=0||
        self.bucket.length<=0) {
        return NO;
    }
    return YES;
}

- (NSString *)generateParallelTaskToken:(NSInteger)parallel filesize:(uint64_t)size fileName:(NSString *)filename
{
    NSDictionary* dict=@{@"bucket":self.bucket,
                         @"object":filename,
                         @"fsize":@(size),
                         @"parallel":@(parallel),
                         @"insertOnly":@"0"};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    NSString *jsonBase64 = [jsonData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    NSString *realSignBeforeMd5 = [self md5String:[jsonBase64 stringByAppendingString:self.secretKey]];
    NSString *realSignString = [NSString stringWithFormat:@"%@:%@:%@",self.accessKey,realSignBeforeMd5,jsonBase64];
    
    return realSignString;
}

- (NSString *)generateFormTaskToken:(NSString *)filename
{
    NSDictionary* dict=@{@"bucket":self.bucket,
                         @"object":filename,
                         @"deadline":[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]+3600],
                         @"insertOnly":@"0"};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    NSString *jsonBase64 = [jsonData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *realSignBeforeMd5 = [self md5String:[jsonBase64 stringByAppendingString:self.secretKey]];
    NSString *realSignString = [NSString stringWithFormat:@"%@:%@:%@",self.accessKey,realSignBeforeMd5,jsonBase64];
    
    return realSignString;
}

- (NSString *)md5String:(NSString *)str{
    gnet::MD5_CTX md5;
    MD5_Init(&md5);
    MD5_Update(&md5, [str cStringUsingEncoding:NSUTF8StringEncoding], strlen([str cStringUsingEncoding:NSUTF8StringEncoding]));
    unsigned char result[16];
    MD5_Final(result, &md5);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

#pragma mark QHVCUploaderDelegate

- (void)didUpload:(QHVCUploader *)uploader status:(QHVCUploadStatus)status error:(nullable NSError *)error
{
//    NSLog(@"didUpload status %@,%@,%@",uploader,@(status),error);
    if (uploader == _uploader||uploader == _logsUploader)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == QHVCUploadStatusUploadSucceed) {
                [self showFinishView:YES];
            }
            else if (status == QHVCUploadStatusUploadFail||
                     status == QHVCUploadStatusUploadError)
            {
                [self showFinishView:NO];
            }
            else if (status == QHVCUploadStatusUploadCancel)
            {
                NSLog(@"The task has cancel");
            }
        });
    }
}

- (void)didUpload:(QHVCUploader *)uploader progress:(float)progress
{
//    NSLog(@"didUpload progress %@,%f",uploader,progress);
    if (uploader == _uploader||uploader == _logsUploader)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_progress updateProgress:progress];
        });
    }
}

#pragma mark QHVCRecorderDelegate
//上传信息需要持久化缓存，缓存形式根据实际情况选择使用（数据库、文件...）
- (void)setRecorder:(NSString *)key data:(NSData *)data
{
    NSString *dir = [self recorderDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:nil])
    {
        BOOL isSucess = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isSucess) {
            return ;
        }
    }
    BOOL status = [data writeToFile:[dir stringByAppendingPathComponent:key] atomically:NO];
    if (!status) {
        NSLog(@"write fail!");
    }
}

- (NSData *)fetchRecorder:(NSString *)key
{
    NSString *dir = [self recorderDir];
    NSData *data = [NSData dataWithContentsOfFile:[dir stringByAppendingPathComponent:key]];
    return data;
}

- (void)deleteRecorder:(NSString *)key
{
    NSString *dir = [self recorderDir];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dir stringByAppendingPathComponent:key] isDirectory:nil])
    {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[dir stringByAppendingPathComponent:key] error:&error];
        if (!success) {
            NSLog(@"delete fail!");
        }
    }
}

- (NSString *)recorderDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    NSString *cacheFilePath = [cachesDir stringByAppendingPathComponent:@"upload"];
    return cacheFilePath;
}

- (NSString *)generateRecorderKey:(NSString *)filePath
{
    //分片断点续传,key的生成方式根据实际业务情况生成,每个key对应一个上传任务信息
    return [self md5String:filePath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
