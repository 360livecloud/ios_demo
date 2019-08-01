//
//  QHVCGVVideoRatioButton.m
//  QHVideoCloudToolSetDebug
//
//  Created by jiangbingbing on 2018/10/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVVideoRatioButton.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@interface QHVCGVVideoRatioButton ()

@property (nonatomic,strong) NSArray<NSString *> *videoRatios;
@property (nonatomic,assign) NSUInteger count;
@end

@implementation QHVCGVVideoRatioButton

- (void)setupWithVideoRatios:(NSArray<NSString *> *)videoRatios {
    [self addTarget:self action:@selector(skipToNext) forControlEvents:UIControlEventTouchUpInside];
    _count = 2;
    [self setupWithCircleText:[self titleWithVideoRatio:videoRatios[_count]] functionText:@"倍率播放"];
    self.videoRatios = videoRatios;
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    self.alpha = enabled ? 1 : 0.6;
}

- (void)skipToNext {
    if (_videoRatios.count == 0) {
        return;
    }
    NSString *videoRatio = _videoRatios[++self.count % _videoRatios.count];
    [self updateCircleText:[self titleWithVideoRatio:videoRatio]];
    if ([self.delegate respondsToSelector:@selector(videoRatioButtonDidSelectVideoRatio:)]) {
        [self.delegate videoRatioButtonDidSelectVideoRatio:videoRatio];
    }
}

- (NSString *)titleWithVideoRatio:(NSString *)videoRatio {
    if (videoRatio == nil || videoRatio.length == 0) {
        return @"X1";
    }
    return [@"X" stringByAppendingString:videoRatio];
}

@end
