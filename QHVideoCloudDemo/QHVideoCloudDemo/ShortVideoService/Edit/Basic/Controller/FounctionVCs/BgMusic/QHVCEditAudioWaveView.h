//
//  QHVCEditAudioWaveView.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/13.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "EZAudioPlot.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCEditAudioWaveView : EZAudioPlot

- (void)updateWaveWithData:(void *)data size:(int)size;

@end

NS_ASSUME_NONNULL_END
