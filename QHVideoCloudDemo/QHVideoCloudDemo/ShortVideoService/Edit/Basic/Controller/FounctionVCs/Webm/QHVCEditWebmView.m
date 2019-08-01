//
//  QHVCEditWebmView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/6.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditWebmView.h"
#import "QHVCEditMainContentView.h"
#import "UIView+Toast.h"
#import "QHVCEditPrefs.h"

@implementation QHVCEditWebmView

- (IBAction)clickedAddButton:(UIButton *)sender
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"webm01" ofType:@"webm"];
    QHVCEditFileInfo* info = [QHVCEditTools getFileInfo:filePath];
    if (info)
    {
        QHVCPhotoItem* item = [[QHVCPhotoItem alloc] init];
        item.isLocalFile = NO;
        item.filePath = filePath;
        item.assetType = info.isPicture ? QHVCAssetType_Image : QHVCAssetType_Video;
        item.assetWidth = info.width;
        item.assetHeight = info.height;
        item.assetDurationMs = info.durationMs;
        item.thumbImage = [UIImage imageNamed:@"edit_play"];
        
        WEAK_SELF
        [self.playerContentView addOverlays:@[item] complete:^{
            STRONG_SELF
            SAFE_BLOCK(self.updatePlayerDuraionBlock);
        }];
    }
    else
    {
        [self makeToast:@"添加失败"];
    }
}


@end
