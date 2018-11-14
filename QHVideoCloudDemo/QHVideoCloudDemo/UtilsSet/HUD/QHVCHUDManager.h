//
//  QHVCHUDManager.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/6.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface QHVCHUDManager : NSObject

- (void)showLoadingProgressOnView:(UIView *)view message:(NSString *)message;

- (void)showTextOnlyAlertViewOnView:(UIView *)view message:(NSString *)message hideFlag:(BOOL)hideFlag;
- (void)showTextOnlyAlertViewOnWindow:(NSString *)message hideFlag:(BOOL)hideFlag;
- (void)hideHud;

@end
