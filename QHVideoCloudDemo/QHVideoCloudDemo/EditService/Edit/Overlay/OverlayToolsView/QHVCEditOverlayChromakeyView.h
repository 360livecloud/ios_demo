//
//  QHVCEditOverlayChromakeyView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/4/2.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OverlayChromakeyAction)(int threshold, int extend);
typedef void(^OverlayChromakeyStoppedAction)();

@interface QHVCEditOverlayChromakeyView : UIView
@property (nonatomic, copy) OverlayChromakeyAction chromakeyAction;
@property (nonatomic, copy) OverlayChromakeyStoppedAction chromakeyStoppedAction;

@end
