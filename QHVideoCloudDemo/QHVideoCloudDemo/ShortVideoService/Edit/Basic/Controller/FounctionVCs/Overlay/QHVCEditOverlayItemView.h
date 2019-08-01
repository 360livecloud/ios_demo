//
//  QHVCEditOverlayItemView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/7.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditGestureView.h"
#import "QHVCPhotoItem.h"
#import "QHVCEditTrackClipItem.h"

@class QHVCEditOverlayItemView;
typedef void(^QHVCEditOverlayItemRefreshPlayerBlock)(BOOL forceRefresh);
typedef void(^QHVCEditOverlayItemResetPlayerBlock)(void);
typedef void(^QHVCEditOverlayItemTappedAction)(QHVCEditOverlayItemView* item);

@interface QHVCEditOverlayItemView : QHVCEditGestureView

- (void)setPhotoItem:(QHVCPhotoItem *)item;

@property (nonatomic, retain) QHVCEditTrackClipItem* clipItem;
@property (nonatomic,   copy) QHVCEditOverlayItemRefreshPlayerBlock refreshPlayerBlock;
@property (nonatomic,   copy) QHVCEditOverlayItemResetPlayerBlock resetPlayerBlock;
@property (nonatomic,   copy) QHVCEditOverlayItemTappedAction tapAction;

@end
