//
//  QHVCEditTrackClipView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/2.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTrackClipView.h"
#import "QHVCPhotoItem.h"
#import "UIViewAdditions.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditTrackClipItem.h"

#define kMinOffset 60

@interface  QHVCEditTrackClipView()
{
    UIView *_top;
    UIView *_bottom;
    UIView *_left;
    UIView *_right;
    UILabel *_startTime;
    UILabel *_endTime;
    
    UIView *_leftPanView;
    UIView *_rightPanView;
    
    UIView *_leftMaskView;
    UIView *_rightMaskView;
}
@property (nonatomic, strong) QHVCEditTrackClipItem *clipItem;

@end

@implementation QHVCEditTrackClipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _startTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, 40, 10)];
        _startTime.backgroundColor = [UIColor clearColor];
        _startTime.font = [UIFont systemFontOfSize:10.0];
        _startTime.textColor = [UIColor whiteColor];
        [self addSubview:_startTime];
        
        _endTime = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 40, _startTime.top, 40, 10)];
        _endTime.backgroundColor = [UIColor clearColor];
        _endTime.font = [UIFont systemFontOfSize:10.0];
        _endTime.textColor = [UIColor whiteColor];
        _endTime.textAlignment = NSTextAlignmentRight;
        [self addSubview:_endTime];
        
        _top = [[UIView alloc]initWithFrame:CGRectMake(0, _startTime.bottom , frame.size.width, 1)];
        _top.backgroundColor = [UIColor whiteColor];
        [self addSubview:_top];
        
        _bottom = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - 23, frame.size.width, 1)];
        _bottom.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bottom];
        
        _leftPanView = [[UIView alloc]initWithFrame:CGRectMake(0, _top.top, 30, frame.size.height)];
        _leftPanView.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftPanView];
        
        _left = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, _bottom.bottom)];
        _left.backgroundColor = [UIColor whiteColor];
        [_leftPanView addSubview:_left];
        
        _rightPanView = [[UIView alloc]initWithFrame:CGRectMake(self.width - 30, _top.top, 30, frame.size.height)];
        _rightPanView.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightPanView];
        
        _right = [[UIView alloc]initWithFrame:CGRectMake(_rightPanView.width - 1, 0, 1, _left.height)];
        _right.backgroundColor = [UIColor whiteColor];
        [_rightPanView addSubview:_right];
        
        UIPanGestureRecognizer *lPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(startPonit:)];
        [_leftPanView addGestureRecognizer:lPan];
        
        UIPanGestureRecognizer *rPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(endPoint:)];
        [_rightPanView addGestureRecognizer:rPan];
        
        _leftMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, _leftPanView.top, 0, frame.size.height - 23)];
        _leftMaskView.backgroundColor = [UIColor blackColor];
        _leftMaskView.alpha = 0.7;
        [self addSubview:_leftMaskView];
        
        _rightMaskView = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width, _leftPanView.top, 0, _leftMaskView.height)];
        _rightMaskView.backgroundColor = [UIColor blackColor];
        _rightMaskView.alpha = 0.7;
        [self addSubview:_rightMaskView];
        
    }
    
    return self;
}

- (void)startPonit:(UIPanGestureRecognizer *)recognizer
{
    if (self.width - _leftMaskView.right < kMinOffset || _rightMaskView.left - _leftMaskView.right < kMinOffset)
    {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateEnded)
    {
        UIView* piece = [recognizer view];
        CGPoint translation = [recognizer translationInView:[piece superview]];
        CGFloat offsetX = translation.x;
        CGFloat maskRight = MIN(_rightMaskView.left - kMinOffset, MAX(0, _leftMaskView.right + offsetX));
        CGFloat maskWidth =  maskRight;
        
        _top.width = _rightMaskView.left - maskWidth;
        _top.x = maskRight;
        _bottom.x = _top.x;
        _bottom.width = _top.width;
        _leftPanView.x = _top.x;
        _leftMaskView.width = maskWidth;
        _startTime.x = _top.x;
        NSTimeInterval start = maskRight * self.clipItem.durationMs / kScreenWidth;
        _startTime.text = [QHVCEditPrefs timeFormatMs:start];
        self.clipItem.startMs = start;
        
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

- (void)endPoint:(UIPanGestureRecognizer *)recognizer
{
    if (_rightMaskView.left < kMinOffset || _rightMaskView.left - _leftMaskView.right < kMinOffset)
    {
        return;
    }

    if ([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateEnded)
    {
        UIView* piece = [recognizer view];
        CGPoint translation = [recognizer translationInView:[piece superview]];
        CGFloat offsetX = translation.x;
        CGFloat maskLeft = MAX(kMinOffset, _rightMaskView.left + offsetX);
        maskLeft - _leftMaskView.right < kMinOffset ? maskLeft = _leftMaskView.right + kMinOffset : maskLeft;
        CGFloat maskWidth = self.width - maskLeft;
        
        _rightMaskView.left = maskLeft;
        _rightMaskView.width  = maskWidth;
        _top.width = _rightMaskView.left - _leftMaskView.right;
        _bottom.width = _top.width;
        _rightPanView.x = _rightMaskView.left - _rightPanView.width;
        _endTime.right = _rightPanView.right;
        
        NSTimeInterval end = maskLeft * self.clipItem.durationMs / kScreenWidth;
        _endTime.text = [QHVCEditPrefs timeFormatMs:end];
        self.clipItem.endMs = end;
        
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

- (void)updateUI:(QHVCEditTrackClipItem *)item
{
    self.clipItem = item;
    _startTime.text = [QHVCEditPrefs timeFormatMs:item.startMs];
    _endTime.text = [QHVCEditPrefs timeFormatMs:item.endMs];
    
    CGFloat pointx = item.startMs*self.width/item.durationMs;
    _top.x = pointx;
    _top.width = (item.endMs - item.startMs) * self.width / item.durationMs;
    _bottom.x = _top.x;
    _bottom.width = _top.width;
    _leftPanView.left = _top.left;
    _rightPanView.right = _top.right;
    _leftMaskView.width = _top.left;
    _rightMaskView.left = _rightPanView.right;
    _rightMaskView.width = self.width - _rightMaskView.left;
    _startTime.left = _top.x;
    _endTime.right = _top.right;
}

@end
