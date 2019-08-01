//
//  QHVCEditPlayerBaseVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/27.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditPlayerBaseVC.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditorConfig.h"

@interface QHVCEditPlayerBaseVC () <QHVCEditPlayerDelegate>

@end

@implementation QHVCEditPlayerBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Player Methods

- (void)createPlayerWithPreview:(UIView *)view
{
    self.player = [[QHVCEditMediaEditor sharedInstance] createPlayerWithView:view delegate:self];
    [self.player setPreviewBgColor:[[QHVCEditMediaEditorConfig sharedInstance] playerBgColor]];
}

- (void)freePlayer
{
    [[QHVCEditMediaEditor sharedInstance] freePlayer:self.player];
}

- (void)play
{
    if (_player) {
        [_player playerPlay];
    }
}

- (void)stop
{
    if (_player) {
        [_player playerStop];
    }
}

- (BOOL)isPlaying
{
    return [_player isPlaying];
}

- (void)seekTo:(NSInteger)pointMs
{
    [self seekTo:pointMs forceRequest:YES];
}

- (void)seekTo:(NSInteger)pointMs forceRequest:(BOOL)forceRequest
{
    [self seekTo:pointMs forceRequest:forceRequest complete:nil];
}

- (void)seekTo:(NSInteger)pointMs complete:(void(^)(void))complete
{
    [self seekTo:pointMs forceRequest:YES complete:complete];
}

- (void)seekTo:(NSInteger)pointMs forceRequest:(BOOL)forceRequest complete:(void (^)(void))complete
{
    if (_player)
    {
            [_player playerSeekToTime:pointMs forceRequest:forceRequest complete:^(NSInteger currentTimeMs)
             {
                 SAFE_BLOCK_IN_MAIN_QUEUE(complete);
             }];
    }
}

- (NSInteger)curPlayerTime
{
    return [_player getCurrentTimestamp];
}

- (NSInteger)playerDuration
{
    return [_player getPlayerDuration];
}

- (void)refreshPlayerForEffectBasicParams
{
    [self refreshPlayerForEffectBasicParams:nil];
}

- (void)refreshPlayerForEffectBasicParams:(void (^)(void))complete
{
    if (_player)
    {
        [_player refreshPlayer:YES completion:complete];
    }
}


- (void)refreshPlayer:(BOOL)forceRefresh
{
    if (_player)
    {
        [_player refreshPlayer:forceRefresh completion:nil];
    }
}

- (void)resetPlayer:(NSInteger)seekTo
{
    if ([_player isPlaying])
    {
        [_player playerStop];
    }
    
    [_player resetPlayer:MAX(seekTo, 0)];
}

- (void)resetPlayerOfCurrentTime
{
    [self resetPlayer:[self curPlayerTime]];
}

- (void)playerComplete
{
    //override
}

- (void)playerRenderedFirstFrame
{
    //override
}

#pragma mark - Player Delegate

- (void)onPlayerError:(QHVCEditError)error detail:(NSString *)detail
{
    NSLog(@"onPlayerError %@, detail: %@", @(error), detail);
}

- (void)onPlayerPlayComplete
{
    NSLog(@"onPlayerPlayComplete");
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF
        [self playerComplete];
    });
}

- (void)onPlayerFirstFrameDidRendered
{
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF
        [self playerRenderedFirstFrame];
    });
}

@end
