//
//  QHVCEditHueSlider.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QHVCEditHueSliderValueChanged)(CGFloat progress);

@interface QHVCEditHueSlider : UIView

@property (nonatomic,   copy) QHVCEditHueSliderValueChanged valueChangedAction;

@end

