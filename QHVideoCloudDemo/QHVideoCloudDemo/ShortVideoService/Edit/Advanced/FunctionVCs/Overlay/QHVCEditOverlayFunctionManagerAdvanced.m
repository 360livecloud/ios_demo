//
//  QHVCEditOverlayFunctionManagerAdvanced.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/9.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditOverlayFunctionManagerAdvanced.h"
#import "QHVCEditOverlayBlendView.h"

@implementation QHVCEditOverlayFunctionManagerAdvanced

- (void)clickedBlendItem
{
    if (self.listView)
    {
        QHVCEditOverlayBlendView* view = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayBlendView class] description] owner:self options:nil][0];
        [view setItemView:self.itemView];
        [view setPlayerVC:self.playerVC];
        [self.listView addSubview:view];
    }
}

@end
