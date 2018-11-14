//
//  QHVCEditViewController.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2017/8/15.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCEditBaseViewController.h"

@class QHVCEditPhotoItem;

typedef void(^DoneAction)(NSArray<QHVCEditPhotoItem *> *items);
typedef void(^FullAction)(NSInteger maxCount);

@interface QHVCEditViewController : QHVCEditBaseViewController

@property (nonatomic,   copy) DoneAction completion;
@property (nonatomic,   copy) FullAction fullAction;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, readonly, strong) NSMutableArray<QHVCEditPhotoItem *> *selectedLists;

@end
