//
//  QHVCEditReorderVC.h
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/26.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCPhotoItem.h"
#import "QHVCEditPlayerBaseVC.h"

@interface QHVCEditReorderVC : QHVCEditPlayerBaseVC

- (instancetype)initWithItems:(NSArray<QHVCPhotoItem *> *)items;

@end
