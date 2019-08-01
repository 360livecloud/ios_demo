//
//  QHVCEditMonochromeTimelineView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

@class QHVCEditPlayerBaseVC;
@interface QHVCEditMonochromeTimelineView : UIView

- (void)setHue:(CGFloat)hue;
- (void)setPlayerBaseVC:(QHVCEditPlayerBaseVC *)playerBaseVC;
- (void)clearAllEffects;
- (void)pause;

@end
