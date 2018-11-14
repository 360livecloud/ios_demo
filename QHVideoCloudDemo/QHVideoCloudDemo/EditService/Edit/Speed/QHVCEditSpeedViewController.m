//
//  QHVCEditSpeedViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSpeedViewController.h"
#import "QHVCEditSpeedView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditSpeedViewController ()
{
    QHVCEditSpeedView *_speedView;
    float _currentSpeed;
}
@end

@implementation QHVCEditSpeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"倍速";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    _currentSpeed = [QHVCEditPrefs sharedPrefs].editSpeed;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createSpeedView];
}

- (void)createSpeedView
{
    _speedView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditSpeedView class] description] owner:self options:nil][0];
    _speedView.frame = CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100);
    __weak typeof(self) weakSelf = self;
    _speedView.changeCompletion = ^(float value) {
        [weakSelf adjustSpeed:value];
    };
    [self.view addSubview:_speedView];
}

- (void)adjustSpeed:(float)value
{
    if (_currentSpeed != value) {
        [[QHVCEditCommandManager manager] adjustSpeed:value];
        _currentSpeed = value;
    }
}

- (void)nextAction:(UIButton *)btn
{
    if (_currentSpeed != [QHVCEditPrefs sharedPrefs].editSpeed) {
        [QHVCEditPrefs sharedPrefs].editSpeed = _currentSpeed;
    }
    [self releasePlayerVC];
}

- (void)backAction:(UIButton *)btn
{
    if (_currentSpeed != [QHVCEditPrefs sharedPrefs].editSpeed) {
        [[QHVCEditCommandManager manager] adjustSpeed:[QHVCEditPrefs sharedPrefs].editSpeed];
    }
    [self releasePlayerVC];
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
