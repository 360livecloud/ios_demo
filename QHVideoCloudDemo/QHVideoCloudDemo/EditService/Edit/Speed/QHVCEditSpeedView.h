//
//  QHVCEditSpeedView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeAction)(float value);

@interface QHVCEditSpeedView : UIView

@property (nonatomic,copy) ChangeAction changeCompletion;

@end
