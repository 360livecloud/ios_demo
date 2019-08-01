//
//  QHVCGVBaseViewController.h
//  QHGroupUI
//
//  Created by sunyimin on 2017/7/13.
//  Copyright © 2017年 北京奇虎科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface QHVCGVBaseViewController : UIViewController

- (void)setupBackBarButton;

- (void)setRightBarButtonView:(UIView *)view;

- (void)onBack;

- (void)keyBoardWillShowWithHeight:(CGFloat)height;

- (void)keyboardWillHide;

@end
