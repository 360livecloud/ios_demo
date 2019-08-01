//
//  QHVCEditPlayerBaseVC.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/27.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditBaseVC.h"
#import <QHVCEditKit/QHVCEditPlayer.h>

@interface QHVCEditPlayerBaseVC : QHVCEditBaseVC
@property (nonatomic, strong) QHVCEditPlayer* player;

- (void)createPlayerWithPreview:(UIView *)view;
- (void)freePlayer;

- (void)play;
- (void)stop;
- (BOOL)isPlaying;
- (void)seekTo:(NSInteger)pointMs;
- (void)seekTo:(NSInteger)pointMs forceRequest:(BOOL)forceRequest;
- (void)seekTo:(NSInteger)pointMs complete:(void(^)(void))complete;
- (void)seekTo:(NSInteger)pointMs forceRequest:(BOOL)forceRequest complete:(void(^)(void))complete;
- (NSInteger)curPlayerTime;
- (NSInteger)playerDuration;

- (void)refreshPlayerForEffectBasicParams;
- (void)refreshPlayerForEffectBasicParams:(void(^)(void))complete;
- (void)refreshPlayer:(BOOL)forceRefresh;
- (void)resetPlayer:(NSInteger)seekTo;
- (void)resetPlayerOfCurrentTime;

//override
- (void)playerComplete;
- (void)playerRenderedFirstFrame;

@end
