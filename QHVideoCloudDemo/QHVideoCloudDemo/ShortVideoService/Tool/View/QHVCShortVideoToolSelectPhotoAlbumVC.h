//
//  QHVCShortVideoToolSelectPhotoAlbumVC.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/23.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCShortVideoBaseVC.h"
#import "QHVCPhotoItem.h"

typedef void(^DoneAction)(NSArray<QHVCPhotoItem *> *items);
@interface QHVCShortVideoToolSelectPhotoAlbumVC : QHVCShortVideoBaseVC

@property (nonatomic,   copy) DoneAction completion;
@property (nonatomic, assign) NSInteger maxCount;

@end

