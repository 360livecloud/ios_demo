//
//  QHVCEditTransferView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditSegmentItem;

typedef void(^AddAction)(void);
typedef void(^TransferAction)(void);

@interface QHVCEditTransferView : UIView

@property (nonatomic, copy) AddAction addCompletion;
@property (nonatomic, copy) TransferAction transferCompletion;

- (void)updateView:(NSArray<NSArray *> *)effects segments:(NSArray<QHVCEditSegmentItem *> *)segments;

@end
