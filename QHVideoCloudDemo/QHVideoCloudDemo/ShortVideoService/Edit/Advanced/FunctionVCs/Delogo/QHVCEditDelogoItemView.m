//
//  QHVCEditDelogoItemView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/21.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditDelogoItemView.h"
#import "QHVCEditPrefs.h"

@implementation QHVCEditDelogoItemView

- (void)prepareSubviews
{
    [self setPinchEnable:NO];
    [self setRotateEnable:NO];
    [self setTapEnable:NO];
}

- (void)moveGestureAction:(BOOL)isEnd
{
    SAFE_BLOCK(self.refreshBlock, isEnd);
}

@end
