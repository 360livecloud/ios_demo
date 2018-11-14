//
//  QHVCEditOverlayChangeResourceVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayChangeResourceVC.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditPhotoManager.h"

@interface QHVCEditOverlayChangeResourceVC ()

@end

@implementation QHVCEditOverlayChangeResourceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.maxCount = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)backAction:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextAction:(UIButton *)btn
{
    [[QHVCEditPhotoManager manager] writeAssetsToSandbox:self.selectedLists complete:^{
        WEAK_SELF
        [self.selectedLists enumerateObjectsUsingBlock:^(QHVCEditPhotoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             STRONG_SELF
             [[QHVCEditCommandManager manager] updateOverlayFile:obj overlayId:self.item.overlayCommandId];
             self.item.startTimestampMs = obj.startMs;
             self.item.endTiemstampMs = obj.endMs;
             [[QHVCEditCommandManager manager] updateMatrix:self.item];
         }];
        
        
        SAFE_BLOCK(self.resetPlayerAction);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
