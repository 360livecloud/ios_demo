//
//  QHVCEditMainViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditMainViewController.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMainNavView.h"
#import "QHVCEditMakeViewController.h"
#import "QHVCEditAlterSoundView.h"
#import "QHVCEditCommandManager.h"
#import "MBProgressHUD.h"
#import "QHVCEditReverseManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSUInteger, QHVCEditVCType)
{
    QHVCEditVCType_PlayerVC,
    QHVCEditVCType_ResourceVC,
    QHVCEditVCType_BaseVC,
    QHVCEditAlterSound_View,
    QHVCEditVCType_Reverse,
    QHVCEditVCType_clear,
};

@interface QHVCEditMainViewController ()
{
    NSArray<NSArray*> *_functions;
    QHVCEditMainNavView *_navView;
    QHVCEditAlterSoundView *_alterSoundView;
    MBProgressHUD *_progressView;
}
@end

@implementation QHVCEditMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = @"编辑";
    _functions = @[
                   @[@"美颜",@"edit_beautify",@"QHVCEditBeautifyViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"滤镜",@"edit_filter",@"QHVCEditAuxFilterViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"特效",@"edit_effect",@"QHVCEditEffectViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"剪辑",@"edit_tailor",@"QHVCEditTailorViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"字幕",@"edit_caption",@"QHVCEditSubtitleViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"贴纸",@"edit_sticker",@"QHVCEditStickerViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"倍速",@"edit_speed",@"QHVCEditSpeedViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"调节",@"edit_adjust",@"QHVCEditQualityViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"音乐",@"edit_audio",@"QHVCEditAudioViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"水印",@"edit_water",@"QHVCEditWatermaskViewController", @(QHVCEditVCType_PlayerVC)],
                   @[@"转场",@"edit_transfer",@"QHVCEditTransferViewController", @(QHVCEditVCType_PlayerVC)],
                 /*  @[@"分段",@"edit_cut",@"QHVCEditCutViewController"]*/
                   @[@"画中画",@"edit_overlay",@"QHVCEditOverlayResourceVC", @(QHVCEditVCType_ResourceVC)],
                   @[@"音效",@"edit_alter_sound",@"QHVCEditAlterSoundView", @(QHVCEditAlterSound_View)],
                   @[@"马赛克",@"edit_alter_sound",@"QHVCEditMosaicVC", @(QHVCEditVCType_PlayerVC)],
                   @[@"去水印",@"edit_alter_sound",@"QHVCEditDelogoVC", @(QHVCEditVCType_PlayerVC)],
                   @[@"变焦",@"edit_alter_sound",@"QHVCEditKenburnsVC", @(QHVCEditVCType_PlayerVC)],
                   @[@"动态字幕",@"edit_alter_sound",@"QHVCEditDynamicSubtitleVC", @(QHVCEditVCType_PlayerVC)],
                   @[@"倒放",@"edit_alter_sound",@"", @(QHVCEditVCType_Reverse)],
                   @[@"清除",@"edit_alter_sound",@"", @(QHVCEditVCType_clear)]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self createNavView];
}

- (void)createNavView
{
    if (!_navView) {
        _navView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditMainNavView class] description] owner:self options:nil][0];
        _navView.frame = CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100);
        [_navView updateView:_functions];
        __weak typeof(self) weakSelf = self;
        _navView.selectedCompletion = ^(NSInteger index) {
            [weakSelf navToFunction:index];
        };
        [self.view addSubview:_navView];
    }
}

- (void)nextAction:(UIButton *)btn
{
    QHVCEditMakeViewController *vc = [[QHVCEditMakeViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)backAction:(UIButton *)btn
{
    [self showAlert];
}

- (void)navToFunction:(NSInteger)index
{
    NSArray *item = _functions[index];
    if (item.count > 3)
    {
        NSString *className = item[2];
        QHVCEditVCType type = (QHVCEditVCType)[item[3] integerValue];
        if (type == QHVCEditVCType_PlayerVC)
        {
            QHVCEditPlayerMainViewController *vc = [[NSClassFromString(className) alloc] initWithNibName:@"QHVCEditPlayerMainViewController" bundle:nil];
            vc.durationMs = self.durationMs;
            __weak typeof(self) weakSelf = self;
            vc.confirmCompletion = ^(QHVCEditPlayerStatus status) {
                if (status == QHVCEditPlayerStatusRefresh) {
                    [weakSelf refreshPlayer];
                }
                else if (status == QHVCEditPlayerStatusReset)
                {
                    [weakSelf resetPlayer:self.durationMs];
                }
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (type == QHVCEditVCType_ResourceVC)
        {
            UIViewController* vc = [[NSClassFromString(className) alloc] initWithNibName:@"QHVCEditViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (type == QHVCEditAlterSound_View)
        {
            [self createAlterSoundView];
        }
        else if (type == QHVCEditVCType_Reverse)
        {
            [self handleReverse];
        }
        else if (type == QHVCEditVCType_clear)
        {
            [[QHVCEditCommandManager manager] removeAllCommands];
            [self resetPlayer:self.playerTime];
        }
        else
        {
            UIViewController* vc = [[NSClassFromString(className) alloc] initWithNibName:className bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)showAlert {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"放弃操作么" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[QHVCEditReverseManager sharedInstance] freeManager];
        [self releasePlayerVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createAlterSoundView
{
    if (!_alterSoundView) {
        _alterSoundView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditAlterSoundView class] description] owner:self options:nil][0];
        _alterSoundView.frame = CGRectMake(0, kScreenHeight - 120, kScreenWidth, 120);
        WEAK_SELF
        [_alterSoundView setChangePitchAction:^(int pitch) {
            STRONG_SELF
            [[QHVCEditCommandManager manager] adjustPitch:pitch];
            [self resetPlayer:self.playerTime];
        }];
        
        [_alterSoundView setChangeVolumeAction:^(int volume) {
            //TODO 调整音量
            STRONG_SELF
            [[QHVCEditCommandManager manager] adjustVolume:volume];
            [self resetPlayer:self.playerTime];
        }];
        
        [_alterSoundView setChangeFIAction:^(BOOL isOn) {
            //TODO 淡入
            STRONG_SELF
            [[QHVCEditCommandManager manager] audioFadeInFadeOut:isOn];
            [self resetPlayer:self.playerTime];
        }];
        
        [_alterSoundView setChangeFOAction:^(BOOL isOn) {
            //TODO 淡出
        }];
        
        [_alterSoundView setOnViewClose:^{
            STRONG_SELF
            self->_sliderViewBottom.constant = 5;
        }];
    }
    _sliderViewBottom.constant = 20;
    [self.view addSubview:_alterSoundView];
}

- (void)playerRenderFirstFrame
{
    [self play];
}

#pragma mark - reverse video
- (void)handleReverse
{
    NSArray<QHVCEditCommandAddFileSegment *>* segments = [[QHVCEditCommandManager manager] getFileSegments];
    WEAK_SELF
    [segments enumerateObjectsUsingBlock:^(QHVCEditCommandAddFileSegment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [QHVCEditReverseManager sharedInstance].handleStart = ^{
            if (!_progressView) {
                _progressView = [[MBProgressHUD alloc] initWithView:self.view];
                [_progressView setRemoveFromSuperViewOnHide:YES];
                _progressView.userInteractionEnabled = NO;
            }
            [self.view addSubview:_progressView];
            [_progressView showAnimated:YES];
        };

        [QHVCEditReverseManager sharedInstance].handleComplete = ^(NSInteger fileIndex, NSString *reverseFilePath) {
            STRONG_SELF
            [_progressView hideAnimated:YES];
            //写入相册
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:reverseFilePath]
                 completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"Save video fail:%@",error);
                    } else {
                        NSLog(@"Save video succeed.");
                        [[NSFileManager defaultManager] removeItemAtPath:reverseFilePath error:nil];
                    }
            }];
            [self resetPlayer:0];
        };
        [QHVCEditReverseManager sharedInstance].handling = ^(float progress) {
            _progressView.label.text = [NSString stringWithFormat:@"%f", progress];
        };
        [[QHVCEditReverseManager sharedInstance] handle:obj];
    }];
}

@end
