//
//  QHVCEditSegmentCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSInteger, QHVCEditTransferType) {
//    QHVCEditTransferTypeNone = 0,
//    QHVCEditTransferTypeDissolution,     //溶解
//    QHVCEditTransferTypeAperture,        //光圈
//    QHVCEditTransferTypeSwipeToRight,    //向右轻擦
//    QHVCEditTransferTypeSwipeToLeft,     //向左轻擦
//    QHVCEditTransferTypeSwipeToTop,      //向上轻擦
//    QHVCEditTransferTypeSwipeToBottom,   //向下轻擦
//    QHVCEditTransferTypeMoveToRight,     //向右滑动
//    QHVCEditTransferTypeMoveToLeft,      //向左滑动
//    QHVCEditTransferTypeMoveToTop,       //向上滑动
//    QHVCEditTransferTypeMoveToBottom,    //向下滑动
//    QHVCEditTransferTypeFade,            //淡化
//    QHVCEditTransferTypeAdd,
//};

@class QHVCEditSegmentItem;

typedef void(^SelectedAction)(QHVCEditSegmentItem *item);

@interface QHVCEditSegmentCell : UICollectionViewCell

@property (nonatomic, copy) SelectedAction selectedCompletion;

- (void)updateCell:(QHVCEditSegmentItem *)item isHighlight:(BOOL)isHighlight;

@end
