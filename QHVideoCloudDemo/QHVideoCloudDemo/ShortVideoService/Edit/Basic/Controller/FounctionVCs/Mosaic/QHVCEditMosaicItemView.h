//
//  QHVCEditMosaicItemView.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2018/12/28.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCEditGestureView.h"

NS_ASSUME_NONNULL_BEGIN

@class QHVCEditMosaicEffect;

typedef void(^QHVCEditMosaicItemRefreshPlayerForBasicParamBlock)(void);
typedef void(^QHVCEditMosaicItemRefreshPlayerBlock)(BOOL forceRefresh);

@interface QHVCEditMosaicItemView : QHVCEditGestureView

- (void)updateIntensity:(CGFloat)intensity;

@property (nonatomic,   copy) QHVCEditMosaicItemRefreshPlayerForBasicParamBlock refreshPlayerForBasicParamBlock;
@property (nonatomic,   copy) QHVCEditMosaicItemRefreshPlayerBlock refreshPlayerBlock;
@property (nonatomic, retain) QHVCEditMosaicEffect* effect;

@end

NS_ASSUME_NONNULL_END
