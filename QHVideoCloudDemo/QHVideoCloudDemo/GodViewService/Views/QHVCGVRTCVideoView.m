//
//  QHVCGVRTCVideoView.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/12/28.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCGVRTCVideoView.h"
#import "UIViewAdditions.h"

@interface QHVCGVRTCVideoView()

@end

@implementation QHVCGVRTCVideoView

- (instancetype)initWithFrame:(CGRect)frame talkId:(NSString *)talkId
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor grayColor];

        _talkId = talkId;
        
        if (self.width < [UIScreen mainScreen].bounds.size.width &&
            self.height < [UIScreen mainScreen].bounds.size.height)
        {
            self.layer.borderColor = [UIColor blackColor].CGColor;
            self.layer.borderWidth = 1.0;
            [self createGesture];
        }
    }
    return self;
}

- (void)createGesture
{
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGesture:)];
    [self addGestureRecognizer:rotateGesture];
    
    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
    [self addGestureRecognizer:moveGesture];
    
    // 放大算法待调整（不应该无限放大） 暂时禁掉
//    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
//    [self addGestureRecognizer:pinchGesture];
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    UIView *piece = [recognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:recognizer];
    
    
    CGRect parentViewFrame = piece.superview.frame;
    CGAffineTransform transform = self.superview.transform;
    
    CGFloat parentViewWidth = CGRectGetWidth(parentViewFrame);
    CGFloat parentViewHeight = CGRectGetHeight(parentViewFrame);
    if (transform.b != 0) {
        parentViewWidth = CGRectGetHeight(parentViewFrame);
        parentViewHeight = CGRectGetWidth(parentViewFrame);
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:[piece superview]];
        CGFloat centerX = [piece center].x + translation.x;
        if (centerX < self.width/2) {
            centerX = self.width/2;
        }
        if (centerX > parentViewWidth - self.width/2) {
            centerX = parentViewWidth - self.width/2;
        }
        CGFloat centerY = [piece center].y + translation.y;
        if (centerY < self.height/2) {
            centerY = self.height/2;
        }
        
        if (centerY > parentViewHeight - self.height/2) {
            centerY = parentViewHeight - self.height/2;
        }
        [piece setCenter:CGPointMake(centerX, centerY)];
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

- (void)rotateGesture:(UIRotationGestureRecognizer *)recognizer
{
    [self adjustAnchorPointForGestureRecognizer:recognizer];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
        [recognizer view].transform = CGAffineTransformRotate([[recognizer view] transform], [recognizer rotation]);
        [recognizer setRotation:0];
    }
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    [self adjustAnchorPointForGestureRecognizer:recognizer];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
        [recognizer view].transform = CGAffineTransformScale([[recognizer view] transform], [recognizer scale], [recognizer scale]);
        [recognizer setScale:1];
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event  {
    if (self.superview.subviews.lastObject != self)
    {
        [self.superview bringSubviewToFront:self];
    }
}

@end
