//
//  QHVCEditMakeViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditMakeViewController.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditPhotoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface QHVCEditMakeViewController ()<QHVCEditMakerDelegate>
{
    __weak IBOutlet UILabel *_loading;
    __weak IBOutlet UIView *_preview;
    QHVCEditMaker* _makerFactory;
    NSString *_makeFilePath;
}
@end

@implementation QHVCEditMakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = @"合成";
    [self.nextBtn setTitle:@"导出" forState:UIControlStateNormal];
    [self createPlayer:_preview];
    [self makeFile];
}

- (void)makeFile
{
    if (!_makerFactory)
    {
        _makerFactory = [[QHVCEditMaker alloc] initWithCommandFactory:[QHVCEditCommandManager manager].commandFactory];
        [_makerFactory setMakerDelegate:self];
    }
    _makeFilePath = [NSString stringWithFormat:@"%@/%@.mp4", [[QHVCEditPhotoManager manager] videoTempDir], @([NSDate date].timeIntervalSinceNow)];
    QHVCEditCommandMakeFile* command = [[QHVCEditCommandMakeFile alloc] initCommand:[QHVCEditCommandManager manager].commandFactory];
    [command setFilePath:_makeFilePath];
    [command addCommand];
    
    [_makerFactory makerStart];
    _loading.text = [NSString stringWithFormat:@"0%%"];
}

- (void)nextAction:(UIButton *)btn
{
    [[QHVCEditPhotoManager manager] saveVideoToAlbum:_makeFilePath];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)backAction:(UIButton *)btn
{
    [self freePlayer];
    [_makerFactory free];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark QHVCEditMakerDelegate

- (void)onMakerProcessing:(QHVCEditMakerStatus)status progress:(float)progress
{
    NSLog(@"progress %.2f", progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        _loading.text = [NSString stringWithFormat:@"%.2f%%",progress];
        if (progress >= 100) {
            _loading.hidden = YES;
            [self play];
        }
    });
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
