//
//  QHVCEditOverlayContentView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/7.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditMainContentView.h"
#import "QHVCEditPrefs.h"
#import "QHVCPhotoManager.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditMediaEditor.h"

@interface QHVCEditMainContentView ()
@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerBaseVC;

@end

@implementation QHVCEditMainContentView

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)clear
{
    //overlay
    [[[QHVCEditMediaEditorConfig sharedInstance] overlayItemArray] enumerateObjectsUsingBlock:^(QHVCEditOverlayItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [[QHVCEditMediaEditor sharedInstance] deleteOverlayClip:obj.clipItem];
        [obj removeFromSuperview];
    }];
    
    //sticker
    [[[QHVCEditMediaEditorConfig sharedInstance] stickerItemArray] enumerateObjectsUsingBlock:^(QHVCEditStickerItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [[QHVCEditMediaEditor sharedInstance] deleteTimelineEffect:obj.effectImage];
        [obj removeFromSuperview];
    }];
    
    //subtitle
    [[[QHVCEditMediaEditorConfig sharedInstance] subtitleItemArray] enumerateObjectsUsingBlock:^(QHVCEditSubtitleItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [[QHVCEditMediaEditor sharedInstance] deleteTimelineEffect:obj.effect];
        [obj removeFromSuperview];
    }];
    
    //mosaic
    [[[QHVCEditMediaEditorConfig sharedInstance] mosaicItemArray] enumerateObjectsUsingBlock:^(QHVCEditMosaicItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [[QHVCEditMediaEditor sharedInstance] deleteMainVideoTrackEffect:obj.effect];
        [obj removeFromSuperview];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QHVCEDIT_DEFINE_NOTIFY_CLEAR_PLAYER_CONTENT object:self];
}

- (void)setBasePlayerVC:(QHVCEditPlayerBaseVC *)playerBaseVC
{
    _playerBaseVC = playerBaseVC;
}

#pragma mark - 画中画

- (void)addOverlays:(NSArray<QHVCPhotoItem *> *)items complete:(void(^)(void))complete
{
    if (![[QHVCEditMediaEditorConfig sharedInstance] usePhotoIdentifier])
    {
        //文件存入沙盒
        WEAK_SELF
        [[QHVCPhotoManager manager] writeAssetsToSandbox:items complete:^{
            STRONG_SELF
            [self addOverlayViews:items];
            SAFE_BLOCK(self.resetPlayerAction);
            SAFE_BLOCK(complete);
        }];
    }
    else
    {
        [[QHVCPhotoManager manager] addAssetIdentifier:items];
        [self addOverlayViews:items];
        SAFE_BLOCK(self.resetPlayerAction);
        SAFE_BLOCK(complete);
    }
}

- (void)addOverlayViews:(NSArray<QHVCPhotoItem *> *)items
{
    [items enumerateObjectsUsingBlock:^(QHVCPhotoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         CGRect rect = [QHVCEditPrefs createRandomRect:kDefaultOverlayWidth targetHeight:kDefaultOverlayHeight
                                           sourceWidth:obj.assetWidth sourceHeight:obj.assetHeight
                                           contentSize:self.frame.size];
        QHVCEditOverlayItemView* overlayItemView = [[QHVCEditOverlayItemView alloc] initWithFrame:rect];
        [self addSubview:overlayItemView];
        [overlayItemView setPhotoItem:obj];
        [[[QHVCEditMediaEditorConfig sharedInstance] overlayItemArray] addObject:overlayItemView];
        
        [overlayItemView setResetPlayerBlock:^{
            SAFE_BLOCK(self.resetPlayerAction);
        }];
        
        [overlayItemView setRefreshPlayerBlock:^(BOOL forceRefresh)
         {
             SAFE_BLOCK(self.refreshPlayerAction, forceRefresh);
         }];
        
        [overlayItemView setTapAction:^(QHVCEditOverlayItemView *item)
         {
             NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:QHVCEDIT_DEFINE_NOTIFY_SHOW_OVERLAY_FUNCTION object:item];
         }];
    }];
}

#pragma mark - 贴纸

- (QHVCEditStickerItemView *)addSticker:(UIImage *)image
{
    CGRect rect = [QHVCEditPrefs createRandomRect:kDefaultStickerWidth targetHeight:kDefaultStickerHeight
                                      sourceWidth:kDefaultStickerWidth sourceHeight:kDefaultStickerHeight
                                      contentSize:self.frame.size];
    QHVCEditStickerItemView* stickerItemView = [[QHVCEditStickerItemView alloc] initWithFrame:rect];
    [stickerItemView setImage:image];
    [stickerItemView setPlayerBaseVC:self.playerBaseVC];
    [self addSubview:stickerItemView];
    [[[QHVCEditMediaEditorConfig sharedInstance] stickerItemArray] addObject:stickerItemView];
    
    WEAK_SELF
    [stickerItemView setRefreshPlayerForBasicParamBlock:^{
        STRONG_SELF
        SAFE_BLOCK(self.refreshPlayerForBasicParamAction);
    }];
    
    [stickerItemView setRefreshPlayerBlock:^(BOOL forceRefresh)
    {
        STRONG_SELF
        SAFE_BLOCK(self.refreshPlayerAction, forceRefresh);
    }];
    
    return stickerItemView;
}

#pragma mark - 字幕

- (QHVCEditSubtitleItemView *)addSubtitle:(UIImage *)image
{
    CGRect rect = [QHVCEditPrefs createRandomRect:kDefaultSubtitleWidth targetHeight:kDefaultSubtitleHeight
                                      sourceWidth:kDefaultSubtitleWidth sourceHeight:kDefaultSubtitleHeight
                                      contentSize:self.frame.size];
    QHVCEditSubtitleItemView* subtitleItemView = [[QHVCEditSubtitleItemView alloc] initWithFrame:rect];
    [subtitleItemView setImage:image];
    [self addSubview:subtitleItemView];
    [[[QHVCEditMediaEditorConfig sharedInstance] subtitleItemArray] addObject:subtitleItemView];
    
    WEAK_SELF
    [subtitleItemView setRefreshPlayerForBasicParamBlock:^{
        STRONG_SELF
        SAFE_BLOCK(self.refreshPlayerForBasicParamAction);
    }];
    
    [subtitleItemView setRefreshPlayerBlock:^(BOOL forceRefresh)
     {
         STRONG_SELF
         SAFE_BLOCK(self.refreshPlayerAction, forceRefresh);
     }];
    
    return subtitleItemView;
}

#pragma mark - 马赛克

- (QHVCEditMosaicItemView *)addMosaic
{
    CGRect rect = [QHVCEditPrefs createRandomRect:kDefaultMosaicWidth targetHeight:kDefaultMosaicHeight
                                      sourceWidth:kDefaultMosaicWidth sourceHeight:kDefaultMosaicHeight
                                      contentSize:self.frame.size];
    QHVCEditMosaicItemView* mosaicItemView = [[QHVCEditMosaicItemView alloc] initWithFrame:rect];
    [self addSubview:mosaicItemView];
    [[[QHVCEditMediaEditorConfig sharedInstance] mosaicItemArray] addObject:mosaicItemView];
    
    WEAK_SELF
    [mosaicItemView setRefreshPlayerForBasicParamBlock:^{
        STRONG_SELF
        SAFE_BLOCK(self.refreshPlayerForBasicParamAction);
    }];
    
    [mosaicItemView setRefreshPlayerBlock:^(BOOL forceRefresh)
    {
        STRONG_SELF
        SAFE_BLOCK(self.refreshPlayerAction, forceRefresh);
    }];
    
    return mosaicItemView;
}

@end
