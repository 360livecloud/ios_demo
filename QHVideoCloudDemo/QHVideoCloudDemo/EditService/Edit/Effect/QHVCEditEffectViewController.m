//
//  QHVCEditEffectViewController.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditEffectViewController.h"
#import "QHVCEditEffectView.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditEffectViewController ()
{
    QHVCEditEffectView *_effectView;
    NSArray <NSArray *> *_effects;
    BOOL _hasEffect;
}

@end

@implementation QHVCEditEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"特效"];
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    _effects = @[@[@"灵魂摆动", @"effect_1"],
                 @[@"effect_2", @"effect_2"],
                 @[@"effect_3", @"effect_3"],
                 @[@"虚拟镜像", @"effect_4"],
                 @[@"effect_5", @"effect_5"],
                 @[@"动感分屏", @"effect_6"],
                 @[@"effect_7", @"effect_7"],
                 @[@"Eglow", @"effect_8"],
                 @[@"炫酷转动", @"effect_9"],
                 @[@"effect_10", @"effect_10"],
                 @[@"空间隧道", @"effect_11"],
                 @[@"燥起来", @"effect_12"],
                 @[@"炫彩边缘", @"effect_13"],
                 @[@"魔法菲林", @"effect_14"],
                 @[@"自定义", @"effect_16"],
                 ];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self createEffectView];
}

- (void)createEffectView
{
    if (!_effectView) {
        _effectView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditEffectView class] description] owner:self options:nil][0];
        _effectView.frame = CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100);
        [_effectView updateView:_effects];
        WEAK_SELF
        _effectView.selectedCompletion = ^(NSInteger index) {
            STRONG_SELF
            if (!self->_hasEffect) {
                [[QHVCEditCommandManager manager] addEffect:(self->_effects[index])[1]];
                _hasEffect = YES;
            }else{
                [[QHVCEditCommandManager manager] adjustEffect:(self->_effects[index])[1]];
            }
            
        };
        [self.view addSubview:_effectView];
    }
}

- (void)nextAction:(UIButton *)btn
{
    [self releasePlayerVC];
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
