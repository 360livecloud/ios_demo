//
//  QHVCEditCutViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditCutViewController.h"
#import "QHVCEditCutView.h"
#import "QHVCEditTransferViewController.h"

#define kCutViewHeightNormal 95
#define kCutViewHeightHighlight 135

@interface QHVCEditCutViewController ()
{
    QHVCEditCutView *_cutView;
}
@end

@implementation QHVCEditCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"分段";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createCutView];
}

- (void)nextAction:(UIButton *)btn
{
    [self releasePlayerVC];
}

- (void)backAction:(UIButton *)btn
{
    [self releasePlayerVC];
}

- (void)createCutView
{
    if (!_cutView) {
        _cutView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditCutView class] description] owner:self options:nil][0];
        _cutView.frame = CGRectMake(0, kScreenHeight - kCutViewHeightNormal, kScreenWidth, kCutViewHeightNormal);
        _cutView.duration = self.durationMs;
        [_cutView freshView];
        __weak typeof(self) weakSelf = self;
        _cutView.cutCompletion = ^{
            [weakSelf handleCutAction];
        };
        _cutView.cancelCompletion = ^{
            [weakSelf handleCancelAction];
        };
        _cutView.doneCompletion = ^{
            [weakSelf handleDoneAction];
        };
        [self.view addSubview:_cutView];
    }
}

- (void)updateCutViewHeight:(BOOL)isHighlight
{
    if (isHighlight) {
        if (_cutView.height != kCutViewHeightHighlight) {
            _cutView.y = kScreenHeight - kCutViewHeightHighlight;
            _cutView.height = kCutViewHeightHighlight;
            _cutView.confirmView.hidden = NO;
            [_cutView layoutIfNeeded];
            _sliderViewBottom.constant = 50;
        }
    }
    else
    {
        if (_cutView.height != kCutViewHeightNormal) {
            _cutView.y = kScreenHeight - kCutViewHeightNormal;
            _cutView.height = kCutViewHeightNormal;
            _cutView.confirmView.hidden = YES;
            [_cutView layoutIfNeeded];
            _sliderViewBottom.constant = 15;
        }
    }
}

- (void)handleCutAction
{
    [self updateCutViewHeight:YES];
}

- (void)handleCancelAction
{
    [self updateCutViewHeight:NO];
}

- (void)handleDoneAction
{
    QHVCEditTransferViewController *vc = [[QHVCEditTransferViewController alloc] initWithNibName:@"QHVCEditPlayerMainViewController" bundle:nil];
    vc.durationMs = self.durationMs;
//    __weak typeof(self) weakSelf = self;
//    vc.confirmCompletion = ^(QHVCEditPlayerStatus status) {
//        if (status == QHVCEditPlayerStatusRefresh) {
//            [weakSelf refreshPlayer];
//        }
//        else if (status == QHVCEditPlayerStatusReset)
//        {
//            [weakSelf resetPlayer:self.durationMs];
//        }
//    };
    [self.navigationController pushViewController:vc animated:YES];
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
