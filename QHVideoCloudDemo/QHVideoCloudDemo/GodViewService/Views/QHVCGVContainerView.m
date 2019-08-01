//
//  QHVCGVContainerView.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/12/29.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCGVContainerView.h"

@implementation QHVCGVContainerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.userInteractionEnabled == NO || self.alpha < 0.001 || self.hidden == YES)
    {
        return nil;
    }
    if (![self pointInside:point withEvent:event])
    {
        return nil;
    }
    for (UIView *subView in self.subviews)
    {
        CGPoint childPoint = [self convertPoint:point toView:subView];
        UIView *view = [subView hitTest:childPoint withEvent:event];
        if (view)
        {
            return view;
        }
    }
    return nil;
}

@end
