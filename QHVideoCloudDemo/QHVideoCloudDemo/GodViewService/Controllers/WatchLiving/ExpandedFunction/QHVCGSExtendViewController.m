//
//  QHVCGSExtendViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/6.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSExtendViewController.h"
#import "QHVCGSImageDownloadViewController.h"

@interface QHVCGSExtendViewController ()

@end

@implementation QHVCGSExtendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)clickedBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickedImageDownloadAction:(id)sender {
    QHVCGSImageDownloadViewController* viewController = [QHVCGSImageDownloadViewController new];
    viewController.deviceModel = _deviceModel;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
