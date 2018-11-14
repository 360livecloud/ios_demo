//
//  QHVCEditPlayerViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditPlayerViewController.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditPlayerViewController ()<QHVCEditPlayerDelegate>
{
    NSTimeInterval _timestamp;
}
@end

@implementation QHVCEditPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)createPlayer:(UIView *)preview
{
    if (!_player) {
        _player = [[QHVCEditPlayer alloc] initPlayerWithCommandFactory:[QHVCEditCommandManager manager].commandFactory];
    }
    [_player setPlayerDelegate:self];
    [_player setPreviewFillMode:[QHVCEditPrefs sharedPrefs].renderMode];
    [_player setPreviewBackgroudColor:[QHVCEditPrefs sharedPrefs].renderColor];
    [_player setPlayerPreview:preview];
}

- (void)setPlayerBackgroudColor:(NSString *)argbColor
{
    [_player setPreviewBackgroudColor:argbColor];
    [QHVCEditPrefs sharedPrefs].renderColor = argbColor;
}

- (void)resetPlayer:(NSTimeInterval)seekTo
{
    if ([_player isPlayerPlaying])
    {
        [_player playerStop];
    }
    
    [_player resetPlayer:MAX(seekTo, 0)];
}

- (NSTimeInterval)playerTime
{
    return [_player getCurrentTimestamp];
}

- (void)refreshPlayer
{
    if (_player) {
        [_player refreshPlayerWithCompletion:nil];
    }
}

- (void)refreshPlayer:(BOOL)forceRefresh
{
    if (_player)
    {
        [_player refreshPlayerWithForceRefresh:forceRefresh completion:nil];
    }
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
    return [_player isPlayerPlaying];
}

- (void)seekTo:(NSTimeInterval)pointMs
{
    if (_player) {
        [_player playerSeekToTime:pointMs forceRequest:YES complete:^(NSTimeInterval currentTime) {
            NSLog(@"currentTime --- %@",@(currentTime));
        }];
    }
}

- (void)seekTo:(NSTimeInterval)pointMs complete:(void(^)())complete
{
    if (_player) {
        [_player playerSeekToTime:pointMs forceRequest:YES complete:^(NSTimeInterval currentTime)
        {
            NSLog(@"currentTime --- %@",@(currentTime));
            SAFE_BLOCK_IN_MAIN_QUEUE(complete);
        }];
    }
}

- (NSTimeInterval)playerTimestamp
{
    if ([_player isPlayerPlaying])
    {
        _timestamp = [_player getCurrentTimestamp];
    }
    return _timestamp;
}

- (void)freePlayer
{
    if (_player) {
        [_player free];
        _player = nil;
    }
}

#pragma mark QHVCEditPlayerDelegate

- (void)onPlayerError:(QHVCEditPlayerError)error detailInfo:(QHVCEditPlayerErrorInfo)info
{
    NSLog(@"onPlayerError %@",@(error));
}

- (void)onPlayerPlayComplete
{
    NSLog(@"onPlayerPlayComplete");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playerComplete];
    });
}

- (void)onPlayerFirstFrameDidRendered
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playerRenderFirstFrame];
    });
}

- (void)playerComplete
{
    
}

- (void)playerRenderFirstFrame
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
