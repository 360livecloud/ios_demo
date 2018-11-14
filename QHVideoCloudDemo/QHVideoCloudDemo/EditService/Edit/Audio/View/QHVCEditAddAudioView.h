//
//  QHVCEditAddAudioView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCEditCommandManager.h"

typedef void (^AudioSelectBlock)(QHVCEditAudioItem *audioItem);

@class QHVCEditAudioItem;

@interface QHVCEditAddAudioView : UIView

@property (nonatomic, strong) QHVCEditAudioItem *audioItem;
@property (nonatomic, copy) AudioSelectBlock audioSelectBlock;

@end
