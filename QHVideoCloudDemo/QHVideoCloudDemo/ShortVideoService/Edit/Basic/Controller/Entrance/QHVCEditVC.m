//
//  QHVCEditVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditVC.h"
#import "QHVCEditSelectPhotoAlbumVC.h"

@interface QHVCEditVC ()

@end

@implementation QHVCEditVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    QHVCEditSelectPhotoAlbumVC* vc = [[QHVCEditSelectPhotoAlbumVC alloc] init];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
