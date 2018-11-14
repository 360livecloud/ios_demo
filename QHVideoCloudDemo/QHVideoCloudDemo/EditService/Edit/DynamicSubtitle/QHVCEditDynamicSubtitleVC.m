//
//  QHVCEditDynamicSubtitleVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/10/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditDynamicSubtitleVC.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditDynamicSubtitleVC ()
@property (nonatomic, retain) UIButton* dynamicSubtitleBtn;

@end

@implementation QHVCEditDynamicSubtitleVC

- (void)nextAction:(UIButton *)btn
{
    [self releasePlayerVC];
}

- (void)backAction:(UIButton *)btn
{
    [self releasePlayerVC];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"动态字幕";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self createView];
}

- (void)createView
{
    _dynamicSubtitleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100)];
    [_dynamicSubtitleBtn addTarget:self action:@selector(onDynamicSubtitleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_dynamicSubtitleBtn setBackgroundColor:[UIColor blackColor]];
    NSString *text = [QHVCEditPrefs sharedPrefs].isEnableDynamicSubtitle?@"关闭":@"开启";
    [_dynamicSubtitleBtn setTitle:[NSString stringWithFormat:@"%@动态字幕",text] forState:UIControlStateNormal];
    [_dynamicSubtitleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_dynamicSubtitleBtn];
}

- (void)onDynamicSubtitleButtonClicked:(UIButton *)button
{
    if (![QHVCEditPrefs sharedPrefs].isEnableDynamicSubtitle)
    {
        [_dynamicSubtitleBtn setTitle:@"关闭动态字幕" forState:UIControlStateNormal];
        [QHVCEditPrefs sharedPrefs].isEnableDynamicSubtitle = YES;
        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"test.ass" ofType:nil];
        [[QHVCEditCommandManager manager] addDynamicSubtitle:filePath];
    }
    else
    {
        [_dynamicSubtitleBtn setTitle:@"开启动态字幕" forState:UIControlStateNormal];
        [QHVCEditPrefs sharedPrefs].isEnableDynamicSubtitle = NO;
        [[QHVCEditCommandManager manager] deleteDynamicSubtitle];
    }
    [self refreshPlayer];
}

@end
