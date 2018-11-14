//
//  QHVCEditKenburnsVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/9/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditKenburnsVC.h"
#import "QHVCEditKenburnsView.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditKenburnsVC ()
@property (nonatomic, retain) QHVCEditKenburnsView* kenburnsView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGFloat currentIntensity;

@end

@implementation QHVCEditKenburnsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = @"变焦";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)nextAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createKenburnsView];
    _sliderViewBottom.constant = 70;
}

- (void)createKenburnsView
{
    _kenburnsView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditKenburnsView class] description] owner:self options:nil][0];
    _kenburnsView.frame = CGRectMake(0, kScreenHeight - 150, kScreenWidth, 150);
    [self.view addSubview:_kenburnsView];
    
    WEAK_SELF
    [_kenburnsView setSelectComplete:^(NSInteger index, CGFloat intensity)
    {
        STRONG_SELF
        [self updateKenburnsEffect:index intensity:intensity];
    }];
}

- (void)updateKenburnsEffect:(NSInteger)index intensity:(CGFloat)intensity
{
    if (_currentIndex == index && _currentIntensity == intensity)
    {
        return;
    }
    
    if (index == 0)
    {
        //删除
        [[QHVCEditCommandManager manager] deleteKenburnsEffect];
        _currentIndex = 0;
        _currentIntensity = 1.25;
        return;
    }
    
    NSDictionary* info = [self getKenburnsInfo:index intensity:intensity];
    [[QHVCEditCommandManager manager] updateKenburnsEffect:info];
    [self refreshPlayer];
    _currentIndex = index;
    _currentIntensity = intensity;
}

- (NSDictionary *)getKenburnsInfo:(NSInteger)index intensity:(CGFloat)intensity
{
    NSDictionary* dict = nil;
    switch (index)
    {
    case 1:
        {
            //推近
            dict = @{
                     @"fromScale": @(1.0+0.05*intensity),
                     @"toScale"  : @1.0,
                     @"fromX"    : @0.0,
                     @"fromY"    : @0.0,
                     @"toX"      : @0.0,
                     @"toY"      : @0.0,
                     };
            break;
        }
    case 2:
        {
            //拉远
            dict = @{
                     @"fromScale": @1.0,
                     @"toScale"  : @(1.0+0.05*intensity),
                     @"fromX"    : @0.0,
                     @"fromY"    : @0.0,
                     @"toX"      : @0.0,
                     @"toY"      : @0.0,
                     };
            break;
        }
    case 3:
        {
            //上移
            dict = @{
                     @"fromScale": @(1.0+0.05*intensity),
                     @"toScale"  : @(1.0+0.05*intensity),
                     @"fromX"    : @0.0,
                     @"fromY"    : @(0.0-0.025 * intensity/(1.0f+0.05f*intensity)),
                     @"toX"      : @0.0,
                     @"toY"      : @(0.0+0.025 * intensity/(1.0f+0.05f*intensity)),
                     };
            break;
        }
    case 4:
        {
            //下移
            dict = @{
                     @"fromScale": @(1.0+0.05*intensity),
                     @"toScale"  : @(1.0+0.05*intensity),
                     @"fromX"    : @0.0,
                     @"fromY"    : @(0.0+0.025 * intensity/(1.0f+0.05f*intensity)),
                     @"toX"      : @0.0,
                     @"toY"      : @(0.0-0.025 * intensity/(1.0f+0.05f*intensity)),
                     };
            break;
        }
    case 5:
        {
            //左移
            dict = @{
                     @"fromScale": @(1.0+0.05*intensity),
                     @"toScale"  : @(1.0+0.05*intensity),
                     @"fromX"    : @(0.0-0.025 * intensity/(1.0f+0.05f*intensity)),
                     @"fromY"    : @0.0,
                     @"toX"      : @(0.0+0.025 * intensity/(1.0f+0.05f*intensity)),
                     @"toY"      : @0.0,
                     };
            break;
        }
    case 6:
        {
            //右移
            dict = @{
                     @"fromScale": @(1.0+0.05*intensity),
                     @"toScale"  : @(1.0+0.05*intensity),
                     @"fromX"    : @(0.0+0.025 * intensity/(1.0f+0.05f*intensity)),
                     @"fromY"    : @0.0,
                     @"toX"      : @(0.0-0.025 * intensity/(1.0f+0.05f*intensity)),
                     @"toY"      : @0.0,
                     };
            break;
        }
    default:
        break;
    }
    return dict;
}

@end
