//
//  QHVCEditQualityView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeAction)(NSInteger type,float value);

@interface QHVCEditQualityView : UIView

@property (nonatomic,copy) ChangeAction changeCompletion;

@end
