//
//  QHVCEditOverlayItemView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/7.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayItemView.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditorConfig.h"

@interface QHVCEditOverlayItemView ()

@end

@implementation QHVCEditOverlayItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    
    return self;
}

- (void)setPhotoItem:(QHVCPhotoItem *)item
{
    self.clipItem = [[QHVCEditTrackClipItem alloc] initWithPhotoItem:item];
    [[QHVCEditMediaEditor sharedInstance] addOverlayClip:self.clipItem];
    [self updateRenderRect];
    [self hideBorder:YES];
}

- (void)updateRenderRect
{
    QHVCEditTrackClip* clip = self.clipItem.clip;
    if (clip)
    {
        CGSize outputSize = [QHVCEditMediaEditorConfig sharedInstance].outputSize;
        CGRect rect = [self rectToOutputRect:outputSize];
        if (!clip.renderInfo)
        {
            QHVCEditRenderInfo* renderInfo = [[QHVCEditRenderInfo alloc] init];
            clip.renderInfo = renderInfo;
        }
        
        QHVCEffectRect newRect = [QHVCEditPrefs rectFormatter:rect];
        [clip.renderInfo setViewRect:newRect];
        [clip.renderInfo setViewRadian:self.radian];
    }
}

#pragma mark - Gesture Action

- (void)tapGestureAction
{
    SAFE_BLOCK(self.tapAction, self);
}

- (void)moveGestureAction:(BOOL)isEnd
{
    [self updateRenderRect];
    SAFE_BLOCK(self.refreshPlayerBlock, isEnd);
}

- (void)rotateGestureAction:(BOOL)isEnd
{
    [self updateRenderRect];
    SAFE_BLOCK(self.refreshPlayerBlock, isEnd);
}

- (void)pinchGestureAction:(BOOL)isEnd
{
    [self updateRenderRect];
    SAFE_BLOCK(self.refreshPlayerBlock, isEnd);
}

@end
