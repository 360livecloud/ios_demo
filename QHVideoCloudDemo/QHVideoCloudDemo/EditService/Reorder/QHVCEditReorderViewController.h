//
//  QHVCEditReorderViewController.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCEditPhotoItem.h"
#import "QHVCEditPlayerViewController.h"

@interface QHVCEditReorderViewController : QHVCEditPlayerViewController

@property (nonatomic, strong) NSMutableArray<QHVCEditPhotoItem *> *resourceArray;

@end
