//
//  QHVCGVBaseNavigationController.m
//  QHShareCloud
//
//  Created by wangdacheng on 2017/12/11.
//  Copyright © 2017年 北京奇虎科技有限公司. All rights reserved.
//

#import "QHVCGVBaseNavigationController.h"

@interface QHVCGVBaseNavigationController()<UIGestureRecognizerDelegate>

@end

@implementation QHVCGVBaseNavigationController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initNavigationBarStyle];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self initNavigationBarStyle];
    }
    return self;
}

- (void)initNavigationBarStyle
{
//    self.navigationBar.barStyle = UIBarStyleDefault;
//    
//    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count==1) {
        viewController.hidesBottomBarWhenPushed = YES; //viewController是将要被push的控制器
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

#pragma mark -
- (UIViewController *)getLastViewController
{
    NSArray *controllers = self.viewControllers;
    if ([controllers count]) {
        return [controllers lastObject];
    }
    return nil;
}

#pragma mark - navigate
- (void)navigateBackToClass:(Class)c
{
    UIViewController *controller = nil;
    NSArray *controllers = self.viewControllers;
    for (UIViewController *con in controllers) {
        if ([con isKindOfClass:c]) {
            controller = con;
            break;
        }
    }
    if (controller) {
        [self.navigationController popToViewController:controller animated:YES];
    }
}

@end
