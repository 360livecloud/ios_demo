//
//  QHVCEditBeautifyViewController.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/4.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditBeautifyViewController.h"
#import "QHVCEditBeautifyView.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditBeautifyViewController (){
    QHVCEditBeautifyView *_beautifyView;
}

@end

@implementation QHVCEditBeautifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = @"美颜";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createBeautifyView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createBeautifyView
{
    _beautifyView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditBeautifyView class] description] owner:self options:nil][0];
    _beautifyView.frame = CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100);
    
    [[QHVCEditCommandManager manager] openBeauty:.5f white:.5f];
    WEAK_SELF
    _beautifyView.onChangeComplete = ^(float beautyLevel, float whiteLevel, float faceLevel, float eyeLevel) {
        STRONG_SELF
        [[QHVCEditCommandManager manager] adjustBeauty:beautyLevel white:whiteLevel];
        [self refreshPlayer];
    };

    [self.view addSubview:_beautifyView];
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
