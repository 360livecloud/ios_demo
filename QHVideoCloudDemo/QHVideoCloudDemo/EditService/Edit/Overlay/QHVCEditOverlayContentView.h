//
//  QHVCEditOverlayContentView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditMatrixItem;
typedef void(^OverlayTapAction)(QHVCEditMatrixItem* item);
typedef void(^PlayerNeedRefreshAction)(BOOL forceRefresh);

@interface QHVCEditOverlayContentView : UIView

- (void)updateOverlayZOrderToTop:(QHVCEditMatrixItem *)item;
- (void)updateOverlayZOrderToBottom:(QHVCEditMatrixItem *)item;
- (void)overlayStartCrop:(QHVCEditMatrixItem *)item;
- (void)overlayStopCrop:(QHVCEditMatrixItem *)item confirm:(BOOL)confirm;
- (void)disSelectAllOverlay;

@property (nonatomic, copy) OverlayTapAction overlayTapAction;
@property (nonatomic, copy) PlayerNeedRefreshAction playerNeedRefreshAction;

@end
