//
//  QHVCEditStickerItemView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditGestureView.h"
#import "QHVCEditMediaEditor.h"

@class QHVCEditStickerItemView;
@class QHVCEditPlayerBaseVC;
typedef void(^QHVCEditStickerItemRefreshPlayerForBasicParamBlock)(void);
typedef void(^QHVCEditStickerItemRefreshPlayerBlock)(BOOL forceRefresh);

@interface QHVCEditStickerItemView : QHVCEditGestureView

- (void)setImage:(UIImage *)image;
- (void)addAnimationOfIndex:(NSInteger)animationIndex;

@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerBaseVC;
@property (nonatomic, retain) QHVCEditStickerEffect* effectImage;
@property (nonatomic,   copy) QHVCEditStickerItemRefreshPlayerForBasicParamBlock refreshPlayerForBasicParamBlock;
@property (nonatomic,   copy) QHVCEditStickerItemRefreshPlayerBlock refreshPlayerBlock;

@end
