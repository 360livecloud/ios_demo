//
//  QHVCEditCropRectControl.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/21.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditCropRectControl.h"

#define kFrameWidth  44.0f
#define kFrameHeight 44.0f

@interface QHVCEditCropRectControl ()

@property (nonatomic, assign) CGPoint translation;
@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation QHVCEditCropRectControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, kFrameWidth, kFrameHeight)];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint translationInView = [gestureRecognizer translationInView:self.superview];
        self.startPoint = CGPointMake(roundf(translationInView.x), translationInView.y);
        
        if ([self.delegate respondsToSelector:@selector(cropRectConrolViewDidBegin:)])
        {
            [self.delegate cropRectConrolViewDidBegin:self];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        self.translation = CGPointMake((roundf(self.startPoint.x + translation.x)),
                                       roundf(self.startPoint.y + translation.y));
        
        if ([self.delegate respondsToSelector:@selector(cropRectConrolViewValueChanged:)])
        {
            [self.delegate cropRectConrolViewValueChanged:self];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        if ([self.delegate respondsToSelector:@selector(cropRectConrolViewDidEnd:)])
        {
            [self.delegate cropRectConrolViewDidEnd:self];
        }
    }
}

@end
