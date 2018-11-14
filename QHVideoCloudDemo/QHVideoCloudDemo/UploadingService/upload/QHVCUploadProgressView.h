//
//  QHVCUploadProgressView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/9/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCUploadProgressView : UIView

@property (nonatomic,copy) void(^onCancelBlock)();

- (void)updateProgress:(float)progress;

@end
