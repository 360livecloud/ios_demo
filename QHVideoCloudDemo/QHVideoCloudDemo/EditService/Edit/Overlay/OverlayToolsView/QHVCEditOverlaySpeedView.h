//
//  QHVCEditOverlaySpeedView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeSpeedAction)(CGFloat speed);
@interface QHVCEditOverlaySpeedView : UIView

@property (nonatomic, copy) ChangeSpeedAction changeSpeedAction;

@end
