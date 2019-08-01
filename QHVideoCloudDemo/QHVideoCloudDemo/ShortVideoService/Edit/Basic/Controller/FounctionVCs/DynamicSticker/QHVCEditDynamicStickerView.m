//
//  QHVCEditDynamicStickerView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/19.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditDynamicStickerView.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditDynamicStickerView ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation QHVCEditDynamicStickerView

- (void)prepareSubviews
{
    QHVCEditDynamicStickerEffect* effect = [[QHVCEditMediaEditorConfig sharedInstance] dynamicStickerEffect];
    NSString* title = effect ? @"关闭动态贴纸":@"开启动态贴纸";
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (IBAction)onButtonClicked:(UIButton *)sender
{
    QHVCEditDynamicStickerEffect* effect = [[QHVCEditMediaEditorConfig sharedInstance] dynamicStickerEffect];
    if (effect)
    {
        //关闭贴纸
        [self.button setTitle:@"开启动态贴纸" forState:UIControlStateNormal];
        [self deleteEffect];
    }
    else
    {
        //开启贴纸
        [self.button setTitle:@"关闭动态贴纸" forState:UIControlStateNormal];
        [self addEffect];
    }
}

#pragma mark - MediaEditor Methods

- (void)addEffect
{
    NSMutableArray* paths = [[NSMutableArray alloc] init];
    for (int i = 0; i <= 50; i++)
    {
        NSString* index = [NSString stringWithFormat:@"%d", i];
        if (i < 10)
        {
            index = [@"0" stringByAppendingString:index];
        }
        NSString* name = [NSString stringWithFormat:@"铲屎官_000%@.png", index];
        NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        [paths addObject:path];
    }
    
    NSMutableDictionary* imageInfo = [[NSMutableDictionary alloc] init];
    [imageInfo setObject:@(25) forKey:@"fps"];
    [imageInfo setObject:paths forKey:@"path"];
    [imageInfo setObject:@(0) forKey:@"loopStartIndex"];
    [imageInfo setObject:@(50) forKey:@"loopEndIndex"];
    
    CGSize outputSize = [[QHVCEditMediaEditorConfig sharedInstance] outputSize];
    float stickerSize = MIN(outputSize.width, outputSize.height)/2.0;
    QHVCEffectRect rect = QHVCEffectRectMake(outputSize.width/2.0, outputSize.height/2.0, stickerSize, stickerSize);
    
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    QHVCEditDynamicStickerEffect* effect = [[QHVCEditDynamicStickerEffect alloc] initEffectWithTimeline:timeline];
    [effect setStartTime:0];
    [effect setEndTime:[timeline duration]];
    [effect setRenderRect:rect];
    [effect setRenderRadian:0];
    [effect setImageInfo:imageInfo];
    [[QHVCEditMediaEditor sharedInstance] addEffectToTimeline:effect];
    [[QHVCEditMediaEditorConfig sharedInstance] setDynamicStickerEffect:effect];
    SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
}

- (void)deleteEffect
{
    QHVCEditDynamicStickerEffect* effect = [[QHVCEditMediaEditorConfig sharedInstance] dynamicStickerEffect];
    if (effect)
    {
        [[QHVCEditMediaEditor sharedInstance] deleteTimelineEffect:effect];
        [[QHVCEditMediaEditorConfig sharedInstance] setDynamicStickerEffect:nil];
        SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
    }
}

@end
