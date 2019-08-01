//
//  QHVCEditDynamicSubtitleTimelineView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/11.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditPlayerBaseVC;
@interface QHVCEditDynamicSubtitleTimelineView : UIView

- (void)setPlayerBaseVC:(QHVCEditPlayerBaseVC *)playerBaseVC;
- (void)addMaskWithDuration:(NSInteger)duration;

@end

