//
//  QHVCEditOverlayBottomView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditMatrixItem;
typedef void(^OverlayChangeColorAction)(NSString* argbColor);
typedef void(^OverlayRestPlayerAction)();
typedef void(^OverlayRefreshPlayerAction)();
typedef void(^OverlayShowPhotoAlbumAction)(QHVCEditMatrixItem* item);
typedef void(^OverlayToTopAction)(QHVCEditMatrixItem* item);
typedef void(^OverlayToBottomAction)(QHVCEditMatrixItem* item);
typedef void(^OverlayStartCropAction)(QHVCEditMatrixItem* item);
typedef void(^OverlayStopCropAction)(QHVCEditMatrixItem* item, BOOL confirm);

@interface QHVCEditOverlayBottomView : UIView

- (void)showOverlayToolsView:(QHVCEditMatrixItem *)item;
- (void)hideOverlayToolsView;

@property (nonatomic, copy) OverlayChangeColorAction changeColorAction;
@property (nonatomic, copy) OverlayRestPlayerAction resetPlayerAction;
@property (nonatomic, copy) OverlayRefreshPlayerAction refreshPlayerAction;
@property (nonatomic, copy) OverlayShowPhotoAlbumAction showPhotoAlbumAction;
@property (nonatomic, copy) OverlayToTopAction toTopAction;
@property (nonatomic, copy) OverlayToBottomAction toBottomAction;
@property (nonatomic, copy) OverlayStartCropAction startCropAction;
@property (nonatomic, copy) OverlayStopCropAction stopCropAction;

@end
