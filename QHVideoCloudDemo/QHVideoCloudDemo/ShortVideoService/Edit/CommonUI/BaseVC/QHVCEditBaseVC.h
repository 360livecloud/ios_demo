//
//  QHVCEditBaseVC.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCEditBaseVC : UIViewController

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView* topBarView;

- (void)prepareSubviews;

- (void)setTitle:(NSString *)title;
- (void)setNextBtnTitle:(NSString *)title;

- (void)backAction:(UIButton *)btn;
- (void)nextAction:(UIButton *)btn;

- (void)hideTopNav;
- (void)showTopNav;
- (CGFloat)topBarHeight;

@end
