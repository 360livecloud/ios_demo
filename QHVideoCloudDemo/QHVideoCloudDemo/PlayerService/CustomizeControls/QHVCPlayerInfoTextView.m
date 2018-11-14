//
//  QHVCPlayerInfoTextField.m
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/11.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPlayerInfoTextView.h"

@implementation QHVCPlayerInfoTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:) || action == @selector(selectAll:))
    {
        return YES;
    }
    return NO;
}

@end
