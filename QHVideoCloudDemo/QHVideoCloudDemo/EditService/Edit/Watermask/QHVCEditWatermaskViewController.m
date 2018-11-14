//
//  QHVCEditWatermaskViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/4.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditWatermaskViewController.h"
#import "UIViewAdditions.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditWatermaskViewController ()
{
    UIButton *_watermaskBtn;
    BOOL _watermaskStatus;
}
@end

@implementation QHVCEditWatermaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"水印";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    _watermaskStatus = [QHVCEditPrefs sharedPrefs].isEnableWatermsk;

    [self createWatermaskView];
}

- (void)createWatermaskView
{
    _watermaskBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100)];
    [_watermaskBtn addTarget:self action:@selector(watermaskAction:) forControlEvents:UIControlEventTouchUpInside];
    [_watermaskBtn setBackgroundColor:[UIColor blackColor]];
    NSString *text = [QHVCEditPrefs sharedPrefs].isEnableWatermsk?@"关闭":@"开启";
    [_watermaskBtn setTitle:[NSString stringWithFormat:@"%@水印",text] forState:UIControlStateNormal];
    [_watermaskBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_watermaskBtn];
}

- (void)watermaskAction:(UIButton *)sender
{
    if ([QHVCEditPrefs sharedPrefs].isEnableWatermsk) {
        [_watermaskBtn setTitle:@"开启水印" forState:UIControlStateNormal];
        [QHVCEditPrefs sharedPrefs].isEnableWatermsk = NO;
        [self deleteWatermaskCommand];
    }
    else
    {
        [_watermaskBtn setTitle:@"关闭水印" forState:UIControlStateNormal];
        [QHVCEditPrefs sharedPrefs].isEnableWatermsk = YES;
        [self addWatermaskCommand];
    }
    [self refreshPlayer];
}

- (void)nextAction:(UIButton *)btn
{
    if (_watermaskStatus != [QHVCEditPrefs sharedPrefs].isEnableWatermsk) {
        if (self.confirmCompletion) {
            self.confirmCompletion(QHVCEditPlayerStatusRefresh);
        }
    }
    [self releasePlayerVC];
}

- (void)backAction:(UIButton *)btn
{
    if (_watermaskStatus != [QHVCEditPrefs sharedPrefs].isEnableWatermsk)
    {
        [QHVCEditPrefs sharedPrefs].isEnableWatermsk = _watermaskStatus;
    }
    [self releasePlayerVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - command methods

- (void)addWatermaskCommand
{
    UIImage* image = [UIImage imageNamed:@"edit_watermask"];
    QHVCEditCommandImageFilter* filter = [[QHVCEditCommandManager manager] addImageFilter:image
                                                                               renderRect:CGRectMake(10, 10, 200, 30)
                                                                                   radian:0];
    [[QHVCEditPrefs sharedPrefs] setWatermaskFilter:filter];
}

- (void)deleteWatermaskCommand
{
    QHVCEditCommandImageFilter* filter = [[QHVCEditPrefs sharedPrefs] watermaskFilter];
    [[QHVCEditCommandManager manager] deleteImageFilter:filter];
}

@end
