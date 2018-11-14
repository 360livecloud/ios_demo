//
//  QHVCEditBaseViewController.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCEditPrefs.h"
#import "UIViewAdditions.h"

@interface QHVCEditBaseViewController : UIViewController

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)backAction:(UIButton *)btn;
- (void)nextAction:(UIButton *)btn;

@end
