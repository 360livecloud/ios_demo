//
//  QHVCEditBaseViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditBaseViewController.h"

#define kTopBarViewHeight 60
#define kYoffset 10

@interface QHVCEditBaseViewController ()
{
    UIView *_topBarView;
}
@end

@implementation QHVCEditBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _topBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopBarViewHeight)];
    _topBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_topBarView];
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kYoffset, kScreenWidth, _topBarView.height - _titleLabel.top)];
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    _titleLabel.textColor = [QHVCEditPrefs colorHex:@"A0A0A3"];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_topBarView addSubview:_titleLabel];
    
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, kYoffset, 50, _titleLabel.height)];
    [_backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [_backBtn setBackgroundColor:[UIColor clearColor]];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_topBarView addSubview:_backBtn];
    
    _nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(_topBarView.width - _backBtn.height, kYoffset, _backBtn.width, _backBtn.height)];
    [_nextBtn addTarget:self action:@selector(nextBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_nextBtn setBackgroundColor:[UIColor clearColor]];
    [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _nextBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _nextBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_topBarView addSubview:_nextBtn];
}

- (void)backBtn:(UIButton *)sender
{
    [self backAction:sender];
}

- (void)nextBtn:(UIButton *)sender
{
    [self nextAction:sender];
}

//子类可重写
- (void)backAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction:(UIButton *)btn
{
    
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
