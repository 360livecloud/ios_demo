//
//  QHVCEditOverlayFreedomItemView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditMatrixItem;
typedef void(^OverlayToolsRestPlayerAction)();
typedef void(^OverlayToolsRefreshPlayerAction)();
typedef void(^OverlayToolsShowPhotoAlbumAction)(QHVCEditMatrixItem* item);
typedef void(^OverlayToolsToTopAction)(QHVCEditMatrixItem* item);
typedef void(^OverlayToolsToBottomAction)(QHVCEditMatrixItem* item);
typedef void(^OverlayToolsCropAction)(QHVCEditMatrixItem* item);

@interface QHVCEditOverlayToolsView : UIView

@property (nonatomic, copy) OverlayToolsRestPlayerAction resetPlayerAction;
@property (nonatomic, copy) OverlayToolsRefreshPlayerAction refreshPlayerAction;
@property (nonatomic, copy) OverlayToolsShowPhotoAlbumAction showPhotoAlbumAction;
@property (nonatomic, copy) OverlayToolsToTopAction toTopAction;
@property (nonatomic, copy) OverlayToolsToBottomAction toBottomAction;
@property (nonatomic, copy) OverlayToolsCropAction cropAction;
@property (nonatomic, retain) QHVCEditMatrixItem* item;

@end
