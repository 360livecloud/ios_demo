//
//  QHVCSlider.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/7.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QHVCSliderDelegate <NSObject>

- (void)beiginSliderScrubbing;
- (void)endSliderScrubbing;
- (void)sliderScrubbing;

@end

@interface QHVCSlider : UIView

@property (nonatomic, weak) id<QHVCSliderDelegate> delegate;

@property (nonatomic, strong) UIImage *trackImage;
@property (nonatomic, assign, readonly) CGFloat minimumValue;
@property (nonatomic, assign, readonly) CGFloat maximumValue;

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat trackValue;

@property (nonatomic, strong) UIColor *playProgressBackgoundColor;
@property (nonatomic, strong) UIColor *trackBackgoundColor;
@property (nonatomic, strong) UIColor *progressBackgoundColor;

@property (nonatomic, assign) CGFloat trackImageLength;
@property (nonatomic, assign) CGFloat sliderHeight;

- (instancetype)initWithFrame:(CGRect)frame trackImageLength:(CGFloat)length sliderHeight:(CGFloat)heigth;

@end
