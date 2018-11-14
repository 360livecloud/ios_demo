//
//  QHVCSegmentView.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/3.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

//下划线位置
enum SelectionIndicatorMode
{
    DDDSelectionIndicatorNone = 1,
    DDDSelectionIndicatorUp   = 2,
    DDDSelectionIndicatorDown = 3
};

@interface QHVCSegmentView : UIControl

@property (strong, nonatomic)    NSArray *sectionTitles;
@property (strong, nonatomic)    UIFont  *font;
@property (strong, nonatomic)    UIColor *textColor;
@property (strong, nonatomic)    UIColor *selectedTextColor;
@property (strong, nonatomic)    UIColor *selectionIndicatorColor;//下划线颜色
@property (nonatomic, readwrite) CGFloat height;//segment高
@property (nonatomic, readwrite) CGFloat selectionIndicatorHeight;//下划线高
@property (strong, nonatomic)    UIColor *backgroundColor;
@property (assign, nonatomic)    NSInteger selectedIndex;
@property (nonatomic, readwrite) UIEdgeInsets segmentEdgeInset;
@property (nonatomic, strong)    CALayer *selectedSegmentLayer;
@property (nonatomic, readwrite) CGFloat segmentWidth;
@property (nonatomic, copy)      void(^indexChangeBlock)(NSUInteger index);
@property (assign, nonatomic)    enum SelectionIndicatorMode selectionIndicatorMode;

- (id)initWithSectionTitles:(NSArray *)sectionTitles;

@end
