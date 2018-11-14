//
//  QHVCEditCropRectView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/21.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditCropRectView.h"
#import "QHVCEditCropRectControl.h"

#define kMinWidth 50
#define kMaxWidth 50

@interface QHVCEditCropRectView () <QHVCEditCropRectControlDelegate>

@property (nonatomic, retain) QHVCEditCropRectControl* topLeftCornerView;
@property (nonatomic, retain) QHVCEditCropRectControl* topRightCornerView;
@property (nonatomic, retain) QHVCEditCropRectControl* bottomLeftCornerView;
@property (nonatomic, retain) QHVCEditCropRectControl* bottomRightCornerView;
@property (nonatomic, retain) QHVCEditCropRectControl* topEdgeView;
@property (nonatomic, retain) QHVCEditCropRectControl* leftEdgeView;
@property (nonatomic, retain) QHVCEditCropRectControl* bottomEdgeView;
@property (nonatomic, retain) QHVCEditCropRectControl* rightEdgeView;
@property (nonatomic, assign) CGRect initialRect;
@property (nonatomic, assign) BOOL isResizing;

@end

@implementation QHVCEditCropRectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
    {
        return nil;
    }
    
    [self initSubviews];
    return self;
}

- (void)setShowGridMajor:(BOOL)showGridMajor
{
    _showGridMajor = showGridMajor;
    [self setNeedsDisplay];
}

- (void)setShowGridMinor:(BOOL)showGridMinor
{
    _showGridMinor = showGridMinor;
    [self setNeedsDisplay];
}

#pragma mark - Layout

- (void)initSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    self.showGridMajor = YES;
    self.showGridMinor = NO;
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, -2.0f, -2.0f)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.image = [[UIImage imageNamed:@"edit_crop_corner"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.0f, 23.0f, 23.0f, 23.0f)];
    [self addSubview:imageView];
    
    self.topLeftCornerView = [self createCropRectConrol];
    self.topRightCornerView = [self createCropRectConrol];
    self.bottomLeftCornerView = [self createCropRectConrol];
    self.bottomRightCornerView = [self createCropRectConrol];
    self.topEdgeView = [self createCropRectConrol];
    self.leftEdgeView = [self createCropRectConrol];
    self.rightEdgeView = [self createCropRectConrol];
    self.bottomEdgeView = [self createCropRectConrol];
}

- (QHVCEditCropRectControl *)createCropRectConrol
{
    QHVCEditCropRectControl* control = [[QHVCEditCropRectControl alloc] init];
    [control setDelegate:self];
    [self addSubview:control];
    return control;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    for (NSInteger i = 0; i < 3; i++)
    {
        if (self.showGridMinor)
        {
            for (NSInteger j = 1; j < 3; j++)
            {
                [[UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.3f] set];
                UIRectFill(CGRectMake(roundf(width / 3 / 3 * j + width / 3 * i), 0.0f, 0.2f, roundf(height)));
                UIRectFill(CGRectMake(0.0f, roundf(height / 3 / 3 * j + height / 3 * i), roundf(width), 0.2f));
            }
        }
        
        if (self.showGridMajor)
        {
            if (i > 0)
            {
                [[UIColor whiteColor] set];
                UIRectFill(CGRectMake(roundf(width / 3 * i), 0.0f, 0.2f, roundf(height)));
                UIRectFill(CGRectMake(0.0f, roundf(height / 3 * i), roundf(width), 0.2f));
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topLeftCornerView.frame = CGRectMake(CGRectGetWidth(self.topLeftCornerView.bounds)/-2,
                                              CGRectGetHeight(self.topLeftCornerView.bounds)/-2,
                                              CGRectGetWidth(self.topLeftCornerView.bounds),
                                              CGRectGetHeight(self.topLeftCornerView.bounds));
    
    self.topRightCornerView.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.topRightCornerView.bounds)/2,
                                               CGRectGetHeight(self.topRightCornerView.bounds)/-2,
                                               CGRectGetWidth(self.topRightCornerView.bounds),
                                               CGRectGetHeight(self.topRightCornerView.bounds));
    
    self.bottomLeftCornerView.frame = CGRectMake(CGRectGetWidth(self.bottomLeftCornerView.bounds)/-2,
                                                 CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomLeftCornerView.bounds)/2,
                                                 CGRectGetWidth(self.bottomLeftCornerView.bounds),
                                                 CGRectGetHeight(self.bottomLeftCornerView.bounds));
    
    self.bottomRightCornerView.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.bottomRightCornerView.bounds)/2,
                                                  CGRectGetHeight(self.bounds) - CGRectGetHeight(self.bottomRightCornerView.bounds)/2,
                                                  CGRectGetWidth(self.bottomRightCornerView.bounds),
                                                  CGRectGetHeight(self.bottomRightCornerView.bounds));
    
    self.topEdgeView.frame = CGRectMake(CGRectGetMaxX(self.topLeftCornerView.frame),
                                        CGRectGetHeight(self.topEdgeView.frame)/-2,
                                        CGRectGetMinX(self.topRightCornerView.frame) - CGRectGetMaxX(self.topLeftCornerView.frame),
                                        CGRectGetHeight(self.topEdgeView.bounds));
    
    self.leftEdgeView.frame = CGRectMake(CGRectGetWidth(self.leftEdgeView.frame)/-2,
                                         CGRectGetMaxY(self.topLeftCornerView.frame),
                                         CGRectGetWidth(self.leftEdgeView.bounds),
                                         CGRectGetMinY(self.bottomLeftCornerView.frame) - CGRectGetMaxY(self.topLeftCornerView.frame));
    
    self.bottomEdgeView.frame = CGRectMake(CGRectGetMaxX(self.bottomLeftCornerView.frame),
                                           CGRectGetMinY(self.bottomLeftCornerView.frame),
                                           CGRectGetMinX(self.bottomRightCornerView.frame) - CGRectGetMaxX(self.bottomLeftCornerView.frame),
                                           CGRectGetHeight(self.bottomEdgeView.bounds));
    
    self.rightEdgeView.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rightEdgeView.bounds)/2,
                                          CGRectGetMaxY(self.topRightCornerView.frame),
                                          CGRectGetWidth(self.rightEdgeView.bounds),
                                          CGRectGetMinY(self.bottomRightCornerView.frame) - CGRectGetMaxY(self.topRightCornerView.frame));
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *subviews = self.subviews;
    for (UIView *subview in subviews)
    {
        if ([subview isKindOfClass:[QHVCEditCropRectControl class]])
        {
            if (CGRectContainsPoint(subview.frame, point))
            {
                return subview;
            }
        }
    }
    
    return nil;
}

#pragma mark - Control Delegate

- (void)cropRectConrolViewDidBegin:(QHVCEditCropRectControl *)cropRectConrolView
{
    self.isResizing = YES;
    self.initialRect = self.frame;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cropRectViewDidBeginEditing:)])
    {
        [self.delegate cropRectViewDidBeginEditing:self];
    }
}

- (void)cropRectConrolViewValueChanged:(QHVCEditCropRectControl *)cropRectConrolView
{
    self.frame = [self resizeWithControlView:cropRectConrolView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cropRectViewEditingChanged:)])
    {
        [self.delegate cropRectViewEditingChanged:self];
    }
}

- (void)cropRectConrolViewDidEnd:(QHVCEditCropRectControl *)cropRectConrolView
{
    self.isResizing = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cropRectViewDidEndEditing:)])
    {
        [self.delegate cropRectViewDidEndEditing:self];
    }
}

- (CGRect)resizeWithControlView:(QHVCEditCropRectControl *)controlView
{
    CGRect rect = self.frame;
    
    if (controlView == self.topEdgeView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + controlView.translation.y,
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) - controlView.translation.y);
    }
    else if (controlView == self.leftEdgeView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + controlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - controlView.translation.x,
                          CGRectGetHeight(self.initialRect));
    }
    else if (controlView == self.bottomEdgeView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect),
                          CGRectGetHeight(self.initialRect) + controlView.translation.y);
    }
    else if (controlView == self.rightEdgeView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + controlView.translation.x,
                          CGRectGetHeight(self.initialRect));
    }
    else if (controlView == self.topLeftCornerView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + controlView.translation.x,
                          CGRectGetMinY(self.initialRect) + controlView.translation.y,
                          CGRectGetWidth(self.initialRect) - controlView.translation.x,
                          CGRectGetHeight(self.initialRect) - controlView.translation.y);
    }
    else if (controlView == self.topRightCornerView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect) + controlView.translation.y,
                          CGRectGetWidth(self.initialRect) + controlView.translation.x,
                          CGRectGetHeight(self.initialRect) - controlView.translation.y);
    }
    else if (controlView == self.bottomLeftCornerView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect) + controlView.translation.x,
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) - controlView.translation.x,
                          CGRectGetHeight(self.initialRect) + controlView.translation.y);
    }
    else if (controlView == self.bottomRightCornerView)
    {
        rect = CGRectMake(CGRectGetMinX(self.initialRect),
                          CGRectGetMinY(self.initialRect),
                          CGRectGetWidth(self.initialRect) + controlView.translation.x,
                          CGRectGetHeight(self.initialRect) + controlView.translation.y);
    }
    
    CGFloat minWidth = kMinWidth;
    if (CGRectGetWidth(rect) < minWidth)
    {
        rect.origin.x = CGRectGetMaxX(self.frame) - minWidth;
        rect.size.width = minWidth;
    }
    
    CGFloat minHeight = kMaxWidth;
    if (CGRectGetHeight(rect) < minHeight)
    {
        rect.origin.y = CGRectGetMaxY(self.frame) - minHeight;
        rect.size.height = minHeight;
    }
    
    CGFloat maxWidth = CGRectGetWidth(self.superview.bounds);
    if (CGRectGetWidth(rect) > maxWidth)
    {
        rect.origin.x = CGRectGetMaxX(self.frame) - maxWidth;
        rect.size.width = maxWidth;
    }
    
    CGFloat maxHeight = CGRectGetHeight(self.superview.bounds);
    if (CGRectGetHeight(rect) > maxHeight)
    {
        rect.origin.y = CGRectGetMaxY(self.frame) - maxHeight;
        rect.size.height = maxHeight;
    }
    
    CGFloat minX = CGRectGetMinX(self.superview.bounds);
    if (CGRectGetMinX(rect) < minX)
    {
        rect.origin.x = minX;
    }
    
    CGFloat maxX = CGRectGetMaxX(self.superview.bounds);
    if (CGRectGetMaxX(rect) > maxX)
    {
        rect.size.width = maxX - rect.origin.x;
    }
    
    CGFloat minY = CGRectGetMinY(self.superview.bounds);
    if (CGRectGetMinY(rect) < minY)
    {
        rect.origin.y = minY;
    }
    
    CGFloat maxY = CGRectGetMaxY(self.superview.bounds);
    if (CGRectGetMaxY(rect) > maxY)
    {
        rect.size.height = maxY - rect.origin.y;
    }
    
    return rect;
}

@end
