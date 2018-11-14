//
//  UIViewAdditions.h
//


#import <UIKit/UIKit.h>

@interface UIView (Additions)

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;


@property (nonatomic, strong) NSLayoutConstraint *leftCon;
@property (nonatomic, strong) NSLayoutConstraint *rightCon;
@property (nonatomic, strong) NSLayoutConstraint *topCon;
@property (nonatomic, strong) NSLayoutConstraint *bottomCon;

@property (nonatomic, strong) NSLayoutConstraint *widthCon;
@property (nonatomic, strong) NSLayoutConstraint *heightCon;

- (CGFloat)contentConstraintHeight;

- (void)setCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
@end
