//
//  QHVCEditPlayerViewController.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditBaseViewController.h"
#import <QHVCEditKit/QHVCEditKit.h>

@interface QHVCEditPlayerViewController : QHVCEditBaseViewController
{
    QHVCEditPlayer *_player;
}
- (void)createPlayer:(UIView *)preview;
- (void)setPlayerBackgroudColor:(NSString *)argbColor;

- (void)play;
- (void)stop;
- (BOOL)isPlaying;
- (void)seekTo:(NSTimeInterval)pointMs;
- (void)seekTo:(NSTimeInterval)pointMs complete:(void(^)())complete;

- (void)refreshPlayer;
- (void)refreshPlayer:(BOOL)forceRefresh;
- (void)resetPlayer:(NSTimeInterval)seekTo;
- (NSTimeInterval)playerTime;

- (void)freePlayer;

- (void)playerComplete;
- (void)playerRenderFirstFrame;

@end
