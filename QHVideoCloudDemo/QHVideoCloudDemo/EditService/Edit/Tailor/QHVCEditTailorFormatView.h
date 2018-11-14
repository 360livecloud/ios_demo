//
//  QHVCEditTailorFormatView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FillAction)(NSInteger index);
typedef void(^ColorAction)(NSInteger index);

@interface QHVCEditTailorFormatView : UIView

@property (nonatomic,copy) FillAction fillSelectedCompletion;
@property (nonatomic,copy) ColorAction colorSelectedCompletion;

- (void)updateView:(NSArray *)fillArray colors:(NSArray *)colorsArray;

@end
