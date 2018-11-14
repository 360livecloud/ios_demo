//
//  QHVCEditAuxFilterView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedAction)(NSDictionary *value);

@interface QHVCEditAuxFilterView : UIView

@property (nonatomic, strong) NSArray<NSDictionary *> *filters;
@property (nonatomic,copy) SelectedAction selectedCompletion;

@end
