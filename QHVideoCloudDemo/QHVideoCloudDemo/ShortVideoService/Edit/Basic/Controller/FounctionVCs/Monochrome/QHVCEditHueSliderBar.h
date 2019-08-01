//
//  QHVCEditHueSliderBar.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditGestureView.h"

typedef void(^QHVCEditHueSliderBarMoveAction)(void);

@interface QHVCEditHueSliderBar : QHVCEditGestureView

@property (nonatomic,   copy) QHVCEditHueSliderBarMoveAction moveAction;

@end
