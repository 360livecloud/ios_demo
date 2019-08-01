//
//  QHVCEditGestureView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/7.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditGestureView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditGestureView ()
{
    BOOL _alreadyLayoutSubviews;
}

@end

@implementation QHVCEditGestureView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
    {
        return nil;
    }
    
    [self.layer setBorderWidth:1.0];
    [self.layer setBorderColor:[QHVCEditPrefs colorHighlight].CGColor];
    self.backgroundColor = [UIColor clearColor];
    self.rotateEnable = YES;
    self.moveEnable = YES;
    self.pinchEnable = YES;
    self.tapEnable = YES;
    [self addGesture];
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_alreadyLayoutSubviews)
    {
        [self prepareSubviews];
        _alreadyLayoutSubviews = YES;
    }
}

- (void)hideBorder:(BOOL)hidden
{
    UIColor* color = hidden ? [UIColor clearColor] : [QHVCEditPrefs colorHighlight];
    [self.layer setBorderColor:color.CGColor];
}

- (void)prepareSubviews
{
    //override
}

- (void)tapGestureAction
{
    //override
}

- (void)rotateGestureAction:(BOOL)isEnd
{
    //override
}

- (void)moveGestureAction:(BOOL)isEnd
{
    //override
}

- (void)pinchGestureAction:(BOOL)isEnd
{
    //override
}

- (void)addGesture
{
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGesture:)];
    [self addGestureRecognizer:rotateGesture];
    
    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
    [self addGestureRecognizer:moveGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)rotateGesture:(UIRotationGestureRecognizer *)recognizer
{
    if (!self.rotateEnable)
    {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        _radian += [recognizer rotation];
        [recognizer view].transform = CGAffineTransformRotate([[recognizer view] transform], [recognizer rotation]);
        [recognizer setRotation:0];
        [self rotateGestureAction:NO];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        [self rotateGestureAction:YES];
    }
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    if (!self.moveEnable)
    {
        return;
    }
    
    UIView *piece = [recognizer view];
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:[piece superview]];
        CGFloat halfx = self.frame.size.width/2 - self.moveExtentX;
        CGFloat halfy = CGRectGetHeight(self.frame)/2 - self.moveExtentY;
        CGFloat x = [piece center].x + translation.x;
        CGFloat y = [piece center].y + translation.y;
        
        if (translation.x < 0)
        {
            //left
            x = MAX(halfx, x);
        }
        else
        {
            //right
            x = MIN(self.superview.bounds.size.width - halfx, x);
        }
        
        if(translation.y < 0)
        {
            //up
            y = MAX(y, halfy);
        }
        else
        {
            //down
            y = MIN(y, self.superview.bounds.size.height - halfy);
        }
        
        [piece setCenter:CGPointMake(x, y)];
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
        [self moveGestureAction:NO];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        [self moveGestureAction:YES];
    }
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (!self.pinchEnable)
    {
        return;
    }
    
    UIView *piece = [recognizer view];
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGFloat newW = piece.frame.size.width * [recognizer scale];
        CGFloat newH = piece.frame.size.height * [recognizer scale];
        CGFloat superW = piece.superview.frame.size.width;
        CGFloat superH = piece.superview.frame.size.height;
        if (newW <= superW && newH <= superH)
        {
            [recognizer view].transform = CGAffineTransformScale([[recognizer view] transform], [recognizer scale], [recognizer scale]);
            [recognizer setScale:1];
        }
        
        [self pinchGestureAction:NO];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        [self pinchGestureAction:YES];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (!self.tapEnable)
    {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        [self tapGestureAction];
    }
}

//view尺寸转为画布尺寸
- (CGRect)rectToOutputRect:(CGSize)outputSize
{
    UIView* view = self;
    CGRect rect = view.frame;
    CGFloat radian = self.radian;
    
    view.transform = CGAffineTransformRotate(view.transform, -radian);
    rect = CGRectMake(rect.origin.x, rect.origin.y, view.frame.size.width, view.frame.size.height);
    view.transform = CGAffineTransformRotate(view.transform, radian);
    
    CGFloat scaleW = outputSize.width/CGRectGetWidth(self.superview.frame);
    CGFloat scaleH = outputSize.height/CGRectGetHeight(self.superview.frame);
    
    CGFloat x = (rect.origin.x + CGRectGetWidth(view.frame)/2.0) * scaleW;
    CGFloat y = (rect.origin.y + CGRectGetHeight(view.frame)/2.0) * scaleH;
    NSInteger w = rect.size.width * scaleW;
    NSInteger h = rect.size.height * scaleH;
    
    CGRect newRect = CGRectMake(x, y, w, h);
    return newRect;
}

@end
