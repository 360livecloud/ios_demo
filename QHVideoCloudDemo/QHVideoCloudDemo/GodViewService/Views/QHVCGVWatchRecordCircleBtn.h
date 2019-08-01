//
//  QHVCGVWatchRecordCircleBtn.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/30.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVWatchRecordCircleBtn : UIButton

/**
 *
 * @param circleText 圆圈内的文字
 * @param funcText   描述功能的文字
 */
- (void)setupWithCircleText:(NSString *)circleText
               functionText:(NSString *)funcText;

- (void)updateCircleText:(NSString *)circleText;
- (void)updateFunctionText:(NSString *)funcText;
- (void)updateCircleText:(NSString *)circleText
            functionText:(NSString *)funcText;


@end

NS_ASSUME_NONNULL_END
