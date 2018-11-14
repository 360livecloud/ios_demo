//
//  QHVCEditCommandManager.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCEditKit/QHVCEditKit.h>

@class QHVCEditPhotoItem;
@class QHVCEditStickerIconView;
@class QHVCEditAudioItem;
@class QHVCEditSegmentItem;
@class QHVCEditSubtitleItem;
@class QHVCEditMatrixItem;

typedef NS_ENUM(NSInteger, QHVCEditCommandStatus) {
    QHVCEditCommandStatusAdd = 1,
    QHVCEditCommandStatusDone,
};

typedef NS_ENUM(NSInteger, QHVCEditCommandOperation) {
    QHVCEditCommandOperationAddFile = 1,
    QHVCEditCommandOperationAdjustQuality,
    QHVCEditCommandOperationAddImage,
    QHVCEditCommandOperationAddFilter,
    QHVCEditCommandOperationAddMatrix,
    QHVCEditCommandOperationAddAudio,
    QHVCEditCommandOperationAddOverlay,
    QHVCEditCommandOperationAddChromakey,
    QHVCEditCommandOperationAddFade,
    QHVCEditCommandOperationAddBeauty,
    QHVCEditCommandOperationAddEffect,
    QHVCEditCommandOperationAddMosaic,
    QHVCEditCommandOperationAddDelogo,
    QHVCEditCommandOperationAddKenburns,
    QHVCEditCommandOperationAddDynamicSubtitle,
};

typedef void(^QHVCEditSegmentInfoBlock)(NSArray<QHVCEditSegmentInfo *>* segments, NSInteger totalDuration);

@interface QHVCEditCommandManager : NSObject

@property (nonatomic, strong) QHVCEditCommandFactory *commandFactory;
@property (nonatomic, strong) QHVCEditOutputParams* outputParams;
@property (nonatomic, strong) QHVCEditThumbnail* thumbnailFactory;

+ (instancetype)manager;

- (void)initCommandFactory;
- (void)freeCommandFactory;

- (void)addFiles:(NSArray<QHVCEditPhotoItem *> *)files;
- (void)appendFiles:(NSArray<QHVCEditPhotoItem *> *)files;
- (NSArray<NSDictionary *> *)fetchFiles;

- (void)fetchThumbs:(NSString *)filePath start:(NSTimeInterval)startMs end:(NSTimeInterval)endMs frameCnt:(int)count thumbSize:(CGSize)size completion:(void (^)(NSArray<QHVCEditThumbnailItem *> *thumbnails))completion;

- (void)fetchPhotoFileThumbs:(NSString *)photoFileIdentifier start:(NSTimeInterval)startMs end:(NSTimeInterval)endMs frameCnt:(int)count thumbSize:(CGSize)size completion:(void (^)(NSArray<QHVCEditThumbnailItem *> *thumbnails))completion;

- (QHVCEditSegmentInfo *)getOverlaySegmentInfo:(NSInteger)overlayCommandId;
- (void)fetchSegmentInfo:(QHVCEditSegmentInfoBlock)complete;
- (NSArray<QHVCEditCommandAddFileSegment *>*)getFileSegments;

- (BOOL)adjustQuality:(NSInteger)type value:(float)value;

- (void)adjustSpeed:(float)speed;

//需resetplayer
- (void)adjustPitch:(float)pitch;
//需resetplayer
- (void)adjustVolume:(float)volume;
//需resetplayer,调节主轴物理文件音量
- (void)adjustMainVolume:(float)volume;

- (void)audioFadeInFadeOut:(BOOL)onFadeInOut;

- (void)addFilter:(NSDictionary *)item;

- (QHVCEditCommandImageFilter *)addImageFilter:(UIImage *)image
                                    renderRect:(CGRect)renderRect
                                        radian:(CGFloat)radian;
- (void)updateImageFilter:(QHVCEditCommandImageFilter *)filterCommand
               renderRect:(CGRect)renderRect
                   radian:(CGFloat)radian;
- (void)deleteImageFilter:(QHVCEditCommandImageFilter *)filterCommand;
- (void)addImageFadeInOut:(QHVCEditCommandImageFilter *)filterCommand;
- (void)addImageMoveInOut:(QHVCEditCommandImageFilter *)filterCommand;
- (void)addImageJumpInOut:(QHVCEditCommandImageFilter *)filterCommand;
- (void)addImageRotateInOut:(QHVCEditCommandImageFilter *)filterCommand;

- (void)addAudios:(NSArray<QHVCEditAudioItem *> *)audios;
- (void)updateAudios;
- (void)deleteAudios;

- (void)addTransfers:(NSArray<QHVCEditSegmentItem *> *)transfers;

- (void)updateOutputSize:(CGSize)size;
- (void)updateOutputRenderMode:(QHVCEditOutputRenderMode)renderMode;
- (void)updateOutputBackgroudMode:(NSString *)colorHex;

- (NSInteger)addOverlayFile:(QHVCEditPhotoItem *)file;
- (void)updateOverlayFile:(QHVCEditPhotoItem *)file overlayId:(NSInteger)overlayId;
- (void)deleteOverlayFile:(NSInteger)overlayId;
- (void)updateOverlaySpeed:(CGFloat)speed overlayId:(NSInteger)overlayId;
- (void)updateOverlayVolume:(CGFloat)volume overlayId:(NSInteger)overlayId;
- (void)addOverlayFadeInOut:(NSInteger)overlayId;
- (void)addOverlayMoveInOut:(NSInteger)overlayId;
- (void)addOverlayJumpInOut:(NSInteger)overlayId;
- (void)addOverlayRotateInOut:(NSInteger)overlayId;
- (void)addOverlayBlendMode:(NSInteger)overlayId blendMode:(NSInteger)blendMode progres:(CGFloat)progress;

- (void)addMatrix:(QHVCEditMatrixItem *)item;
- (void)updateMatrix:(QHVCEditMatrixItem *)item;
- (void)deleteMatrix:(QHVCEditMatrixItem *)item;

- (void)addChromakeyWithColor:(NSString*)argb
                    threshold:(int)threshold
                       extend:(int)extend
             overlayCommandId:(NSInteger)overlayCommandId
             startTimestampMs:(int)startTimestampMs
               endTimestampMs:(int)endTimestampMs;
- (void)updateChromakeyWithColor:(NSString*)argb
                       threshold:(int)threshold
                          extend:(int)extend
                overlayCommandId:(NSInteger)overlayCommandId;
- (void)deleteChromakey:(NSInteger)overlayCommandId;

- (NSArray *)getAudios;

- (void)openBeauty:(float)softLevel white:(float)whiteLevel;
- (void)adjustBeauty:(float)softLevel white:(float)whiteLevel;

- (void)addEffect:(NSString *)effectName;
- (void)adjustEffect:(NSString *)effectName;

- (void)updateMosaic:(CGRect)region degree:(CGFloat)degree;
- (void)updateDelogo:(CGRect)region;

- (void)updateKenburnsEffect:(NSDictionary *)kenburnsInfo;
- (void)deleteKenburnsEffect;

- (void)addDynamicSubtitle:(NSString *)filePath;
- (void)deleteDynamicSubtitle;

- (void)removeAllCommands;

@end
