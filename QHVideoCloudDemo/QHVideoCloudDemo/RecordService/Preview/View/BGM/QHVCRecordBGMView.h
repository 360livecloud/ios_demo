//
//  QHVCRecordBGMView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/11/28.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecordBGMView : UIView

@property (nonatomic,copy) void(^playMusic)(NSDictionary *value);
@property (nonatomic,copy) void(^cutMusic)(int from,int to);
@property (nonatomic,copy) void(^loopMusic)(BOOL isLoop);
@property (nonatomic,copy) void(^volumeMusic)(int volume);
@property (nonatomic,copy) void(^confirmMusic)(NSDictionary *value);

@end

NS_ASSUME_NONNULL_END
