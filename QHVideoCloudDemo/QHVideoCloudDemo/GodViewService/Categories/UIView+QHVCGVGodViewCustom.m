//
//  UIView+QHVCGVGodViewCustom.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/31.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "UIView+QHVCGVGodViewCustom.h"

@implementation UIView (QHVCGVGodViewCustom)

/**
 * 截图
 */
- (UIImage *)takeScreenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES,[UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;

}

@end
