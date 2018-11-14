//
//  QHVCEditTailorRateVC.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QHVCEditRateType) {
    QHVCEditRateTypeOneOne = 1,
    QHVCEditRateTypeFourThree,
};

typedef void(^RateAction)(QHVCEditRateType type);

@interface QHVCEditTailorRateVC : UIViewController

@property (nonatomic,copy) RateAction selectedCompletion;

@end
