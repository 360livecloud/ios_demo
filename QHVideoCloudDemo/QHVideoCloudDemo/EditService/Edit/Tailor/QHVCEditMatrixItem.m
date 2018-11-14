//
//  QHVCEditMatrixItem.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditMatrixItem.h"

@implementation QHVCEditMatrixItem

- (instancetype)copy
{
    QHVCEditMatrixItem* item = [[QHVCEditMatrixItem alloc] init];
    item.overlayCommandId = self.overlayCommandId;
    item.frameRadian = self.frameRadian;
    item.flipX = self.flipX;
    item.flipY = self.flipY;
    item.renderRect = self.renderRect;
    item.sourceRect = self.sourceRect;
    item.originRect = self.originRect;
    item.zOrder = self.zOrder;
    item.preview = self.preview;
    item.outputParams = self.outputParams;
    item.startTimestampMs = self.startTimestampMs;
    item.endTiemstampMs = self.endTiemstampMs;
    return item;
}

@end
