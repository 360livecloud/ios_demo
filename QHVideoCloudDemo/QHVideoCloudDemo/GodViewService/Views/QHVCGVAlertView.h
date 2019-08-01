//
//  QHVCGVAlertView.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/11/13.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVAlertView : UIView
+ (instancetype)alertWithMsg:(NSString *)msg icon:(UIImage *)icon clickHandler:(void(^)(NSInteger index))handler;
- (void)showInView:(UIView *)parentView;
@end

NS_ASSUME_NONNULL_END
