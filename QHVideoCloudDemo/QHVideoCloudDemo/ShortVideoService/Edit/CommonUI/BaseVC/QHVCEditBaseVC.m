//
//  QHVCEditBaseVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditBaseVC.h"
#import "QHVCEditPrefs.h"
#import "UIViewAdditions.h"
#import "sys/utsname.h"

@interface QHVCEditBaseVC ()
{
    CGFloat _kTopBarViewHeight;
    CGFloat _kYoffset;
    BOOL _alreadyLayoutSubviews;
}

@end

@implementation QHVCEditBaseVC

/**
 * 获取设备型号
 */
- (NSString *)getMachineInfo
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _kTopBarViewHeight = 60 + 10;
    _kYoffset = 10;
    
    NSString* machineInfo = [self getMachineInfo];
    if ([machineInfo compare:@"iPhone10" options:NSNumericSearch] != NSOrderedAscending)
    {
        _kTopBarViewHeight = 80;
    }
    
    _topBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, _kTopBarViewHeight)];
    _topBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_topBarView];
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _kYoffset, kScreenWidth, _topBarView.height - _titleLabel.top)];
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    _titleLabel.textColor = [QHVCEditPrefs colorHex:@"A0A0A3"];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_topBarView addSubview:_titleLabel];
    
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, _kYoffset, 50, _titleLabel.height)];
    [_backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [_backBtn setBackgroundColor:[UIColor clearColor]];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_topBarView addSubview:_backBtn];
    
    _nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(_topBarView.width - _backBtn.height, _kYoffset, _backBtn.width, _backBtn.height)];
    [_nextBtn addTarget:self action:@selector(nextBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_nextBtn setBackgroundColor:[UIColor clearColor]];
    [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _nextBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _nextBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_topBarView addSubview:_nextBtn];
}

- (void)viewWillLayoutSubviews
{
    if (!_alreadyLayoutSubviews)
    {
        [self prepareSubviews];
        _alreadyLayoutSubviews = YES;
    }
}

- (void)prepareSubviews
{
    //override
}

- (void)setTitle:(NSString *)title
{
    [_titleLabel setText:title];
}

- (void)setNextBtnTitle:(NSString *)title
{
    [_nextBtn setTitle:title forState:UIControlStateNormal];
}

- (void)backBtn:(UIButton *)sender
{
    [self backAction:sender];
}

- (void)nextBtn:(UIButton *)sender
{
    [self nextAction:sender];
}

- (void)hideTopNav
{
    [_topBarView setHidden:YES];
}

- (void)showTopNav
{
    [_topBarView setHidden:NO];
}

- (CGFloat)topBarHeight
{
    return _kTopBarViewHeight;
}

//子类可重写
- (void)backAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction:(UIButton *)btn
{
    
}

@end
