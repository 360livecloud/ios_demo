//
//  QHVCEditOverlayVolumeView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeVolumeAction)(NSInteger volume);
@interface QHVCEditOverlayVolumeView : UIView

- (void)setVolume:(NSInteger)volume;
@property (nonatomic, copy) ChangeVolumeAction changeVolumeAction;

@end
