//
//  QHVCGVRTCVideoView.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/12/28.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGVRTCVideoView : UIView

@property (nonatomic,strong,readonly) NSString *talkId;

- (instancetype)initWithFrame:(CGRect)frame talkId:(NSString *)talkId;

@end

NS_ASSUME_NONNULL_END
