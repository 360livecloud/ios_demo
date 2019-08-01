//
//  QHVCEditOverlayContentView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/7.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCPhotoItem.h"
#import "QHVCEditOverlayItemView.h"
#import "QHVCEditStickerItemView.h"
#import "QHVCEditSubtitleItemView.h"
#import "QHVCEditMosaicItemView.h"

typedef void(^QHVCEditMainContentResetPlayerBlock)(void);
typedef void(^QHVCEditMainContentRefreshPlayerBlock)(BOOL isEnd);
typedef void(^QHVCEditMainContentRefreshPlayerForBasicParam)(void);

@class QHVCEditPlayerBaseVC;
@interface QHVCEditMainContentView : UIView

- (void)setBasePlayerVC:(QHVCEditPlayerBaseVC *)playerBaseVC;
- (void)addOverlays:(NSArray<QHVCPhotoItem *> *)items complete:(void(^)(void))complete;
- (QHVCEditStickerItemView *)addSticker:(UIImage *)image;
- (QHVCEditSubtitleItemView *)addSubtitle:(UIImage *)image;
- (QHVCEditMosaicItemView *)addMosaic;
- (void)clear;

@property (nonatomic,   copy) QHVCEditMainContentRefreshPlayerBlock refreshPlayerAction;
@property (nonatomic,   copy) QHVCEditMainContentResetPlayerBlock resetPlayerAction;
@property (nonatomic,   copy) QHVCEditMainContentRefreshPlayerForBasicParam refreshPlayerForBasicParamAction;

@end
