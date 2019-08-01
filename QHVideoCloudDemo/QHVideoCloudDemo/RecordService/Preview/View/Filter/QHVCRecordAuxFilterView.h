//
//  QHVCEditAuxFilterView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCRecordAuxFilterView : UIView

@property (nonatomic,copy) void(^filterAction)(NSDictionary *value);

@end
