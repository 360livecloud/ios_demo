//
//  QHVCEditStickerIconView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditStickerIconView.h"
#import "UIViewAdditions.h"
#import "QHVCEditPrefs.h"
#import "UIImageView+AFNetworking.h"

@interface QHVCEditStickerIconView()
{
    UIButton *_delete;
    void* _userData;
}
@property (nonatomic, weak) UIView *menuView;

@end

@implementation QHVCEditStickerIconView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *borderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width - 2, self.width - 2)];
        borderView.backgroundColor = [UIColor clearColor];
        borderView.layer.borderWidth = 1.0;
        borderView.layer.borderColor = [QHVCEditPrefs colorHighlight].CGColor;
        [self addSubview:borderView];
        
        _sticker = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        [self addSubview:_sticker];
        
        _subtitle = [[UILabel alloc]initWithFrame: _sticker.bounds];
        _subtitle.backgroundColor = [UIColor clearColor];
        [_sticker addSubview:_subtitle];
        
        _delete = [[UIButton alloc]initWithFrame:CGRectMake(self.width - 18, -9, 18, 18)];
        [_delete setImage:[UIImage imageNamed:@"edit_selected_delete"] forState:UIControlStateNormal];
        [_delete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_delete];
        
        UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGesture:)];
        [self addGestureRecognizer:rotateGesture];
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
        [self addGestureRecognizer:longGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
        [self addGestureRecognizer:pinchGesture];
    }
    return self;
}

- (void)setStickerImageUrl:(NSString *)imageUrl
{
    [_sticker setImageWithURL:[NSURL URLWithString:imageUrl]];
}

- (void)setUserData:(void *)userData
{
    _userData = userData;
}

- (void *)userData
{
    return _userData;
}

- (void)delete:(UIButton *)sender
{
    [self removeFromSuperview];
    if (self.deleteCompletion) {
        self.deleteCompletion(self);
    }
}
-(void)longGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        [self becomeFirstResponder];
        self.menuView = [gestureRecognizer view];
        NSString *topTitle = @"置顶";
        UIMenuItem *top = [[UIMenuItem alloc] initWithTitle:topTitle action:@selector(topAction:)];

        NSString *bottomTitle = @"置底";
        UIMenuItem *bottom = [[UIMenuItem alloc] initWithTitle:bottomTitle action:@selector(bottomAction:)];
        
        NSString *fadeTitle = @"淡入淡出";
        UIMenuItem *fadeAction = [[UIMenuItem alloc] initWithTitle:fadeTitle action:@selector(fadeAction:)];
        
        NSString *moveTitle = @"滑入滑出";
        UIMenuItem *moveAction = [[UIMenuItem alloc] initWithTitle:moveTitle action:@selector(moveAction:)];
        
        NSString *jumpTitle = @"弹入弹出";
        UIMenuItem *jumpAction = [[UIMenuItem alloc] initWithTitle:jumpTitle action:@selector(jumpAction:)];
        
        NSString *rotateTitle = @"旋入旋出";
        UIMenuItem *rotateAction = [[UIMenuItem alloc] initWithTitle:rotateTitle action:@selector(rotateAction:)];

        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setMenuItems:@[top, bottom, fadeAction, moveAction, jumpAction, rotateAction]];
        [menuController update];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);
        [menuController setTargetRect:menuLocation inView:[gestureRecognizer view]];

        [menuController setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(topAction:)||
       action == @selector(bottomAction:)||
       action == @selector(fadeAction:)||
       action == @selector(moveAction:)||
       action == @selector(jumpAction:)||
       action == @selector(rotateAction:))
    {
        return YES;
    }
    return NO;
}

- (void)topAction:(UIMenuController *)controller
{
    [self.superview bringSubviewToFront:self];
}

- (void)bottomAction:(UIMenuController *)controller
{
    if (self.superview.subviews.count > 1) {
        [self.superview insertSubview:self atIndex:1];
    }
}

- (void)fadeAction:(UIMenuController *)controller
{
    //淡入淡出
    SAFE_BLOCK(self.fadeInOutAction, self);
}

- (void)moveAction:(UIMenuController *)controller
{
    //滑入滑出
    SAFE_BLOCK(self.moveInOutAction, self);
}

- (void)jumpAction:(UIMenuController *)controller
{
    //弹入弹出
    SAFE_BLOCK(self.jumpInOutAction, self);
}

- (void)rotateAction:(UIMenuController *)controller
{
    //旋入旋出
    SAFE_BLOCK(self.rotateInOutAction, self);
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    UIView *piece = [recognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:recognizer];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
        SAFE_BLOCK(self.moveAction, NO, self);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        CGPoint translation = [recognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
        SAFE_BLOCK(self.moveAction, YES, self);
    }
}

- (void)rotateGesture:(UIRotationGestureRecognizer *)recognizer
{
    [self adjustAnchorPointForGestureRecognizer:recognizer];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        [recognizer view].transform = CGAffineTransformRotate([[recognizer view] transform], [recognizer rotation]);
        _rotateAngle += [recognizer rotation];
        [recognizer setRotation:0];
        SAFE_BLOCK(self.rotateAction, NO, self);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        [recognizer view].transform = CGAffineTransformRotate([[recognizer view] transform], [recognizer rotation]);
        _rotateAngle += [recognizer rotation];
        [recognizer setRotation:0];
        SAFE_BLOCK(self.rotateAction, YES, self);
    }
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    [self adjustAnchorPointForGestureRecognizer:recognizer];
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
        [recognizer view].transform = CGAffineTransformScale([[recognizer view] transform], [recognizer scale], [recognizer scale]);
        [recognizer setScale:1];
        SAFE_BLOCK(self.pinchAction, NO, self);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        [recognizer view].transform = CGAffineTransformScale([[recognizer view] transform], [recognizer scale], [recognizer scale]);
        [recognizer setScale:1];
        SAFE_BLOCK(self.pinchAction, YES, self);
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@end
