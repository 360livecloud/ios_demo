//
//  QHVCRecordSettingViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/10/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordSettingViewController.h"

@interface QHVCRecordSettingViewController ()

@end

@implementation QHVCRecordSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark Action

- (IBAction)clickedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
