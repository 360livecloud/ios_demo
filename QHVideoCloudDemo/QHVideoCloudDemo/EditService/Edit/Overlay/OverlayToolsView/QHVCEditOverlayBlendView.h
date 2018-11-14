//
//  QHVCEditOverlayBlendView.h
//  QHVideoCloudToolSetDebug
//
//  Created by liyue-g on 2018/5/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OverlayBlendModeAction)(NSInteger modeIndex, CGFloat progress);

@interface QHVCEditOverlayBlendView : UIView

@property (nonatomic, copy) OverlayBlendModeAction blendAction;

@end
