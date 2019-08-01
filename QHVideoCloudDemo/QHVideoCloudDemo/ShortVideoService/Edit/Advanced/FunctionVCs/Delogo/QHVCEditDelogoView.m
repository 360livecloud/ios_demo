//
//  QHVCEditDelogoView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/21.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditDelogoView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditMediaEditorConfig+Advanced.h"
#import "QHVCEditDelogoItemView.h"
#import "QHVCEditMainContentView.h"

@interface QHVCEditDelogoView ()
@property (weak, nonatomic) IBOutlet UIButton *button;


@end

@implementation QHVCEditDelogoView

- (void)prepareSubviews
{
    QHVCEditDelogoEffect* effect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoEffect];
    NSString* title = effect ? @"关闭去水印":@"开启去水印";
    [self.button setTitle:title forState:UIControlStateNormal];
    
    QHVCEditDelogoItemView* itemView = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoItemView];
    if (itemView)
    {
        [itemView hideBorder:NO];
    }
}

- (void)confirmAction
{
    [super confirmAction];
    QHVCEditDelogoItemView* itemView = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoItemView];
    if (itemView)
    {
        [itemView hideBorder:YES];
    }
}

- (IBAction)onButtonClicked:(UIButton *)sender
{
    QHVCEditDelogoEffect* effect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoEffect];
    if (!effect)
    {
        [self.button setTitle:@"关闭去水印" forState:UIControlStateNormal];
        [self addEffect];
    }
    else
    {
        [self.button setTitle:@"开启去水印" forState:UIControlStateNormal];
        [self deleteEffect];
    }
}

- (QHVCEditDelogoItemView *)createDelogoItemView
{
    CGRect rect = [QHVCEditPrefs createRandomRect:kDefaultDelogoWidth targetHeight:kDefaultDelogoHeight
                                      sourceWidth:kDefaultDelogoWidth sourceHeight:kDefaultDelogoHeight
                                      contentSize:self.playerContentView.frame.size];
    QHVCEditDelogoItemView* itemView = [[QHVCEditDelogoItemView alloc] initWithFrame:rect];
    [self.playerContentView addSubview:itemView];
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setDelogoItemView:itemView];
    
    WEAK_SELF
    [itemView setRefreshBlock:^(BOOL forceRefresh)
    {
        STRONG_SELF
        [self updateEffect:forceRefresh];
    }];
    
    return itemView;
}

#pragma mark - MediaEdit Methods

- (void)addEffect
{
    QHVCEditDelogoItemView* itemView = [self createDelogoItemView];
    CGSize outputSize = [QHVCEditMediaEditorConfig sharedInstance].outputSize;
    CGRect region = [itemView rectToOutputRect:outputSize];
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    QHVCEditTrack* track = [[QHVCEditMediaEditor sharedInstance] getMainVideoTrack];
    QHVCEditDelogoEffect* effect = [[QHVCEditDelogoEffect alloc] initEffectWithTimeline:timeline];
    [effect setStartTime:0];
    [effect setEndTime:[track duration]];
    [effect setRegion:[QHVCEditPrefs rectFormatter:region]];
    [[QHVCEditMediaEditor sharedInstance] addEffectToMainVideoTrack:effect];
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setDelogoEffect:effect];
    SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
}

- (void)deleteEffect
{
    QHVCEditDelogoEffect* effect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoEffect];
    if (effect)
    {
        QHVCEditDelogoItemView* itemView = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoItemView];
        [itemView removeFromSuperview];
        [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setDelogoItemView:nil];
        
        [[QHVCEditMediaEditor sharedInstance] deleteMainVideoTrackEffect:effect];
        [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setDelogoEffect:nil];
        SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
    }
}

- (void)updateEffect:(BOOL)forceRefresh
{
    QHVCEditDelogoEffect* effect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoEffect];
    if (effect)
    {
        QHVCEditDelogoItemView* itemView = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] delogoItemView];
        CGSize outputSize = [QHVCEditMediaEditorConfig sharedInstance].outputSize;
        CGRect rect = [itemView rectToOutputRect:outputSize];
        [effect setRegion:[QHVCEditPrefs rectFormatter:rect]];
        [[QHVCEditMediaEditor sharedInstance] updateMainVideoTrackEffect:effect];
        SAFE_BLOCK(self.refreshPlayerBlock, forceRefresh);
    }
}

@end
