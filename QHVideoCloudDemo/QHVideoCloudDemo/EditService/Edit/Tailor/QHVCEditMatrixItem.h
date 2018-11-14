//
//  QHVCEditMatrixItem.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QHVCEditOverlayItemPreview;
@class QHVCEditOutputParams;
@interface QHVCEditMatrixItem : NSObject

@property (nonatomic, assign) NSInteger overlayCommandId;
@property (nonatomic, assign) CGFloat frameRadian;
@property (nonatomic, assign) CGFloat previewRadian;
@property (nonatomic, assign) BOOL flipX;
@property (nonatomic, assign) BOOL flipY;
@property (nonatomic, assign) CGRect renderRect;
@property (nonatomic, assign) CGRect sourceRect;
@property (nonatomic, assign) CGRect originRect;
@property (nonatomic, assign) NSInteger zOrder;
@property (nonatomic, retain) QHVCEditOverlayItemPreview* preview;
@property (nonatomic, retain) QHVCEditOutputParams* outputParams;
@property (nonatomic, assign) NSTimeInterval startTimestampMs;
@property (nonatomic, assign) NSTimeInterval endTiemstampMs;

- (instancetype)copy;

@end
