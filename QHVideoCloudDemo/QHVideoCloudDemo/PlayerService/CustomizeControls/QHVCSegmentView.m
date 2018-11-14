//
//  QHVCSegmentView.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/3.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCSegmentView.h"

@implementation QHVCSegmentView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initDefaults];
    }
    return self;
}

- (id)initWithSectionTitles:(NSArray *)sectionTitles
{
    if (self = [super initWithFrame:CGRectZero])
    {
        self.sectionTitles = sectionTitles;
        [self initDefaults];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.sectionTitles)
    {
        [self updateSegmentRects];
    }
    [self setNeedsDisplay];
}

//默认参数
- (void)initDefaults
{
    self.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
    self.textColor = [UIColor blueColor];
    self.selectedTextColor = [UIColor redColor];
    self.backgroundColor = [UIColor whiteColor];
    self.selectionIndicatorColor = [UIColor colorWithRed:52.0f/255.0f green:181.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    self.selectedIndex = 0;
    self.height = 60.0f;
    self.selectionIndicatorHeight = 5.0f;
    self.selectedSegmentLayer = [CALayer layer];
    self.selectionIndicatorMode = DDDSelectionIndicatorDown;
}

- (void)setSelectionIndicatorMode:(enum SelectionIndicatorMode)selectionIndicatorMode
{
    _selectionIndicatorMode = selectionIndicatorMode;
    if (self.selectionIndicatorMode == DDDSelectionIndicatorNone)
    {
        self.selectedSegmentLayer.hidden = YES;
    }
}

- (void)drawRect:(CGRect)rect
{
    [self.backgroundColor set];
    UIRectFill([self bounds]);
    [self.textColor set];
    [self.sectionTitles enumerateObjectsUsingBlock:^(id  _Nonnull titleString, NSUInteger idx,BOOL * _Nonnull stop) {
        CGSize fontSize = [titleString sizeWithAttributes:@{NSFontAttributeName:self.font}];
        CGFloat stringHeight = fontSize.height;
        CGFloat y = ((self.height - self.selectionIndicatorHeight) / 2) + (self.selectionIndicatorHeight - stringHeight /2);
        CGRect rect = CGRectMake(self.segmentWidth * idx, y, self.segmentWidth, stringHeight);
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByClipping];
        [style setAlignment:NSTextAlignmentCenter];
        NSDictionary *dis = [[NSDictionary alloc] initWithObjectsAndKeys:style,NSParagraphStyleAttributeName,self.font, NSFontAttributeName,self.textColor, NSForegroundColorAttributeName, nil];
        if (idx == _selectedIndex)
        {
            dis = [[NSDictionary alloc] initWithObjectsAndKeys:style,NSParagraphStyleAttributeName,self.font, NSFontAttributeName,self.selectedTextColor, NSForegroundColorAttributeName, nil];
        }
        
        [titleString drawInRect:rect withAttributes:dis];
        self.selectedSegmentLayer.frame = [self frameForSelectionIndicator];
        self.selectedSegmentLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
        [self.layer addSublayer:self.selectedSegmentLayer];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, touchLocation))
    {
        NSInteger segment = touchLocation.x / self.segmentWidth;
        if (segment != self.selectedIndex)
        {
            [self setSelectedIndex:segment animated:YES];
        }
    }
}

- (CGRect)frameForSelectionIndicator
{
    CGSize fontSize = [[self.sectionTitles objectAtIndex:self.selectedIndex] sizeWithAttributes:@{NSFontAttributeName:self.font}];
    CGFloat stringWidth = fontSize.width;
    CGFloat widthTillEndOfSelectedIndex = (self.segmentWidth * self.selectedIndex) + self.segmentWidth;
    CGFloat widthTillBeforeSelectedIndex = (self.segmentWidth * self.selectedIndex);
    
    CGFloat x = ((widthTillEndOfSelectedIndex - widthTillBeforeSelectedIndex) / 2) + (widthTillBeforeSelectedIndex - stringWidth /2);
    return CGRectMake(x, self.frame.size.height - self.selectionIndicatorHeight, stringWidth, self.selectionIndicatorHeight);
}

- (void)updateSegmentRects
{
    self.segmentWidth = self.frame.size.width / self.sectionTitles.count;
    self.height = self.frame.size.height;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    _selectedIndex = index;
    if (animated)
    {
        self.selectedSegmentLayer.actions = nil;
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.15f];
        [CATransaction setCompletionBlock:^{
            if (self.superview)
            {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            
            if (self.indexChangeBlock)
            {
                self.indexChangeBlock(index);
            }
        }];
        self.selectedSegmentLayer.frame = [self frameForSelectionIndicator];
        [CATransaction commit];
    } else
    {
        NSMutableDictionary *newsActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        self.selectedSegmentLayer.actions = newsActions;
        self.selectedSegmentLayer.frame = [self frameForSelectionIndicator];
        if (self.superview)
        {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        if (self.indexChangeBlock)
        {
            self.indexChangeBlock(index);
        }
    }
    [self setNeedsDisplay];
}

@end
