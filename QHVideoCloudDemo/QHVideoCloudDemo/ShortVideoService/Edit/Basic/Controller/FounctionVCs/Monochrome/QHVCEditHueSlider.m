//
//  QHVCEditHueSlider.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditHueSlider.h"
#import "QHVCEditHueSliderBar.h"
#import "QHVCEditPrefs.h"

#define HUE_VIEW_BORDER 5
#define BAR_WIDTH 30

@interface QHVCEditHueSlider ()
@property (nonatomic, retain) QHVCEditHueSliderBar* bar;
@property (nonatomic, retain) UIView* line;
@end

@implementation QHVCEditHueSlider

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self createHueView];
    [self createBar];
}

- (void)createHueView
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(HUE_VIEW_BORDER, HUE_VIEW_BORDER,
                                                            self.frame.size.width - HUE_VIEW_BORDER*2,
                                                            self.frame.size.height - HUE_VIEW_BORDER*2)];
    CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    NSArray* colors = @[(id)[UIColor redColor].CGColor,
                        (id)[UIColor yellowColor].CGColor,
                        (id)[UIColor greenColor].CGColor,
                        (id)[UIColor cyanColor].CGColor,
                        (id)[UIColor blueColor].CGColor,
                        (id)[UIColor magentaColor].CGColor,
                        (id)[UIColor redColor].CGColor];
    [gradientLayer setColors:colors];
    [gradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
    [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
    [view.layer addSublayer:gradientLayer];
    [self addSubview:view];
}

- (void)createBar
{
    self.bar = [[QHVCEditHueSliderBar alloc] initWithFrame:CGRectMake((self.frame.size.width - BAR_WIDTH)/2.0,
                                                                     0,
                                                                     BAR_WIDTH,
                                                                     self.frame.size.height)];
    [self.bar hideBorder:YES];
    [self.bar setMoveExtentX:(BAR_WIDTH/2.0 - HUE_VIEW_BORDER)];
    [self addSubview:self.bar];
    
    self.line = [[UIView alloc] initWithFrame:CGRectMake((BAR_WIDTH - 1)/2.0, 0,
                                                            1, self.bar.frame.size.height)];
    [self.line setBackgroundColor:[UIColor whiteColor]];
    [self.bar addSubview:self.line];
    
    WEAK_SELF
    [self.bar setMoveAction:^{
        STRONG_SELF
        CGFloat progress = self.bar.frame.origin.x / (self.frame.size.width - HUE_VIEW_BORDER * 2);
        SAFE_BLOCK(self.valueChangedAction, progress);
    }];
}

@end
