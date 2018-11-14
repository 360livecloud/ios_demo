//
//  QHVCEditOverlayAlphaMovView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeAlphaMovAction)(NSString* filePath);
@interface QHVCEditOverlayAlphaMovView : UIView

@property (nonatomic, copy) ChangeAlphaMovAction changeAlphaMovAction;

@end
