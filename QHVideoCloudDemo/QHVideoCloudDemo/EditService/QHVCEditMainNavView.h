//
//  QHVCEditMainNavView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedAction)(NSInteger index);

@interface QHVCEditMainNavView : UIView

@property (nonatomic, copy) SelectedAction selectedCompletion;

- (void)updateView:(NSArray<NSArray*> *)functions;

@end
