//
//  QHVCEditQualityItem.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/5/21.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QHVCEditQualityValueChanged)(int tag, float value);

@interface QHVCEditQualityItem : UICollectionViewCell

- (void)updateCell:(NSString *)name tag:(int)tag minValue:(int)min maxValue:(int)max;

@property (nonatomic, copy) QHVCEditQualityValueChanged valueChanged;

@end
