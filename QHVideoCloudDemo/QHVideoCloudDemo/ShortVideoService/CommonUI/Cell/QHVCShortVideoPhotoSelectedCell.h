//
//  QHVCShortVideoPhotoSelectedCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCPhotoItem.h"

typedef void(^DeleteAction)(QHVCPhotoItem* item);

@interface QHVCShortVideoPhotoSelectedCell : UICollectionViewCell

@property (nonatomic,copy) DeleteAction deleteCompletion;

- (void)updateCell:(QHVCPhotoItem *)item;

@end
