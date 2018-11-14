//
//  QHVCEditMosaicView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/7/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QHVCEditMosaicValueChanged)(CGFloat value, BOOL isEnd);

@interface QHVCEditMosaicView : UIView

@property (nonatomic,   copy) QHVCEditMosaicValueChanged mosaicValueChangedBlock;

@end
