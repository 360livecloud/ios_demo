//
//  QHVCGVFunctionBtn.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVFunctionBtn : UIButton


/**
 * @param iconImage 按钮icon
 * @param text      icon下方文字说明
 */
- (void)setupWithIconImage:(UIImage *)iconImage
                      text:(NSString *)text;

/**
 * @param iconImage 按钮icon
 * @param text      icon下方文字说明
 * @param textColor 文字颜色
 */
- (void)setupWithIconImage:(UIImage *)iconImage
                      text:(NSString *)text
                 textColor:(UIColor *)textColor;

/**
 * @param iconImage 按钮icon
 * @param text      icon下方文字说明
 * @param textColor 文字颜色
 * @param font      字体
 */
- (void)setupWithIconImage:(UIImage *)iconImage
                      text:(NSString *)text
                 textColor:(UIColor *)textColor
                      font:(UIFont *)font;

/**
 * @param iconImage 按钮icon
 * @param selectedImage 按钮选中效果的图片
 * @param text      icon下方文字说明
 * @param textColor 文字颜色
 * @param font      字体
 */
- (void)setupWithIconImage:(UIImage *)iconImage
             selectedImage:(UIImage *)selectedImage
                      text:(NSString *)text
                 textColor:(UIColor *)textColor
                      font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
