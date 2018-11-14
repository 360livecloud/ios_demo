//
//  QHVCEditKenburnsView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/9/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QHVCEditKenburnsSelectComplete)(NSInteger index, CGFloat intensity);
@interface QHVCEditKenburnsView : UIView

@property (nonatomic,   copy) QHVCEditKenburnsSelectComplete selectComplete;

@end

NS_ASSUME_NONNULL_END
