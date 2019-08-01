//
//  QHGViewUtils.h
//  QHGroupUI
//
//  Created by wangdacheng on 17/7/17.
//  Copyright © 2017年 北京奇虎科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QHVCGVBarBtnUtils : NSObject

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action image:(UIImage *)image;

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action image:(UIImage *)image imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;

+ (UIButton *)createCustomBarBtnWithTarget:(id)target
                                    action:(SEL)action
                                nomalImage:(UIImage *)nomalImage
                          higeLightedImage:(UIImage *)higeLightedImage
                           imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action title:(NSString *)title;

+ (UIButton *)createCustomBarBtnWithTarget:(id)target action:(SEL)action title:(NSString *)title titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;

+ (UIButton *)createCustomBarBtnWithTarget:(id)target
                                    action:(SEL)action
                                     title:(NSString *)title
                                      font:(UIFont *)font
                                titleColor:(UIColor *)titleColor
                          highlightedColor:(UIColor *)highlightedColor
                           titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;

@end
