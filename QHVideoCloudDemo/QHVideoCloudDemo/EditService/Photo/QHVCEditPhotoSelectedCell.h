//
//  QHVCEditPhotoSelectedCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCEditPhotoItem.h"

typedef void(^DeleteAction)(QHVCEditPhotoItem *);

@interface QHVCEditPhotoSelectedCell : UICollectionViewCell

@property (nonatomic,copy) DeleteAction deleteCompletion;

- (void)updateCell:(QHVCEditPhotoItem *)item;

@end
