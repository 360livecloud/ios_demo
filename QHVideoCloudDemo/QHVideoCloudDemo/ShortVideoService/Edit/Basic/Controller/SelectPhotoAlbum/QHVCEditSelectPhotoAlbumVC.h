//
//  QHVCEditSelectPhotoAlbumVC.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditBaseVC.h"

@class QHVCPhotoItem;

typedef void(^DoneAction)(NSArray<QHVCPhotoItem *> *items);
typedef void(^FullAction)(NSInteger maxCount);

@interface QHVCEditSelectPhotoAlbumVC : QHVCEditBaseVC

@property (nonatomic,   copy) DoneAction completion;
@property (nonatomic,   copy) FullAction fullAction;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, readonly, strong) NSMutableArray<QHVCPhotoItem *> *selectedLists;

@end
