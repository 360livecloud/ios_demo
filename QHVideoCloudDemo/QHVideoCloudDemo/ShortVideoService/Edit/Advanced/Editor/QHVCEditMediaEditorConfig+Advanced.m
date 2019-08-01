//
//  QHVCEditMediaEditorConfig+Advanced.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/14.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditMediaEditorConfig+Advanced.h"
#import "QHVCEditDelogoItemView.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditPrefs.h"
#import "QHVCShortVideoUtils.h"

@implementation QHVCEditMediaEditorConfigAdvanced

+ (instancetype)sharedInstance
{
    static QHVCEditMediaEditorConfigAdvanced* s_instance = nil;
    static dispatch_once_t predic;
    dispatch_once(&predic, ^{
        s_instance = [[QHVCEditMediaEditorConfigAdvanced alloc] init];
        [s_instance initialAdvancedParams];
    });
    return s_instance;
}

- (void)initialAdvancedParams
{
    self.kenburnsIntensity = 1.0;
    self.blendIndex = 0;
    self.blendValue = 1.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearPlayerContentAdvanced) name:QHVCEDIT_DEFINE_NOTIFY_CLEAR_PLAYER_CONTENT object:nil];
}

- (void)requestAdvancedAuth:(void(^)())complete
{
//    /*
//     * 1. 只本地离线授权生效
//     */
//    NSString* localAuth = @"";
//    [QHVCEditConfig setLocalAuthorizationInfo:localAuth];  //本地离线授权
//    [QHVCEditConfig requestAdvancedAuthorization:^(QHVCEditAuthError err, NSString *errMessage)
//     {
//         NSLog(@"EditKit advanced %@", err==QHVCEditAuthErrorNoError ? @"valid":@"invalid");
//         SAFE_BLOCK_IN_MAIN_QUEUE(complete);
//     }];
    
//    /*
//     * 2.1 不配置本地离线授权文件，只走sdk内部自动鉴权逻辑
//     * 启动时主动获取鉴权状态
//     */
//    [QHVCEditConfig requestAdvancedAuthorization:^(QHVCEditAuthError err, NSString *errMessage)
//     {
//         NSLog(@"EditKit advanced %@", err==QHVCEditAuthErrorNoError ? @"valid":@"invalid");
//         SAFE_BLOCK_IN_MAIN_QUEUE(complete);
//     }];
    
    /*
     * 2.2 不配置本地离线授权文件，只走sdk内部自动鉴权逻辑
     * 使用高级功能时自动鉴权，可能会出现短时间无效果现象
     */
    SAFE_BLOCK_IN_MAIN_QUEUE(complete);
}

- (void)cleanParamsAdvanced
{
    self.qualityEffect = nil;
    self.kenburnsEffect = nil;
    self.kenburnsIndex = 0;
    self.kenburnsIntensity = 1.0;
    self.motionEffectIndex = 0;
    self.motionEffect = nil;
    self.blendIndex = 0;
    self.blendValue = 1.0;
    self.blendEffect = nil;
}

- (void)clearPlayerContentAdvanced
{
    //delogo
    if (self.delogoItemView)
    {
        [self.delogoItemView removeFromSuperview];
        self.delogoItemView = nil;
    }
    
    if (self.delogoEffect)
    {
        [[QHVCEditMediaEditor sharedInstance] deleteMainVideoTrackEffect:self.delogoEffect];
        self.delogoEffect = nil;
    }
}

@end
