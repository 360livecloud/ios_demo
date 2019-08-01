//
//  QHVCEditOverlayFunctionsView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditFunctionBaseView.h"
#import "QHVCEditOverlayItemView.h"

@interface QHVCEditOverlayFunctionsView : QHVCEditFunctionBaseView

@property (nonatomic, retain) QHVCEditOverlayItemView* clipItemView;

//override
- (void)overlayFunctionDidSelected:(NSInteger)index;

@end
