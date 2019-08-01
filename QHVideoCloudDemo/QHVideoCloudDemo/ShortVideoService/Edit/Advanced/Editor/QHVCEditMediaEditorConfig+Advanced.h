//
//  QHVCEditMediaEditorConfig+Advanced.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/14.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCEditKit/QHVCEditEffect+Advanced.h>

@class QHVCEditDelogoItemView;

@interface QHVCEditMediaEditorConfigAdvanced : NSObject

+ (instancetype)sharedInstance;
- (void)requestAdvancedAuth:(void(^)())complete;
- (void)cleanParamsAdvanced;
- (void)clearPlayerContentAdvanced;

//画质
@property (nonatomic, retain) QHVCEditQualityEffect* qualityEffect;

//变焦
@property (nonatomic, retain) QHVCEditKenburnsEffect* kenburnsEffect;
@property (nonatomic, assign) NSInteger kenburnsIndex;
@property (nonatomic, assign) CGFloat kenburnsIntensity;

//去水印
@property (nonatomic, retain) QHVCEditDelogoEffect* delogoEffect;
@property (nonatomic, retain) QHVCEditDelogoItemView* delogoItemView;

//动效
@property (nonatomic, retain) QHVCEditMotionEffect* motionEffect;
@property (nonatomic, assign) NSInteger motionEffectIndex;

//画中画-混合模式
@property (nonatomic, retain) QHVCEditBlendEffect* blendEffect;
@property (nonatomic, assign) NSInteger blendIndex;
@property (nonatomic, assign) CGFloat blendValue;

@end

#define kDefaultDelogoWidth    80.0
#define kDefaultDelogoHeight   50.0
