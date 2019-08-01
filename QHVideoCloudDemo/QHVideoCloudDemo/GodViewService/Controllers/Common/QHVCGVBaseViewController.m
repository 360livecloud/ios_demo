//
//  QHVCGVBaseViewController.m
//  QSCroupUI
//
//  Created by sunyimin on 2017/7/13.
//  Copyright © 2017年 北京奇虎科技有限公司. All rights reserved.
//

#import "QHVCGVBaseViewController.h"
#import "QHVCGVBarBtnView.h"
#import "QHVCGlobalConfig.h"

@interface QHVCGVBaseViewController () <UIGestureRecognizerDelegate>

@end

@implementation QHVCGVBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setupNaviBar];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        //防止重复赋值 导致侧滑失效
        if (![self.navigationController.interactivePopGestureRecognizer.delegate isKindOfClass:[QHVCGVBaseViewController class]]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = self;
        }
    }
    
}

- (void)setupNaviBar {
    if (kQHVCIPhoneXSerial) {
        [self.navigationController.navigationBar setBackgroundImage:kQHVCGetImageWithName(@"godview_navi_bg_iphonex") forBarMetrics:UIBarMetricsDefault];
    }
    else if (kQHVCIPhone6Plus) {
        [self.navigationController.navigationBar setBackgroundImage:kQHVCGetImageWithName(@"godview_navi_plus") forBarMetrics:UIBarMetricsDefault];
    }
    else {
        [self.navigationController.navigationBar setBackgroundImage:kQHVCGetImageWithName(@"godview_navi_bg") forBarMetrics:UIBarMetricsDefault];
    }
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    /** 设置导航栏字体、颜色 */
    NSDictionary *attri = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, kQHVCFontPingFangSCMedium(17), NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attri];
}

- (void)setupBackBarButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:kQHVCGetImageWithName(@"godview_icon_back") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButtonView:backButton];
}

- (void)setLeftBarButtonView:(UIView *)view
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        QHVCGVBarBtnView *barBtnView = [[QHVCGVBarBtnView alloc] initWithFrame:view.frame];
        [barBtnView setPosition:QHVCGVBarButtonViewPositionLeft];
        [barBtnView addSubview:view];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:barBtnView]];
    } else {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        [space setWidth:-18];
        
        [self.navigationItem setLeftBarButtonItems:@[space,[[UIBarButtonItem alloc] initWithCustomView:view]]];
    }
}

- (void)setRightBarButtonView:(UIView *)view
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        QHVCGVBarBtnView *barBtnView = [[QHVCGVBarBtnView alloc] initWithFrame:view.frame];
        [barBtnView setPosition:QHVCGVBarButtonViewPositionRight];
        [barBtnView addSubview:view];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:barBtnView]];
    } else {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
        [space setWidth:-18];
        [self.navigationItem setRightBarButtonItems:@[space,[[UIBarButtonItem alloc] initWithCustomView:view]]];
    }
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UIGestureRecognizerDelegate
/**
 * 子类若想关闭侧滑返回，复写此方法并返回NO
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
//        return self.navigationController.viewControllers.count > 1;
//    }
//    return YES;
    return NO;
}


@end
