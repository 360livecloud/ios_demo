//
//  QHVCEditQualityViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditQualityViewController.h"
#import "QHVCEditQualityView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditQualityViewController ()
{
    QHVCEditQualityView *_qualityView;
    NSMutableArray<NSNumber *> *_qualitys;
    BOOL _hasChange;
}
@end

@implementation QHVCEditQualityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"调节";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    _qualitys = [NSMutableArray arrayWithArray:[QHVCEditPrefs sharedPrefs].qualitys];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createQualityView];
    _sliderViewBottom.constant += 70;
}

- (void)createQualityView
{
    _qualityView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditQualityView class] description] owner:self options:nil][0];
    _qualityView.frame = CGRectMake(0, kScreenHeight - 160, kScreenWidth, 160);
    __weak typeof(self) weakSelf = self;
    _qualityView.changeCompletion = ^(NSInteger type, float value) {
        [weakSelf adjustQuality:type value:value];
    };
    [self.view addSubview:_qualityView];
}

- (void)adjustQuality:(NSInteger)type value:(float)value
{
    BOOL hasChange = [[QHVCEditCommandManager manager] adjustQuality:type value:value];
    if (hasChange) {
        [self refreshPlayer];
        [_qualitys replaceObjectAtIndex:type withObject:@(value)];
        _hasChange = hasChange;
    }
}

- (void)nextAction:(UIButton *)btn
{
    if (_hasChange) {
        [QHVCEditPrefs sharedPrefs].qualitys = _qualitys;
        if (self.confirmCompletion) {
            self.confirmCompletion(QHVCEditPlayerStatusRefresh);
        }
    }
    [self releasePlayerVC];
}

- (void)backAction:(UIButton *)btn
{
    NSInteger i = 0;
    for (NSNumber *v in [QHVCEditPrefs sharedPrefs].qualitys) {
        if (v.floatValue != _qualitys[i].floatValue) {
            [[QHVCEditCommandManager manager] adjustQuality:i value:v.floatValue];
        }
        i++;
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
