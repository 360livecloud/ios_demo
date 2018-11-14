//
//  QHVCSlider.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/7.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCSlider.h"

@implementation QHVCSlider
{
    UIView *_bgProgressView;
    UIView *_ableBufferProgressView;
    UIView *_finishPlayProgressView;
    CGPoint _lastPoint;
    UIButton *_sliderBtn;
    CGFloat sliderWidth;
}

- (instancetype)initWithFrame:(CGRect)frame trackImageLength:(CGFloat)length sliderHeight:(CGFloat)heigth
{
    _trackImageLength = length;
    _sliderHeight = heigth;
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        if (_trackImageLength <= 0)
        {
            _trackImageLength = 40;
        }
        if (_sliderHeight <= 0)
        {
            _sliderHeight = 1.0;
        }
        sliderWidth = self.frame.size.width - _trackImageLength;
        
        _minimumValue = 0.f;
        _maximumValue = 1.f;
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat showY = (self.frame.size.height - _sliderHeight)*0.5;
        
        _bgProgressView = [[UIView alloc] initWithFrame:CGRectMake(_trackImageLength/2, showY, sliderWidth, _sliderHeight)];
        _bgProgressView.backgroundColor = [UIColor grayColor];
        [self addSubview:_bgProgressView];
        
        _ableBufferProgressView = [[UIView alloc] initWithFrame:CGRectMake(_trackImageLength/2, showY, 0, _sliderHeight)];
        _ableBufferProgressView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_ableBufferProgressView];
        
        _finishPlayProgressView = [[UIView alloc] initWithFrame:CGRectMake(_trackImageLength/2, showY, 0, _sliderHeight)];
        _finishPlayProgressView.backgroundColor = [UIColor colorWithRed:103/255.0 green:154/255.0 blue:222/255.0 alpha:1.0];
        [self addSubview:_finishPlayProgressView];
        
        _sliderBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, showY, _trackImageLength, _trackImageLength)];
        
        CGPoint center = _sliderBtn.center;
        center.y = _finishPlayProgressView.center.y;
        _sliderBtn.center = center;
        [_sliderBtn addTarget:self action:@selector(beiginSliderScrubbing) forControlEvents:UIControlEventTouchDown];
        [_sliderBtn addTarget:self action:@selector(endSliderScrubbing) forControlEvents:UIControlEventTouchCancel];
        [_sliderBtn addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_sliderBtn addTarget:self action:@selector(endSliderScrubbing) forControlEvents:UIControlEventTouchUpInside];
        [_sliderBtn addTarget:self action:@selector(endSliderScrubbing) forControlEvents:UIControlEventTouchUpOutside];
        [_sliderBtn addTarget:self action:@selector(sliderScrubbing) forControlEvents:UIControlEventValueChanged];
        _lastPoint = _sliderBtn.center;
        [self addSubview:_sliderBtn];
    }
    
    return self;
}

- (void)setTrackImage:(UIImage *)trackImage
{
    _trackImage = trackImage;
    [_sliderBtn setImage:_trackImage forState:UIControlStateNormal];
    [_sliderBtn setImage:_trackImage forState:UIControlStateHighlighted];
    _sliderBtn.layer.masksToBounds = YES;
}

- (void)setPlayProgressBackgoundColor:(UIColor *)playProgressBackgoundColor
{
    if (_playProgressBackgoundColor != playProgressBackgoundColor)
    {
        _finishPlayProgressView.backgroundColor = playProgressBackgoundColor;
    }
}

- (void)setTrackBackgoundColor:(UIColor *)trackBackgoundColor
{
    if (_trackBackgoundColor != trackBackgoundColor)
    {
        _ableBufferProgressView.backgroundColor = trackBackgoundColor;
    }
}

- (void)setProgressBackgoundColor:(UIColor *)progressBackgoundColor
{
    if (_progressBackgoundColor != progressBackgoundColor)
    {
        _bgProgressView.backgroundColor = progressBackgoundColor;
    }
}

- (void)setValue:(CGFloat)progressValue
{
    _value = progressValue;
    CGFloat finishValue = _bgProgressView.frame.size.width * progressValue;
    CGPoint tempPoint = _sliderBtn.center;
    tempPoint.x =  _bgProgressView.frame.origin.x + finishValue;
    
    if (tempPoint.x >= _bgProgressView.frame.origin.x && tempPoint.x <= (self.frame.size.width - _trackImageLength/2))
    {
        _sliderBtn.center = tempPoint;
        _lastPoint = _sliderBtn.center;
        CGRect tempFrame = _finishPlayProgressView.frame;
        tempFrame.size.width = tempPoint.x - _trackImageLength/2;
        _finishPlayProgressView.frame = tempFrame;
    }
}

- (void)setTrackValue:(CGFloat)trackValue
{
    CGFloat finishValue = _bgProgressView.frame.size.width * trackValue;
    
    CGRect tempFrame = _ableBufferProgressView.frame;
    tempFrame.size.width = finishValue;
    _ableBufferProgressView.frame = tempFrame;
}

- (void)dragMoving:(UIButton *)btn withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self];
    CGFloat offsetX = point.x - _lastPoint.x;
    CGPoint tempPoint = CGPointMake(btn.center.x + offsetX, btn.center.y);
    CGFloat progressValue = (tempPoint.x - _bgProgressView.frame.origin.x)*1.0f/_bgProgressView.frame.size.width;
    [self setValue:progressValue];
    if (_delegate && [_delegate respondsToSelector:@selector(sliderScrubbing)])
    {
        [_delegate sliderScrubbing];
    }
}

- (void)beiginSliderScrubbing
{
    if (_delegate && [_delegate respondsToSelector:@selector(beiginSliderScrubbing)])
    {
        [_delegate beiginSliderScrubbing];
    }
}

- (void)endSliderScrubbing
{
    if (_delegate && [_delegate respondsToSelector:@selector(endSliderScrubbing)])
    {
        [_delegate endSliderScrubbing];
    }
}

- (void)sliderScrubbing
{
    if (_delegate && [_delegate respondsToSelector:@selector(sliderScrubbing)])
    {
        [_delegate sliderScrubbing];
    }
}

@end
