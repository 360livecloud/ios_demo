//
//  QHVCToast.m
//  QHVideoCloudToolSetDebug
//
//  Created by deng on 2018/4/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCToast.h"
#import "UIView+Toast.h"

@implementation QHVCToast

+ (void)makeToast:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window makeToast:message];
    });
}

@end
