//
//  QHVCEditEffectView.h
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedAction)(NSInteger index);

@interface QHVCEditEffectView : UIView
@property (nonatomic, copy) SelectedAction selectedCompletion;
- (void)updateView:(NSArray<NSArray*> *)effectArray;
@end
