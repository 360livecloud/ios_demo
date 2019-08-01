//
//  QHVCEditMediaEditor.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/26.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCEditTrackClipItem.h"
#import <QHVCEditKit/QHVCEditKit.h>

@interface QHVCEditMediaEditor : NSObject

+ (instancetype)sharedInstance;

#pragma mark -  timeline

- (void)createTimeline;
- (void)freeTimeline;
- (NSTimeInterval)getTimelineDuration;

- (void)addEffectToTimeline:(QHVCEditEffect *)effect;
- (void)updateTimelineEffect:(QHVCEditEffect *)effect;
- (void)deleteTimelineEffect:(QHVCEditEffect *)effect;

#pragma mark - main video track

- (void)createMainTrack;
- (QHVCEditSequenceTrack *)getMainVideoTrack;

- (void)mainTrackAppendClip:(QHVCEditTrackClipItem *)item;
- (void)mainTrackDeleteClip:(QHVCEditTrackClipItem *)item;
- (void)mainTrackInsertClip:(QHVCEditTrackClipItem *)item atIndex:(NSInteger)index;
- (void)mainTrackUpdateClip:(QHVCEditTrackClipItem *)item;
- (void)mainTrackMoveClip:(NSInteger)fromIndex toIndex:(NSInteger)index;
- (NSMutableArray<QHVCEditTrackClipItem *>*)getMainTrackClips;

//transition
- (void)mainTrackAddTransition:(NSInteger)index
                      duration:(NSInteger)duration
                transitionName:(NSString *)transitionName
            easingFunctionType:(QHVCEditEasingFunctionType)easingFunctionType;

- (void)mainTrackUpdateTransition:(NSInteger)index
                         duration:(NSInteger)duration
                   transitionName:(NSString *)transitionName
               easingFunctionType:(QHVCEditEasingFunctionType)easingFunctionType;

- (void)mainTrackDeleteTransition:(NSInteger)index;

//property
- (void)setMainTrackVolume:(NSInteger)volume;
- (void)setMainTrackPitch:(NSInteger)pitch;

//effect
- (void)addEffectToMainVideoTrack:(QHVCEditEffect *)effect;
- (void)updateMainVideoTrackEffect:(QHVCEditEffect *)effect;
- (void)deleteMainVideoTrackEffect:(QHVCEditEffect *)effect;

#pragma mark - video overlay track

- (void)addOverlayClip:(QHVCEditTrackClipItem *)item;
- (void)deleteOverlayClip:(QHVCEditTrackClipItem *)item;
- (void)updateOverlayClipParams:(QHVCEditTrackClipItem *)item;
- (void)updateOverlayClipZOrder:(QHVCEditTrackClipItem *)item step:(NSInteger)step; //1:置顶，-1:置底

- (void)overlayClip:(QHVCEditTrackClipItem *)item addEffect:(QHVCEditEffect *)effect;
- (void)overlayClip:(QHVCEditTrackClipItem *)item updateEffect:(QHVCEditEffect *)effect;
- (void)overlayTrack:(QHVCEditTrackClipItem *)item addEffect:(QHVCEditEffect *)effect;
- (void)overlayTrack:(QHVCEditTrackClipItem *)item updateEffect:(QHVCEditEffect *)effect;
- (void)overlayTrack:(QHVCEditTrackClipItem *)item deleteEffect:(QHVCEditEffect *)effect;

#pragma mark - main audio track

- (void)createMainAudioTrack;
- (QHVCEditTrack *)getMainAudioTrack;
- (void)deleteMainAudioTrack;
- (void)mainAudioTrackAppendClip:(QHVCEditTrackClipItem *)item;
- (void)mainAudioTrackDeleteClip:(QHVCEditTrackClipItem *)item;
- (void)mainAudioTrackDeleteAllClips;
- (NSMutableArray<QHVCEditTrackClipItem *>*)getMainAduioTrackClips;
- (void)setMainAduioTrackVolume:(NSInteger)volume;
- (void)setMainAduioTrackPitch:(NSInteger)pitch;

#pragma mark - player

- (QHVCEditPlayer *)createPlayerWithView:(UIView *)view delegate:(id<QHVCEditPlayerDelegate>)delegate;
- (void)freePlayer:(QHVCEditPlayer *)player;

#pragma mark - thumbnail

//单张缩略图
- (QHVCEditError)requestThumbFromFilePath:(NSString *)filePath
                    timestamp:(NSTimeInterval)timeMs
                    thumbSize:(CGSize)size
                thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback;

- (QHVCEditError)requestThumbFromFileIdentifier:(NSString *)fileIdentifier
                                      timestamp:(NSTimeInterval)timeMs
                                      thumbSize:(CGSize)size
                                  thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback;

//多张缩略图
- (QHVCEditError)requestThumbsFromFilePath:(NSString *)filePath
                start:(NSTimeInterval)startMs
                  end:(NSTimeInterval)endMs
             frameCnt:(int)count
            thumbSize:(CGSize)size
        thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback;

- (QHVCEditError)requestThumbsFromFileIdentifier:(NSString *)fileIdentifier
                                           start:(NSTimeInterval)startMs
                                             end:(NSTimeInterval)endMs
                                        frameCnt:(int)count
                                       thumbSize:(CGSize)size
                                   thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback;

- (QHVCEditError)cancelThumbnailRequest;
- (QHVCEditError)freeThumbnailBuilder;

#pragma mark - Producer

- (QHVCEditProducer *)createProducerWithDelegate:(id<QHVCEditProducerDelegate>)delegate;
- (void)freeProducer:(QHVCEditProducer *)producer;


#pragma mark - Propertys

@property (nonatomic, readonly, retain) QHVCEditTimeline* timeline;
@property (nonatomic, readonly, strong) QHVCEditThumbnail* thumbnail;

@property (nonatomic, readonly, retain) QHVCEditSequenceTrack* mainTrack;
@property (nonatomic, readonly, strong) NSMutableArray<QHVCEditTrackClipItem *>* mainTrackClips;

@property (nonatomic, readonly, retain) NSMutableArray<QHVCEditTrack *>* overlayTracks;
@property (nonatomic, readonly, retain) NSMutableArray<QHVCEditTrackClipItem *>* overlayTrackClips;

@property (nonatomic, readonly, strong) QHVCEditOverlayTrack *mainAudioTrack;
@property (nonatomic, readonly, strong) NSMutableArray<QHVCEditTrackClipItem *>* mainAudioTrackClips;

@end

