//
//  QHVCShortVideoBaseVC.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/22.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCShortVideoBaseVC : UIViewController

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

