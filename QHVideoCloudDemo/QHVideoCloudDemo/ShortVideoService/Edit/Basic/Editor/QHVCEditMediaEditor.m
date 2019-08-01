//
//  QHVCEditMediaEditor.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/26.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditMediaEditor.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCShortVideoUtils.h"

@interface QHVCEditMediaEditor ()

@property (nonatomic, retain) QHVCEditTimeline* timeline;
@property (nonatomic, strong) QHVCEditThumbnail* thumbnail;

@property (nonatomic, retain) QHVCEditSequenceTrack* mainTrack;
@property (nonatomic, strong) NSMutableArray<QHVCEditTrackClipItem *>* mainTrackClips;

@property (nonatomic, retain) NSMutableArray<QHVCEditTrack *>* overlayTracks;
@property (nonatomic, retain) NSMutableArray<QHVCEditTrackClipItem *>* overlayTrackClips;

@property (nonatomic, strong) QHVCEditOverlayTrack *mainAudioTrack;
@property (nonatomic, strong) NSMutableArray<QHVCEditTrackClipItem *>* mainAudioTrackClips;

@end

@implementation QHVCEditMediaEditor

+ (instancetype)sharedInstance
{
    static QHVCEditMediaEditor* s_instance = nil;
    static dispatch_once_t predic;
    dispatch_once(&predic, ^{
        s_instance = [[QHVCEditMediaEditor alloc] init];
    });
    return s_instance;
}

- (instancetype)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    self.mainTrackClips = [[NSMutableArray alloc] initWithCapacity:0];
    self.overlayTracks = [[NSMutableArray alloc] initWithCapacity:0];
    self.overlayTrackClips = [[NSMutableArray alloc] initWithCapacity:0];
#ifdef DEBUG
    [QHVCEditConfig setSDKLogLevel:QHVCEditLogLevelDebug];
#endif
    return self;
}

#pragma mark - timeline

- (void)createTimeline
{
    CGSize outputSize = [[QHVCEditMediaEditorConfig sharedInstance] outputSize];
    NSInteger fps = [[QHVCEditMediaEditorConfig sharedInstance] outputFps];
    NSInteger bitrate = [[QHVCEditMediaEditorConfig sharedInstance] outputVideoBitrate];
    self.timeline = [[QHVCEditTimeline alloc] initTimeline];
    [self.timeline setOutputWidth:outputSize.width height:outputSize.height];
    [self.timeline setOutputBgColor:@"FF000000"];
    [self.timeline setOutputFps:fps];
    [self.timeline setVideoOutputBitrate:bitrate];
}

- (void)freeTimeline
{
    [self.timeline free];
    [self.mainTrackClips removeAllObjects];
    self.mainTrack = nil;
    [self.overlayTracks removeAllObjects];
    [self.overlayTrackClips removeAllObjects];
    [self.mainAudioTrackClips removeAllObjects];
    self.mainAudioTrack = nil;
}

- (NSTimeInterval)getTimelineDuration
{
    return [self.timeline duration];
}

//timeline effect
- (void)addEffectToTimeline:(QHVCEditEffect *)effect
{
    [self.timeline addEffect:effect];
}

- (void)updateTimelineEffect:(QHVCEditEffect *)effect
{
    [self.timeline updateEffect:effect];
}

- (void)deleteTimelineEffect:(QHVCEditEffect *)effect
{
    [self.timeline deleteEffectById:effect.effectId];
}

#pragma mark - main video track

- (void)createMainTrack
{
    self.mainTrack = [[QHVCEditSequenceTrack alloc] initWithTimeline:self.timeline type:QHVCEditTrackTypeVideo];
    [self.timeline appendTrack:self.mainTrack];
}

- (void)mainTrackAppendClip:(QHVCEditTrackClipItem *)item
{
    if (!item)
    {
        return;
    }
    
    QHVCEditTrackClip* clip = [[QHVCEditTrackClip alloc] initClipWithTimeline:self.timeline];
    if (item.fileIdentifier)
    {
        [clip setFileIdentifier:item.fileIdentifier type:item.clipType];
    }
    else
    {
        [clip setFilePath:item.filePath type:item.clipType];
    }
    
    [clip setFileStartTime:0];
    [clip setFileEndTime:item.durationMs];
    [clip setSlowMotionVideoInfo:item.slowMotionInfo];
    item.clip = clip;
    [self.mainTrack appendClip:clip];
    [self.mainTrackClips addObject:item];
}

- (void)mainTrackDeleteClip:(QHVCEditTrackClipItem *)item
{
    if (!item)
    {
        return;
    }
    
    [self.mainTrack deleteClipById:item.clip.clipId];
    [self.mainTrackClips removeObject:item];
}

- (void)mainTrackInsertClip:(QHVCEditTrackClipItem *)item atIndex:(NSInteger)index
{
    if (!item)
    {
        return;
    }
    
    [self.mainTrack insertClip:item.clip atIndex:index];
    [self.mainTrackClips insertObject:item atIndex:index];
}

- (void)mainTrackUpdateClip:(QHVCEditTrackClipItem *)item
{
    if (!item)
    {
        return;
    }
    
    [self.mainTrack updateClipParams:item.clip];
}

- (void)mainTrackMoveClip:(NSInteger)fromIndex toIndex:(NSInteger)index
{
    if (fromIndex >= 0 && index >= 0 && fromIndex != index)
    {
        [self.mainTrack moveClip:fromIndex toIndex:index];
    }
}

- (QHVCEditSequenceTrack *)getMainVideoTrack
{
    return self.mainTrack;
}

- (NSMutableArray<QHVCEditTrackClipItem *>*)getMainTrackClips
{
    return self.mainTrackClips;
}

- (void)mainTrackAddTransition:(NSInteger)index
                      duration:(NSInteger)duration
                transitionName:(NSString *)transitionName
            easingFunctionType:(QHVCEditEasingFunctionType)easingFunctionType
{
    [self.mainTrack addVideoTransitionToIndex:index duration:duration videoTransitionName:transitionName easingFunctionType:easingFunctionType];
}

- (void)mainTrackUpdateTransition:(NSInteger)index
                         duration:(NSInteger)duration
                   transitionName:(NSString *)transitionName
               easingFunctionType:(QHVCEditEasingFunctionType)easingFunctionType
{
    [self.mainTrack updateVideoTransitionAtIndex:index duration:duration videoTransitionName:transitionName easingFunctionType:easingFunctionType];
}

- (void)mainTrackDeleteTransition:(NSInteger)index
{
    [self.mainTrack deleteVideoTransition:index];
}

- (void)setMainTrackVolume:(NSInteger)volume
{
    if (_mainTrack)
    {
        [_mainTrack setVolume:volume];
    }
}

- (void)setMainTrackPitch:(NSInteger)pitch
{
    if (_mainTrack)
    {
        [self.mainTrackClips enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            [obj.clip setPitch:pitch];
            [self.mainTrack updateClipParams:obj.clip];
        }];
    }
}

//main video track effect
- (void)addEffectToMainVideoTrack:(QHVCEditEffect *)effect
{
    [self.mainTrack addEffect:effect];
}

- (void)updateMainVideoTrackEffect:(QHVCEditEffect *)effect
{
    [self.mainTrack updateEffect:effect];
}

- (void)deleteMainVideoTrackEffect:(QHVCEditEffect *)effect
{
    [self.mainTrack deleteEffectById:effect.effectId];
}

#pragma mark - video overlay track

- (void)addOverlayClip:(QHVCEditTrackClipItem *)item
{
    if (!item)
    {
        return;
    }
    
    QHVCEditOverlayTrack* overlayTrack = [[QHVCEditOverlayTrack alloc] initWithTimeline:self.timeline type:QHVCEditTrackTypeVideo];
    [overlayTrack setZOrder:[self.overlayTracks count] + 1];
    [self.timeline appendTrack:overlayTrack];
    
    QHVCEditTrackClip* clip = [[QHVCEditTrackClip alloc] initClipWithTimeline:self.timeline];
    if (item.fileIdentifier)
    {
        [clip setFileIdentifier:item.fileIdentifier type:item.clipType];
    }
    else
    {
        [clip setFilePath:item.filePath type:item.clipType];
    }
    
    [clip setFileStartTime:0];
    [clip setFileEndTime:item.durationMs];
    [clip setSlowMotionVideoInfo:item.slowMotionInfo];
    item.clip = clip;
    [overlayTrack addClip:clip atTime:0];
    [self.overlayTracks addObject:overlayTrack];
    [self.overlayTrackClips addObject:item];
}

- (void)deleteOverlayClip:(QHVCEditTrackClipItem *)item
{
    if (!item)
    {
        return;
    }
    
    if (!item.clip)
    {
        return;
    }
    
    QHVCEditOverlayTrack* track = (QHVCEditOverlayTrack *)[item.clip superObj];
    [track deleteClipById:item.clip.clipId];
    [self.overlayTrackClips removeObject:item];
    [self.overlayTracks removeObject:track];
}

- (void)updateOverlayClipParams:(QHVCEditTrackClipItem *)item
{
    if (!item)
    {
        return;
    }
    
    if (!item.clip)
    {
        return;
    }
    
    QHVCEditOverlayTrack* track = (QHVCEditOverlayTrack *)[item.clip superObj];
    [track updateClipParams:item.clip];
}

- (void)updateOverlayClipZOrder:(QHVCEditTrackClipItem *)item step:(NSInteger)step
{
    //画中画排序1-8
    if (!item || !item.clip)
    {
        return;
    }
    
    //更新其他track zorder
    QHVCEditTrack* curTrack = (QHVCEditTrack *)[item.clip superObj];
    NSInteger curZOrder = [curTrack zOrder];
    [self.overlayTracks enumerateObjectsUsingBlock:^(QHVCEditTrack * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         NSInteger zOrder = [obj zOrder];
         if (step == 1)
         {
             //置顶
             if (zOrder > curZOrder)
             {
                 [obj setZOrder:zOrder - 1];
             }
         }
         else if (step == -1)
         {
             //置底
             if (zOrder < curZOrder)
             {
                 [obj setZOrder:zOrder + 1];
             }
         }
     }];
    
    //修改当前track zorder
    if (step == 1)
    {
        //置顶
        [curTrack setZOrder:[self.overlayTracks count]];
    }
    else if (step == -1)
    {
        //置底
        [curTrack setZOrder:1];
    }
}

- (void)overlayClip:(QHVCEditTrackClipItem *)item addEffect:(QHVCEditEffect *)effect
{
    if (!item || !item.clip)
    {
        return;
    }
    
    [item.clip addEffect:effect];
}

- (void)overlayClip:(QHVCEditTrackClipItem *)item updateEffect:(QHVCEditEffect *)effect
{
    if (!item || !item.clip)
    {
        return;
    }
    
    [item.clip updateEffect:effect];
}

- (void)overlayTrack:(QHVCEditTrackClipItem *)item addEffect:(QHVCEditEffect *)effect
{
    if (!item || !item.clip || !effect)
    {
        return;
    }
    
    QHVCEditTrack* track = (QHVCEditTrack *)[item.clip superObj];
    [track addEffect:effect];
}

- (void)overlayTrack:(QHVCEditTrackClipItem *)item updateEffect:(QHVCEditEffect *)effect
{
    if (!item || !item.clip || !effect)
    {
        return;
    }
    
    QHVCEditTrack* track = (QHVCEditTrack *)[item.clip superObj];
    [track updateEffect:effect];
}

- (void)overlayTrack:(QHVCEditTrackClipItem *)item deleteEffect:(QHVCEditEffect *)effect
{
    if (!item || !item.clip || !effect)
    {
        return;
    }
    
    QHVCEditTrack* track = (QHVCEditTrack *)[item.clip superObj];
    [track deleteEffectById:effect.effectId];
}

#pragma mark - main audio track

- (void)createMainAudioTrack
{
    self.mainAudioTrack = [[QHVCEditOverlayTrack alloc] initWithTimeline:self.timeline type:QHVCEditTrackTypeAudio];
    [self.timeline appendTrack:self.mainAudioTrack];
    _mainAudioTrackClips = [[NSMutableArray alloc] init];
}

- (QHVCEditTrack *)getMainAudioTrack
{
    return self.mainAudioTrack;
}

- (void)deleteMainAudioTrack
{
    [self.timeline deleteTrackById:self.mainAudioTrack.trackId];
}

- (void)mainAudioTrackAppendClip:(QHVCEditTrackClipItem *)item
{
    if (!item) {
        return;
    }
    
    if (!self.mainAudioTrack) {
        [self createMainAudioTrack];
    }
    
    QHVCEditTrackClip *clip = [[QHVCEditTrackClip alloc] initClipWithTimeline:self.timeline];
    [clip setFilePath:item.filePath type:item.clipType];
    [clip setFileStartTime:0];
    [clip setFileEndTime:item.endMs];
    item.clip = clip;
    [self.mainAudioTrack addClip:clip atTime:item.insertMs];
    [self.mainAudioTrackClips addObject:item];
}

- (void)mainAudioTrackDeleteClip:(QHVCEditTrackClipItem *)item
{
    if (!item)
    {
        return;
    }
    
    [self.mainAudioTrack deleteClipById:item.clip.clipId];
    [self.mainAudioTrackClips removeObject:item];
}

- (void)mainAudioTrackDeleteAllClips
{
    [_mainAudioTrackClips enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [self mainAudioTrackDeleteClip:obj];
    }];
    
    [_mainAudioTrackClips removeAllObjects];
}

- (NSMutableArray<QHVCEditTrackClipItem *>*)getMainAduioTrackClips
{
    return self.mainAudioTrackClips;
}

- (void)setMainAduioTrackVolume:(NSInteger)volume
{
    if (self.mainAudioTrack)
    {
        [self.mainAudioTrack setVolume:volume];
    }
}

- (void)setMainAduioTrackPitch:(NSInteger)pitch
{
    if (self.mainAudioTrack)
    {
        [self.mainAudioTrackClips enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            [obj.clip setPitch:pitch];
        }];
    }
}

#pragma mark - player

- (QHVCEditPlayer *)createPlayerWithView:(UIView *)view delegate:(id<QHVCEditPlayerDelegate>)delegate
{
    QHVCEditPlayer* player = [[QHVCEditPlayer alloc] initWithTimeline:self.timeline];
    [player setDelegate:delegate];
    [player setPreview:view];
    return player;
}

- (void)freePlayer:(QHVCEditPlayer *)player
{
    [player free];
}

#pragma mark - thumbnail
    
- (QHVCEditError)requestThumbsFromFilePath:(NSString *)filePath
                                     start:(NSTimeInterval)startMs
                                       end:(NSTimeInterval)endMs
                                  frameCnt:(int)count
                                 thumbSize:(CGSize)size
                             thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback
{
    if (!_thumbnail) {
        _thumbnail = [[QHVCEditThumbnail alloc] init];
    }
    __block QHVCEditError error = QHVCEditErrorNoError;
    [_thumbnail requestThumbnailFromFilePath:filePath width:size.width height:size.height startTime:startMs endTime:endMs count:count dataCallback:^(QHVCEditThumbnailItem *thumbnail, QHVCEditError error) {
        if (error == QHVCEditErrorNoError) {
            SAFE_BLOCK(callback, thumbnail);
        }else{
            error = QHVCEditErrorStatusError;
        }
    }];
    
    return error;
}

- (QHVCEditError)requestThumbFromFilePath:(NSString *)filePath
                                timestamp:(NSTimeInterval)timeMs
                                thumbSize:(CGSize)size
                            thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback
{
    if (!_thumbnail) {
        _thumbnail = [[QHVCEditThumbnail alloc] init];
    }
    __block QHVCEditError error = QHVCEditErrorNoError;
    [_thumbnail requestThumbnailFromFilePath:filePath width:size.width height:size.height timestamp:timeMs dataCallback:^(QHVCEditThumbnailItem *thumbnail, QHVCEditError error)
    {
        if (error == QHVCEditErrorNoError)
        {
            SAFE_BLOCK(callback, thumbnail);
        }
        else
        {
            error = QHVCEditErrorStatusError;
        }
    }];
    
    return error;
}

- (QHVCEditError)requestThumbsFromFileIdentifier:(NSString *)fileIdentifier
                                           start:(NSTimeInterval)startMs
                                             end:(NSTimeInterval)endMs
                                        frameCnt:(int)count
                                       thumbSize:(CGSize)size
                                   thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback
{
    if (!_thumbnail)
    {
        _thumbnail = [[QHVCEditThumbnail alloc] init];
    }
    
    __block QHVCEditError error = QHVCEditErrorNoError;
    [_thumbnail requestThumbnailFromFileIdentifier:fileIdentifier
                                             width:size.width
                                            height:size.height
                                         startTime:startMs
                                           endTime:endMs
                                             count:count
                                      dataCallback:^(QHVCEditThumbnailItem *thumbnail, QHVCEditError error)
    {
        if (error == QHVCEditErrorNoError)
        {
            SAFE_BLOCK(callback, thumbnail);
        }
        else
        {
            error = QHVCEditErrorStatusError;
        }
    }];
    
    return error;
}

- (QHVCEditError)requestThumbFromFileIdentifier:(NSString *)fileIdentifier
                                      timestamp:(NSTimeInterval)timeMs
                                      thumbSize:(CGSize)size
                                  thumbCallback:(void (^)(QHVCEditThumbnailItem* thumbnail))callback
{
    if (!_thumbnail)
    {
        _thumbnail = [[QHVCEditThumbnail alloc] init];
    }
    
    __block QHVCEditError error = QHVCEditErrorNoError;
    [_thumbnail requestThumbnailFromFileIdentifier:fileIdentifier
                                             width:size.width
                                            height:size.height
                                         timestamp:timeMs
                                      dataCallback:^(QHVCEditThumbnailItem *thumbnail, QHVCEditError error)
     {
        if (error == QHVCEditErrorNoError)
        {
            SAFE_BLOCK(callback, thumbnail);
        }
        else
        {
            error = QHVCEditErrorStatusError;
        }
    }];
    
    return error;
}

- (QHVCEditError)cancelThumbnailRequest
{
    if (_thumbnail) {
        [_thumbnail cancelAllThumbnailRequest];
    }
    
    return QHVCEditErrorNoError;
}

- (QHVCEditError)freeThumbnailBuilder
{
    if (_thumbnail) {
        [_thumbnail free];
        _thumbnail = nil;
    }
    
    return QHVCEditErrorNoError;
}

#pragma mark - Producer

- (QHVCEditProducer *)createProducerWithDelegate:(id<QHVCEditProducerDelegate>)delegate
{
    QHVCEditProducer* producer = [[QHVCEditProducer alloc] initWithTimeline:self.timeline];
    [producer setDelegate:delegate];
    return producer;
}

- (void)freeProducer:(QHVCEditProducer *)producer
{
    [producer free];
}


@end
