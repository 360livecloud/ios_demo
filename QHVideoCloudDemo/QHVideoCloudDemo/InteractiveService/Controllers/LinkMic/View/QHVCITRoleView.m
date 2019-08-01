//
//  QHVCITGuestView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITRoleView.h"
#import "UIViewAdditions.h"
#import "QHVCGlobalConfig.h"
#import "QHVCITSUserSystem.h"

@interface QHVCITRoleView()
{
    UILabel *_titleLabel;
}
@end

@implementation QHVCITRoleView

- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor grayColor];
        _userId = userId;
        
        _preview = [[UIView alloc]initWithFrame:self.bounds];
        [self addSubview:_preview];
        
        if ([QHVCITSUserSystem sharedInstance].roomInfo.roomType == QHVCITS_Room_Type_Party) {
            [self createTitleLabel];
            return self;
        }
        if (self.width < [UIScreen mainScreen].bounds.size.width &&
            self.height < [UIScreen mainScreen].bounds.size.height)
        {
            self.layer.borderColor = [UIColor blackColor].CGColor;
            self.layer.borderWidth = 1.0;
            
            [self createTitleLabel];
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
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
}

- (void)createTitleLabel
{
    _titleLabel = [[UILabel alloc]initWithFrame: CGRectMake(0, self.height - 20, self.width, 20)];
    _titleLabel.backgroundColor = [UIColor blackColor];
    _titleLabel.text = _userId;
    _titleLabel.font = [UIFont systemFontOfSize:11.0];
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    UIView *piece = [recognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:recognizer];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:[piece superview]];
        CGFloat centerX = [piece center].x + translation.x;
        if (centerX < self.width/2) {
            centerX = self.width/2;
        }
        if (centerX > kScreenWidth) {
            centerX = kScreenWidth;
        }
        CGFloat centerY = [piece center].y + translation.y;
        if (centerY < self.height/2) {
            centerY = self.height/2;
        }
        if (centerY > kScreenHeight - self.height) {
            centerY = kScreenHeight - self.height;
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

@end
