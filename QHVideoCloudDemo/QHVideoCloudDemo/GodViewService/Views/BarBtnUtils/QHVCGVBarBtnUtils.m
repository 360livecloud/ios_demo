//
//  QHGViewUtils.m
//  QHGroupUI
//
//  Created by wangdacheng on 17/7/17.
//  Copyright © 2017年 北京奇虎科技有限公司. All rights reserved.
//

#import "QHVCGVBarBtnUtils.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@implementation QHVCGVBarBtnUtils

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action image:(UIImage *)image
{
    return [self createCustomBarBtnWithTarget:target action:action nomalImage:image higeLightedImage:nil imageEdgeInsets:UIEdgeInsetsZero];
}

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action image:(UIImage *)image imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets
{
    return [self createCustomBarBtnWithTarget:target action:action nomalImage:image higeLightedImage:nil imageEdgeInsets:imageEdgeInsets];
}

+ (UIButton *)createCustomBarBtnWithTarget:(id)target
                                           action:(SEL)action
                                       nomalImage:(UIImage *)nomalImage
                                 higeLightedImage:(UIImage *)higeLightedImage
                                  imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [button setImage:[nomalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    if (higeLightedImage) {
        [button setImage:[higeLightedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
    }
    button.frame = CGRectMake(0, 0, 40, 40);
    button.imageEdgeInsets = imageEdgeInsets;
    return button;
}

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action title:(NSString *)title
{
    return [self createCustomBarBtnWithTarget:target action:action title:title font:nil titleColor:nil highlightedColor:nil titleEdgeInsets:UIEdgeInsetsZero];
}

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action title:(NSString *)title titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
    return [self createCustomBarBtnWithTarget:target action:action title:title font:nil titleColor:nil highlightedColor:nil titleEdgeInsets:titleEdgeInsets];
}

+ (UIButton *)createCustomBarBtnWithTarget:(id)target
                                    action:(SEL)action
                                     title:(NSString *)title
                                      font:(UIFont *)font
                                titleColor:(UIColor *)titleColor
                          highlightedColor:(UIColor *)highlightedColor
                           titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = font?font:nil;
    [button setTitleColor:titleColor?titleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:highlightedColor?highlightedColor:nil forState:UIControlStateHighlighted];
    [button setTitleColor:[QHVCToolUtils colorWithHexString:@"#B0B0B0"] forState:UIControlStateDisabled];
    [button sizeToFit];
    button.frame = CGRectMake(0, 0, button.frame.size.width+18, 40);
    button.titleEdgeInsets = titleEdgeInsets;
    return button;
}

@end
