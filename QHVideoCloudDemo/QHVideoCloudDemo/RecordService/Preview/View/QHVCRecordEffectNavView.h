//
//  QHVCRecordEffectNavView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/11/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectedAction)(NSInteger index);

@interface QHVCRecordEffectNavView : UIView

@property (nonatomic,copy) SelectedAction selectedCompletion;

@end

NS_ASSUME_NONNULL_END
