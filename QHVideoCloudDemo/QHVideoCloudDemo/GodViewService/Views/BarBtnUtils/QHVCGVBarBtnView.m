//
//  QHGBarButtonView.m
//  QHGroupUI
//
//  Created by wangdacheng on 2017/10/23.
//  Copyright © 2017年 北京奇虎科技有限公司. All rights reserved.
//

#import "QHVCGVBarBtnView.h"
//#import "QHGroupUI.h"

@interface QHVCGVBarBtnView ()
{
    BOOL applied;
}

@end

@implementation QHVCGVBarBtnView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (applied || [[[UIDevice currentDevice] systemVersion] doubleValue]  < 11)
    {
        return;
    }
    
    UIView *view = self;
    while (![view isKindOfClass:[UINavigationBar class]] && [view superview] != nil)
    {
        view = [view superview];
        if (@available(iOS 9.0, *)) {
            if ([view isKindOfClass:[UIStackView class]] && [view superview] != nil)
            {
                CGFloat constant = 1;
                if (self.position == QHVCGVBarButtonViewPositionLeft)
                {
                    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0+constant]];
                    applied = YES;
                }
                else if (self.position == QHVCGVBarButtonViewPositionRight)
                {
                    [view.superview addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0-constant]];
                    applied = YES;
                }
                break;
            }
        }
    }
}

@end
