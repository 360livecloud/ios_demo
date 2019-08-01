//
//  QHVCGVFunctionBtn.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVFunctionBtn.h"
#import "QHVCGVDefine.h"
#import "QHVCGlobalConfig.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

#define kQHVCGVFunctionBtnText_H               (16.5 * kQHVCScreenScaleTo6)
#define kQHVCGVFunctionBtnIcon_MarginBottom    (5.5 * kQHVCScreenScaleTo6)

@interface QHVCGVFunctionBtn ()
@property (nonatomic,strong) UIImage *normalImage;
@property (nonatomic,strong) UIImage *selectedImage;
@end

@implementation QHVCGVFunctionBtn
{
    UIImageView *ivIcon;
}

/**
 * @param iconImage 按钮icon
 * @param text      icon下方文字说明
 */
- (void)setupWithIconImage:(UIImage *)iconImage text:(NSString *)text {
    [self setupWithIconImage:iconImage text:text textColor:[QHVCToolUtils colorWithHexString:@"4D4D4D"]];
}

/**
 * @param iconImage 按钮icon
 * @param text      icon下方文字说明
 * @param textColor 文字颜色
 */
- (void)setupWithIconImage:(UIImage *)iconImage
                      text:(NSString *)text
                 textColor:(UIColor *)textColor {
    [self setupWithIconImage:iconImage text:text textColor:textColor font:kQHVCFontPingFangHKRegular(12)];
}

/**
 * @param iconImage 按钮icon
 * @param text      icon下方文字说明
 * @param textColor 文字颜色
 * @param font      字体
 */
- (void)setupWithIconImage:(UIImage *)iconImage
                      text:(NSString *)text
                 textColor:(UIColor *)textColor
                      font:(UIFont *)font {
    [self setupWithIconImage:iconImage selectedImage:nil text:text textColor:textColor font:font];
}


/**
 * @param iconImage 按钮icon
 * @param selectedImage 按钮选中效果的图片
 * @param text      icon下方文字说明
 * @param textColor 文字颜色
 * @param font      字体
 */
- (void)setupWithIconImage:(UIImage *)iconImage
             selectedImage:(UIImage * )selectedImage
                      text:(NSString *)text
                 textColor:(UIColor *)textColor
                      font:(UIFont *)font {
    if (self.superview == nil) {
        NSAssert(false, @"请先添加到父视图上，再调用本方法");
    }
    self.normalImage = iconImage;
    self.selectedImage = selectedImage;
    
    // 文本说明
    UILabel *labText = [UILabel new];
    labText.text = text;
    labText.font = font;
    labText.textColor = textColor;
    labText.textAlignment = NSTextAlignmentCenter;
    [self addSubview:labText];
    [labText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(self);
        make.height.equalTo(@(kQHVCGVFunctionBtnText_H));
    }];
    
    // icon
    ivIcon = [UIImageView new];
    ivIcon.image = iconImage;
    [self addSubview:ivIcon];
    CGSize sizeIcon = iconImage.size;
    [ivIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(sizeIcon.width));
        make.height.equalTo(@(sizeIcon.height));
        make.centerX.equalTo(self);
        make.bottom.equalTo(labText.mas_top).offset(-kQHVCGVFunctionBtnIcon_MarginBottom);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    ivIcon.image = self.normalImage;
    if (selected && self.selectedImage) {
        ivIcon.image = self.selectedImage;
    }
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    self.alpha = enabled ? 1 : 0.6;
}

@end
