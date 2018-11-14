//
//  QHVCEditTailorMainView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QHVCEditTailorType) {
    QHVCEditTailorTypeRestore = 0,
    QHVCEditTailorTypeRotate,
    QHVCEditTailorTypeFlipUpDown,
    QHVCEditTailorTypeFormat,
    QHVCEditTailorTypeFilpLeftRight,
    QHVCEditTailorTypeRate,
};

typedef void(^SelectedAction)(QHVCEditTailorType type);

@interface QHVCEditTailorMainView : UIView

@property (nonatomic,copy) SelectedAction selectedCompletion;

@end
