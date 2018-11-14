//
//  QHVCEditOverlayBgColorView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeColorAction)(NSString* argbColor);
@interface QHVCEditOverlayBgColorView : UIView

@property (nonatomic, copy) ChangeColorAction changeColorAction;

@end
