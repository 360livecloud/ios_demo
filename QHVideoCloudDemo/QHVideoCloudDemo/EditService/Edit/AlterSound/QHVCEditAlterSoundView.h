//
//  QHVCEditAlterSoundView.h
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/5/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangePitchAction)(int pitch);
typedef void(^ChangeVolumeAction)(int volume);
typedef void(^ChangeFIAction)(BOOL isOn);
typedef void(^ChangeFOAction)(BOOL isOn);

typedef void(^CloseViewAction)();

@interface QHVCEditAlterSoundView : UIView

@property (nonatomic, copy) ChangePitchAction changePitchAction;
@property (nonatomic, copy) ChangeVolumeAction changeVolumeAction;
@property (nonatomic, copy) ChangeFIAction changeFIAction;
@property (nonatomic, copy) ChangeFOAction changeFOAction;
@property (nonatomic, copy) CloseViewAction onViewClose;

@end
