//
//  QHVCEditSpeedView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCRecordSpeedView : UIView

@property (nonatomic, strong) IBOutlet UISlider *speedSlider;
@property (nonatomic, copy) void(^speedAction)(float value);

@end
