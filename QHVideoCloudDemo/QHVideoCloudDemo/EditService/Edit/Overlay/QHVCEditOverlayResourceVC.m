//
//  QHVCEditOverlayResourceVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayResourceVC.h"
#import "UIView+Toast.h"
#import "QHVCEditPhotoManager.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditOverlayVC.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditOverlayResourceVC ()
@property (nonatomic, retain) QHVCEditOverlayVC* overlayVC;

@end

@implementation QHVCEditOverlayResourceVC

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSInteger matrixCount = MAX(1, [[QHVCEditPrefs sharedPrefs].matrixItems count]);
    self.maxCount = 9 - matrixCount;

    WEAK_SELF
    self.fullAction = ^(NSInteger maxCount)
    {
        STRONG_SELF
        [self.view makeToast:@"最多支持9张哦~" duration:2 position:CSToastPositionCenter];
    };
}

- (void)nextAction:(UIButton *)btn
{
    [[QHVCEditPhotoManager manager] writeAssetsToSandbox:self.selectedLists complete:^{
        [self.selectedLists enumerateObjectsUsingBlock:^(QHVCEditPhotoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             CGSize assetSize = CGSizeMake(obj.asset.pixelWidth, obj.asset.pixelHeight);
             NSInteger commandId = [[QHVCEditCommandManager manager] addOverlayFile:obj];
             QHVCEditMatrixItem* item = [[QHVCEditMatrixItem alloc] init];
             item.overlayCommandId = commandId;
             item.startTimestampMs = obj.startMs;
             item.endTiemstampMs = obj.endMs;
             item.sourceRect = CGRectMake(0, 0, assetSize.width, assetSize.height);
             item.originRect = CGRectMake(0, 0, assetSize.width, assetSize.height);
             [[QHVCEditPrefs sharedPrefs].matrixItems addObject:item];
             [[QHVCEditCommandManager manager] addMatrix:item];
         }];
        
        [self.selectedLists removeAllObjects];
        [self.navigationController pushViewController:self.overlayVC animated:YES];
    }];
}

- (QHVCEditOverlayVC *)overlayVC
{
    if (!_overlayVC)
    {
        _overlayVC = [[QHVCEditOverlayVC alloc] init];
    }
    return _overlayVC;
}

@end
