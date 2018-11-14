//
//  QHVCEditCommandManager.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditCommandManager.h"
#import "QHVCEditPhotoItem.h"
#import "QHVCEditStickerIconView.h"
#import "QHVCEditAudioItem.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditSegmentItem.h"
#import "QHVCEditSubtitleItem.h"
#import "QHVCEditMatrixItem.h"
#import "QHVCEditOverlayItemPreview.h"

static QHVCEditCommandManager *manager = nil;

@interface QHVCEditCommandManager()
{
    
}
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *commandsArray;

@end

@implementation QHVCEditCommandManager

+ (instancetype)manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        [QHVCEditLog setSDKLogLevel:QHVCEditLogLevel_Debug];
        [QHVCEditLog setSDKLogLevelForFile:QHVCEditLogLevel_Debug];
        [QHVCEditLog writeLogToLocal:YES];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _commandsArray = [NSMutableArray array];
    }
    return self;
}

- (void)initCommandFactory
{
    [self freeCommandFactory];
    self.commandFactory = [[QHVCEditCommandFactory alloc] initCommandFactory];
    self.outputParams = [[QHVCEditOutputParams alloc] init];
    [self.outputParams setSize:CGSizeMake(kOutputVideoWidth, kOutputVideoHeight)];
    [self.outputParams setRenderMode:QHVCEditOutputRenderMode_AspectFit];
    self.commandFactory.defaultOutputParams = self.outputParams;
}

- (void)freeCommandFactory
{
    if (self.commandFactory)
    {
        [self.commandFactory freeCommandFactory];
        self.commandFactory = nil;
        [self.commandsArray removeAllObjects];
        [[QHVCEditPrefs sharedPrefs].matrixItems removeAllObjects];
    }
}

- (NSArray<NSDictionary *> *)fetchFiles
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    return cs;
}

- (void)fetchSegmentInfo:(QHVCEditSegmentInfoBlock)complete
{
    NSArray<QHVCEditSegmentInfo *>* segments = [self.commandFactory getSegmentInfo];
    __block NSInteger totoalDuration = 0;
    [segments enumerateObjectsUsingBlock:^(QHVCEditSegmentInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        totoalDuration += obj.segmentEndTime - obj.segmentStartTime;
    }];
    
    if (complete)
    {
        complete(segments, totoalDuration);
    }
}

- (QHVCEditSegmentInfo *)getOverlaySegmentInfo:(NSInteger)overlayCommandId
{
    return [self.commandFactory getOverlaySegmentInfo:overlayCommandId];
}

- (NSArray<QHVCEditCommandAddFileSegment *>*)getFileSegments
{
    NSMutableArray<QHVCEditCommandAddFileSegment *>* segments = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray<NSDictionary *>* cs = (NSArray<NSDictionary *>*)[self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSDictionary *c in cs)
    {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)c[@"object"];
        [segments addObject:cmd];
    }
    return segments;
}

- (void)deleteFile:(NSInteger)fileIndex
{
    QHVCEditCommandDeleteFile *deleteCommand = [[QHVCEditCommandDeleteFile alloc] initCommand:self.commandFactory];
    deleteCommand.fileIndex = fileIndex;
    [deleteCommand addCommand];
}

- (void)addFiles:(NSArray<QHVCEditPhotoItem *> *)files
{
    NSArray<NSDictionary *> *cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    NSInteger fileIndex = cs.count - 1;
    while (fileIndex >= 0) {
        [self deleteFile:fileIndex];
        fileIndex--;
    }

    if (cs.count > 0) {
        [self.commandsArray removeObjectsInArray:cs];
    }
    [self appendFiles:files];
}

- (void)appendFiles:(NSArray<QHVCEditPhotoItem *> *)files
{
    int i = 0;
    for (QHVCEditPhotoItem *item in files) {
        QHVCEditCommandAddFileSegment *addCommand = [[QHVCEditCommandAddFileSegment alloc] initCommand:self.commandFactory];
        addCommand.filePath = item.filePath;
        addCommand.photoFileIdentifier = item.photoFileIdentifier;
        addCommand.fileIndex = i;
        addCommand.durationMs = item.asset.mediaType == PHAssetMediaTypeImage ? (item.endMs - item.startMs) : 0;
        addCommand.slowMotionVideoInfos = item.slowMotionVideoInfos;
        addCommand.startTimestampMs = item.startMs;
        addCommand.endTimestampMs = item.endMs;
        [addCommand addCommand];
        NSDictionary *cmd = [self formatCommand:QHVCEditCommandOperationAddFile object:addCommand status:QHVCEditCommandStatusAdd];
        [self.commandsArray addObject:cmd];
        i++;
    }
}

- (void)fetchThumbs:(NSString *)filePath start:(NSTimeInterval)startMs end:(NSTimeInterval)endMs frameCnt:(int)count thumbSize:(CGSize)size completion:(void (^)(NSArray<QHVCEditThumbnailItem *> *thumbnails))completion
{
    if (!_thumbnailFactory) {
        _thumbnailFactory = [[QHVCEditThumbnail alloc] initThumbnailFactory];
    }
    NSMutableArray *ts = [NSMutableArray array];
    [_thumbnailFactory getVideoThumbnailFromFile:filePath width:size.width height:size.height startTime:startMs endTime:endMs count:count callback:^(NSArray<QHVCEditThumbnailItem *> *thumbnails, QHVCEditThumbnailCallbackState state) {
        if ((state != QHVCEditThumbnailCallbackState_Error) || (state != QHVCEditThumbnailCallbackState_Cancel))
        {
            [ts addObjectsFromArray:thumbnails];
            if (ts.count >= count) {
                if (completion) {
                    completion(ts);
                }
            }
        }
    }];
}

- (void)fetchPhotoFileThumbs:(NSString *)photoFileIdentifier start:(NSTimeInterval)startMs end:(NSTimeInterval)endMs frameCnt:(int)count thumbSize:(CGSize)size completion:(void (^)(NSArray<QHVCEditThumbnailItem *> *thumbnails))completion
{
    if (!_thumbnailFactory) {
        _thumbnailFactory = [[QHVCEditThumbnail alloc] initThumbnailFactory];
    }
    NSMutableArray *ts = [NSMutableArray array];
    [_thumbnailFactory getVideoThumbnailFromPhotoAlbum:photoFileIdentifier
                                                 width:size.width
                                                height:size.height
                                             startTime:startMs
                                               endTime:endMs
                                                 count:count
                                              callback:^(NSArray<QHVCEditThumbnailItem *> *thumbnails, QHVCEditThumbnailCallbackState state)
    {
        if ((state != QHVCEditThumbnailCallbackState_Error) || (state != QHVCEditThumbnailCallbackState_Cancel))
        {
            [ts addObjectsFromArray:thumbnails];
            if (ts.count >= count) {
                if (completion) {
                    completion(ts);
                }
            }
        }
    }];
}

- (NSDictionary *)formatCommand:(QHVCEditCommandOperation)command object:(id)object status:(QHVCEditCommandStatus)status
{
    return @{@"command":@(command),
             @"object":object,
             @"status":@(status)
             };
}

- (NSArray<NSDictionary *> *)filterCommand:(QHVCEditCommandOperation)command
{
    if (self.commandsArray.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"command =%@",@(command)];
        NSArray *cs = [self.commandsArray filteredArrayUsingPredicate:predicate];
        return cs;
    }
    return nil;
}

#pragma mark Quality

- (void)setQualityValue:(NSInteger)type value:(float)value command:(QHVCEditCommandQualityFilter *)cmd
{
    switch (type)
    {
        case 0:
        {
            //亮度
            cmd.brightnessValue = value;
            break;
        }
        case 1:
        {
            //对比度
            cmd.contrastValue = value;
            break;
        }
        case 2:
        {
            //曝光度
            cmd.exposureValue = value;
            break;
        }
        case 3:
        {
            //gamma补偿
            cmd.gammaOffsetValue = value;
            break;
        }
        case 4:
        {
            //色温
            cmd.temperatureValue = value;
            break;
        }
        case 5:
        {
            //色调
            cmd.tintValue = value;
            break;
        }
        case 6:
        {
            //饱和度
            cmd.saturationValue = value;
            break;
        }
        case 7:
        {
            //色相
            cmd.hueValue = value;
            break;
        }
        case 8:
        {
            //振动
            cmd.vibranceValue = value;
            break;
        }
        case 9:
        {
            //暗角
            cmd.vignetteValue = value;
            break;
        }
        case 10:
        {
            //色散
            cmd.prismValue = value;
            break;
        }
        case 11:
        {
            //褪色
            cmd.fadeValue = value;
            break;
        }
        case 12:
        {
            //高光减弱
            cmd.highlightValue = value;
            break;
        }
        case 13:
        {
            //阴影补偿
            cmd.shadowValue = value;
            break;
        }
        case 14:
        {
            //肤色
            cmd.skinValue = value;
            break;
        }
        case 15:
        {
            //锐度
            cmd.sharpenValue = value;
            break;
        }
        case 16:
        {
            //颗粒噪声
            cmd.filmGrainValue = value;
            break;
        }
        case 17:
        {
            //高光色调橙色
            cmd.highlightOrangeValue = value;
            break;
        }
        case 18:
        {
            //高光色调奶油色
            cmd.highlightCreamValue = value;
            break;
        }
        case 19:
        {
            //高光色调黄色
            cmd.highlightYellowValue = value;
            break;
        }
        case 20:
        {
            //高光色调绿色
            cmd.highlightGreenValue = value;
            break;
        }
        case 21:
        {
            //高光色调蓝色
            cmd.highlightBlueValue = value;
            break;
        }
        case 22:
        {
            //高光色调洋红色
            cmd.highlightMagentaValue = value;
            break;
        }
        case 23:
        {
            //阴影色调红色
            cmd.shadowRedValue = value;
            break;
        }
        case 24:
        {
            //阴影色调橙色
            cmd.shadowOrangeValue = value;
            break;
        }
        case 25:
        {
            //阴影色调黄色
            cmd.shadowYellowValue = value;
            break;
        }
        case 26:
        {
            //阴影色调绿色
            cmd.shadowGreenValue = value;
            break;
        }
        case 27:
        {
            //阴影色调蓝色
            cmd.shadowBlueValue = value;
            break;
        }
        case 28:
        {
            //阴影色调紫色
            cmd.shadowPurpleValue = value;
            break;
        }
        default:
            break;
    }
}

- (BOOL)adjustQuality:(NSInteger)type value:(float)value
{
    NSArray<NSDictionary *>* qs = [self filterCommand:QHVCEditCommandOperationAdjustQuality];
    if (qs.count > 0) {
        for (NSDictionary *q in qs) {
            QHVCEditCommandQualityFilter *cmd = (QHVCEditCommandQualityFilter *)q[@"object"];
            [self setQualityValue:type value:value command:cmd];
            [cmd editCommand];
        }
        return YES;
    }
    NSTimeInterval start = 0.0;
    
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSDictionary *c in cs) {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)c[@"object"];
        QHVCEditCommandQualityFilter *q = [[QHVCEditCommandQualityFilter alloc] initCommand:self.commandFactory];
        [self setQualityValue:type value:value command:q];
        q.startTimestampMs = start;
        q.endTimestampMs =  q.startTimestampMs +cmd.endTimestampMs;
        [q addCommand];
        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAdjustQuality object:q status:QHVCEditCommandStatusAdd]];
        start = q.endTimestampMs;
    }
    return YES;
}

#pragma mark Speed
- (void)adjustSpeed:(float)speed
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandAlterSpeed *command = [[QHVCEditCommandAlterSpeed alloc] initCommand:self.commandFactory];
        [command setFileIndex:i];
        [command setSpeed:speed];
        [command addCommand];
    }
    
    [self editAutiosSpeed:speed];
}

#pragma mark pitch
- (void)adjustPitch:(float)pitch
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandAlterPitch *command = [[QHVCEditCommandAlterPitch alloc] initCommand:self.commandFactory];
        [command setFileIndex:i];
        [command setPitch:pitch];
        [command addCommand];
    }
    
    [self editAutios:pitch];
    [self editOverlayPitch:pitch];
}

#pragma mark - 声音淡入淡出
- (void)audioFadeInFadeOut:(BOOL)onFadeInOut
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    if (onFadeInOut) {
        for (NSInteger i = 0; i < cs.count; i++) {
            
            QHVCEditCommandAudioFadeInOut *command = [[QHVCEditCommandAudioFadeInOut alloc] initCommand:self.commandFactory];
            QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)cs[i][@"object"];
            [command setMainIndex:i];
            [command setStartTimestampMs:0];
            [command setEndTimestampMs:(cmd.endTimestampMs - cmd.startTimestampMs)/2];
            [command setAudioFilterType:QHVCEditAudioFilterFadeIn];
            [command setFadeType:QHVCEditAudioFadeLog];
            
            [command addCommand];
            NSDictionary *cmdFade = [self formatCommand:QHVCEditCommandOperationAddFade object:command status:QHVCEditCommandStatusAdd];
            [self.commandsArray addObject:cmdFade];
        }
    }
    
    if (onFadeInOut) {
        for (NSInteger i = 0; i < cs.count; i++) {
            QHVCEditCommandAudioFadeInOut *command = [[QHVCEditCommandAudioFadeInOut alloc] initCommand:self.commandFactory];
            QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)cs[i][@"object"];
            NSTimeInterval timeInterval = cmd.endTimestampMs - cmd.startTimestampMs;
            NSTimeInterval timeStart = timeInterval/2;
            NSTimeInterval timeEnd = timeInterval;
            [command setMainIndex:i];
            [command setStartTimestampMs:timeStart];
            [command setEndTimestampMs:timeEnd];
            [command setAudioFilterType:QHVCEditAudioFilterFadeOut];
            [command setFadeType:QHVCEditAudioFadeLog];
            [command addCommand];
            NSDictionary *cmdFade = [self formatCommand:QHVCEditCommandOperationAddFade object:command status:QHVCEditCommandStatusAdd];
            [self.commandsArray addObject:cmdFade];
        }
    }
    
    NSArray<NSDictionary *>* overlay = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    if (onFadeInOut) {
        [overlay enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
             QHVCEditCommandAudioFadeInOut *command = [[QHVCEditCommandAudioFadeInOut alloc] initCommand:self.commandFactory];
             [command setOverlayCommandId:cmd.commandId];
             [command setStartTimestampMs:0];
             [command setEndTimestampMs:(cmd.endTimestampMs - cmd.startTimestampMs)/2];
             [command setAudioFilterType:QHVCEditAudioFilterFadeIn];
             [command setFadeType:QHVCEditAudioFadeLog];
             
             [command addCommand];
             NSDictionary *cmdFade = [self formatCommand:QHVCEditCommandOperationAddFade object:command status:QHVCEditCommandStatusAdd];
             [self.commandsArray addObject:cmdFade];
         }];
    }
    
    if (onFadeInOut) {
        [overlay enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
             NSTimeInterval timeInterval = cmd.endTimestampMs - cmd.startTimestampMs;
             NSTimeInterval timeStart = timeInterval/2;
             NSTimeInterval timeEnd = timeInterval;
             QHVCEditCommandAudioFadeInOut *command = [[QHVCEditCommandAudioFadeInOut alloc] initCommand:self.commandFactory];
             [command setOverlayCommandId:cmd.commandId];
             [command setStartTimestampMs:timeStart];
             [command setEndTimestampMs:timeEnd];
             [command setAudioFilterType:QHVCEditAudioFilterFadeOut];
             [command setFadeType:QHVCEditAudioFadeLog];
             
             [command addCommand];
             NSDictionary *cmdFade = [self formatCommand:QHVCEditCommandOperationAddFade object:command status:QHVCEditCommandStatusAdd];
             [self.commandsArray addObject:cmdFade];
         }];
    }
    
    NSArray<NSDictionary *>* audios = [self filterCommand:QHVCEditCommandOperationAddAudio];
    if (onFadeInOut) {
        for (NSDictionary *audio in audios) {
            QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)audio[@"object"];
            QHVCEditCommandAudioFadeInOut *command = [[QHVCEditCommandAudioFadeInOut alloc] initCommand:self.commandFactory];
            [command setOverlayCommandId:cmd.commandId];
            [command setStartTimestampMs:0];
            [command setEndTimestampMs:(cmd.endTime - cmd.startTime)/2];
            [command setAudioFilterType:QHVCEditAudioFilterFadeIn];
            [command setFadeType:QHVCEditAudioFadeLog];
            
            [command addCommand];
            NSDictionary *cmdFade = [self formatCommand:QHVCEditCommandOperationAddFade object:command status:QHVCEditCommandStatusAdd];
            [self.commandsArray addObject:cmdFade];
            }
    }
    
    if (onFadeInOut) {
        for (NSDictionary *audio in audios) {
            QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)audio[@"object"];
            NSTimeInterval timeInterval = cmd.startTime - cmd.endTime;
            NSTimeInterval timeStart = timeInterval/2;
            NSTimeInterval timeEnd = timeInterval;
            QHVCEditCommandAudioFadeInOut *command = [[QHVCEditCommandAudioFadeInOut alloc] initCommand:self.commandFactory];
            [command setOverlayCommandId:cmd.commandId];
            [command setStartTimestampMs:timeStart];
            [command setEndTimestampMs:timeEnd];
            [command setAudioFilterType:QHVCEditAudioFilterFadeIn];
            [command setFadeType:QHVCEditAudioFadeLog];
            
            [command addCommand];
            NSDictionary *cmdFade = [self formatCommand:QHVCEditCommandOperationAddFade object:command status:QHVCEditCommandStatusAdd];
            [self.commandsArray addObject:cmdFade];
        }
    }
    
    if (!onFadeInOut) {
        NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFade];
        for (NSDictionary *c in cs) {
            QHVCEditCommandAudioFadeInOut *cmd = (QHVCEditCommandAudioFadeInOut *)c[@"object"];
            [cmd deleteCommand];
        }
        if (cs.count > 0) {
            [self.commandsArray removeObjectsInArray:cs];
        }
    }
}

#pragma mark volume
- (void)adjustVolume:(float)volume
{
    [self adjustMainVolume:volume];
    [self editAutiosVolume:volume];
    [self editOverlayVolume:volume];
}

- (void)adjustMainVolume:(float)volume
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandAlterVolume *command = [[QHVCEditCommandAlterVolume alloc] initCommand:self.commandFactory];
        [command setFileIndex:i];
        [command setVolume:volume];
        [command addCommand];
    }
}

#pragma mark getAudios
- (NSArray *)getAudios
{
    NSArray<NSDictionary *>* audios = [self filterCommand:QHVCEditCommandOperationAddAudio];
    return audios;
}


#pragma mark Filter

- (void)addFilter:(NSDictionary *)item
{
    NSArray<NSDictionary *>* fs = [self filterCommand:QHVCEditCommandOperationAddFilter];
    if (fs.count > 0) {
        for (NSDictionary *f in fs) {
            QHVCEditCommandAuxFilter *cmd = (QHVCEditCommandAuxFilter *)f[@"object"];
            cmd.auxFilterType = [item[@"type"] intValue];
//            cmd.auxFilterInfo = item[@"color"];
            NSString* path = item[@"color"];
            cmd.clutImage = [UIImage imageNamed:path];
            [cmd editCommand];
            return;
        }
    }
    NSTimeInterval start = 0.0;
    
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSDictionary *c in cs) {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)c[@"object"];
        
        //滤镜
        QHVCEditCommandAuxFilter *f = [[QHVCEditCommandAuxFilter alloc] initCommand:self.commandFactory];
        f.auxFilterType = [item[@"type"] intValue];
//        f.auxFilterInfo = item[@"color"];
        NSString* path = item[@"color"];
        f.clutImage = [UIImage imageNamed:path];
        f.startTimestampMs = start;
        f.endTimestampMs =  f.startTimestampMs +cmd.endTimestampMs;
        [f addCommand];
        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddFilter object:f status:QHVCEditCommandStatusAdd]];
        start = f.endTimestampMs;
        
        //特效临时测试入口
//        QHVCEditCommandEffectFilter *f = [[QHVCEditCommandEffectFilter alloc] initCommand:self.commandFactory];
//        f.effectName = @"effect_6";
//        f.startTimestampMs = start;
//        f.endTimestampMs =  f.startTimestampMs +cmd.endTimestampMs;
//        [f addCommand];
//        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddFilter object:f status:QHVCEditCommandStatusAdd]];
//        start = f.endTimestampMs;
        
        //美颜临时测试入口
//        QHVCEditCommandBeauty *f = [[QHVCEditCommandBeauty alloc] initCommand:self.commandFactory];
//        f.softLevel = 1.0;
//        f.whiteLevel = 1.0;
//        f.startTimestampMs = start;
//        f.endTimestampMs =  f.startTimestampMs +cmd.endTimestampMs;
//        [f addCommand];
//        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddFilter object:f status:QHVCEditCommandStatusAdd]];
//        start = f.endTimestampMs;
    }
}

#pragma mark - Image Filter

- (QHVCEditCommandImageFilter *)addImageFilter:(UIImage *)image renderRect:(CGRect)renderRect radian:(CGFloat)radian
{
    NSTimeInterval duration = 0.0;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSDictionary* c in cs)
    {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)c[@"object"];
        duration = duration + cmd.endTimestampMs - cmd.startTimestampMs;
    }
    
    QHVCEditCommandImageFilter* f = [[QHVCEditCommandImageFilter alloc] initCommand:self.commandFactory];
    f.image = image;
    f.destinationX = renderRect.origin.x;
    f.destinationY = renderRect.origin.y;
    f.destinationWidth = renderRect.size.width;
    f.destinationHeight = renderRect.size.height;
    f.destinationRotateAngle = radian;
    f.startTimestampMs = 0;
    f.endTimestampMs = duration;
    [f addCommand];
    [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddImage object:f status:QHVCEditCommandStatusAdd]];
    return f;
}

- (void)updateImageFilter:(QHVCEditCommandImageFilter *)filterCommand renderRect:(CGRect)renderRect radian:(CGFloat)radian
{
    filterCommand.destinationX = renderRect.origin.x;
    filterCommand.destinationY = renderRect.origin.y;
    filterCommand.destinationWidth = renderRect.size.width;
    filterCommand.destinationHeight = renderRect.size.height;
    filterCommand.destinationRotateAngle = radian;
    [filterCommand editCommand];
}

- (void)deleteImageFilter:(QHVCEditCommandImageFilter *)filterCommand
{
    [filterCommand deleteCommand];
}

- (void)addImageFadeInOut:(QHVCEditCommandImageFilter *)filterCommand
{
    NSTimeInterval duration = filterCommand.endTimestampMs - filterCommand.startTimestampMs;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
    fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
    fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    NSArray* animations = @[fadeIn, fadeOut];
    [filterCommand setAnimation:animations];
    [filterCommand editCommand];
}

- (void)addImageMoveInOut:(QHVCEditCommandImageFilter *)filterCommand
{
    NSTimeInterval duration = filterCommand.endTimestampMs - filterCommand.startTimestampMs;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    QHVCEditCommandAnimation* moveIn = [[QHVCEditCommandAnimation alloc] init];
    moveIn.animationType = QHVCEditCommandAnimationType_OffsetX;
    moveIn.curveType = QHVCEditCommandAnimationCurveType_Curve;
    moveIn.startTime = 0;
    moveIn.endTime = lastTime;
    moveIn.startValue = -kOutputVideoWidth/10.0;
    moveIn.endValue = 0;
    
    QHVCEditCommandAnimation* moveOut = [[QHVCEditCommandAnimation alloc] init];
    moveOut.animationType = QHVCEditCommandAnimationType_OffsetX;
    moveOut.curveType = QHVCEditCommandAnimationCurveType_Curve;
    moveOut.startTime = duration - lastTime;
    moveOut.endTime = duration;
    moveOut.startValue = 0;
    moveOut.endValue = kOutputVideoWidth/10.0;
    
    QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
    fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeIn.curveType = QHVCEditCommandAnimationCurveType_Curve;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
    fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeOut.curveType = QHVCEditCommandAnimationCurveType_Curve;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    QHVCEditCommandAnimation* scaleIn = [[QHVCEditCommandAnimation alloc] init];
    scaleIn.animationType = QHVCEditCommandAnimationType_Scale;
    scaleIn.curveType = QHVCEditCommandAnimationCurveType_Curve;
    scaleIn.startTime = 0;
    scaleIn.endTime = lastTime;
    scaleIn.startValue = 0.6;
    scaleIn.endValue = 1.0;
    
    QHVCEditCommandAnimation* scaleOut = [[QHVCEditCommandAnimation alloc] init];
    scaleOut.animationType = QHVCEditCommandAnimationType_Scale;
    scaleOut.curveType = QHVCEditCommandAnimationCurveType_Curve;
    scaleOut.startTime = duration - lastTime;
    scaleOut.endTime = duration;
    scaleOut.startValue = 1.0;
    scaleOut.endValue = 0.6;
    
    NSArray* animations = @[moveIn, moveOut, scaleIn, scaleOut, fadeIn, fadeOut];
    [filterCommand setAnimation:animations];
    [filterCommand editCommand];
}

- (void)addImageJumpInOut:(QHVCEditCommandImageFilter *)filterCommand
{
    NSTimeInterval duration = filterCommand.endTimestampMs - filterCommand.startTimestampMs;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    
    QHVCEditCommandAnimation* jumpIn = [[QHVCEditCommandAnimation alloc] init];
    jumpIn.animationType = QHVCEditCommandAnimationType_OffsetY;
    jumpIn.startTime = 0;
    jumpIn.endTime = lastTime;
    jumpIn.startValue = kOutputVideoHeight/10.0;
    jumpIn.endValue = 0;
    
    QHVCEditCommandAnimation* jumpOut = [[QHVCEditCommandAnimation alloc] init];
    jumpOut.animationType = QHVCEditCommandAnimationType_OffsetY;
    jumpOut.startTime = duration - lastTime;
    jumpOut.endTime = duration;
    jumpOut.startValue = 0;
    jumpOut.endValue = -kOutputVideoHeight/10.0;
    
    QHVCEditCommandAnimation* scaleIn = [[QHVCEditCommandAnimation alloc] init];
    scaleIn.animationType = QHVCEditCommandAnimationType_Scale;
    scaleIn.startTime = 0;
    scaleIn.endTime = lastTime;
    scaleIn.startValue = 0.1;
    scaleIn.endValue = 1.0;
    
    QHVCEditCommandAnimation* scaleOut = [[QHVCEditCommandAnimation alloc] init];
    scaleOut.animationType = QHVCEditCommandAnimationType_Scale;
    scaleOut.startTime = duration - lastTime;
    scaleOut.endTime = duration;
    scaleOut.startValue = 1.0;
    scaleOut.endValue = 0.1;
    
    QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
    fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
    fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    NSArray* animations = @[jumpIn, jumpOut, scaleIn, scaleOut, fadeIn, fadeOut];
    [filterCommand setAnimation:animations];
    [filterCommand editCommand];
}

- (void)addImageRotateInOut:(QHVCEditCommandImageFilter *)filterCommand
{
    NSTimeInterval duration = filterCommand.endTimestampMs - filterCommand.startTimestampMs;
    NSTimeInterval lastTime = MIN(500, duration/2.0);
    
    QHVCEditCommandAnimation* rotateIn = [[QHVCEditCommandAnimation alloc] init];
    rotateIn.animationType = QHVCEditCommandAnimationType_Radian;
    rotateIn.startTime = 0;
    rotateIn.endTime = lastTime;
    rotateIn.startValue = 30.0/180.0*M_PI;
    rotateIn.endValue = 0;
    
    QHVCEditCommandAnimation* rotateOut = [[QHVCEditCommandAnimation alloc] init];
    rotateOut.animationType = QHVCEditCommandAnimationType_Radian;
    rotateOut.startTime = duration - lastTime;
    rotateOut.endTime = duration;
    rotateOut.startValue = 0;
    rotateOut.endValue = -30./180.0*M_PI;
    
    QHVCEditCommandAnimation* scaleIn = [[QHVCEditCommandAnimation alloc] init];
    scaleIn.animationType = QHVCEditCommandAnimationType_Scale;
    scaleIn.startTime = 0;
    scaleIn.endTime = lastTime;
    scaleIn.startValue = 1.2;
    scaleIn.endValue = 1.0;
    
    QHVCEditCommandAnimation* scaleOut = [[QHVCEditCommandAnimation alloc] init];
    scaleOut.animationType = QHVCEditCommandAnimationType_Scale;
    scaleOut.startTime = duration - lastTime;
    scaleOut.endTime = duration;
    scaleOut.startValue = 1.0;
    scaleOut.endValue = 1.2;
    
    QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
    fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeIn.startTime = 0;
    fadeIn.endTime = lastTime;
    fadeIn.startValue = 0;
    fadeIn.endValue = 1.0;
    
    QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
    fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
    fadeOut.startTime = duration - lastTime;
    fadeOut.endTime = duration;
    fadeOut.startValue = 1.0;
    fadeOut.endValue = 0;
    
    NSArray* animations = @[rotateIn, rotateOut, scaleIn, scaleOut, fadeIn, fadeOut];
    [filterCommand setAnimation:animations];
    [filterCommand editCommand];
}

#pragma mark Audio

- (void)addAudios:(NSArray<QHVCEditAudioItem *> *)audios
{
    for (QHVCEditAudioItem *item in audios) {
        if (item.audiofile.length > 0) {
            if (item.insertStartTimeMs >= item.insertEndTimeMs ||
                item.startTimeMs >= item.audioDuration) {
                continue;
            }
            QHVCEditCommandAudio *a = [[QHVCEditCommandAudio alloc]initCommand:self.commandFactory];
            NSString* filePath = [[NSBundle mainBundle] pathForResource:item.audiofile ofType:@"mp3"];
            if (!filePath) {
                filePath = [[NSBundle mainBundle] pathForResource:item.audiofile ofType:@"mp4"];
            }
            if (filePath.length <= 0) {
                continue;
            }
            a.filePath = filePath;
            a.startTime = item.startTimeMs;
            a.endTime = item.audioDuration;
            a.insertStartTime = item.insertStartTimeMs;
            a.insertEndTime = item.insertEndTimeMs;
            a.volume = item.volume;
            a.speed = 1.0f;
            a.loop = (a.endTime - a.startTime) > (a.insertEndTime - a.insertStartTime)?NO:YES;
            [a addCommand];
            [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddAudio object:a status:QHVCEditCommandStatusAdd]];
        }
        else
        {
            NSArray<NSDictionary *>* cs = [self fetchFiles];
            for (NSInteger i = 0; i < cs.count; i++) {
                QHVCEditCommandAlterVolume *cmd = [[QHVCEditCommandAlterVolume alloc]initCommand:self.commandFactory];
                cmd.fileIndex = i;
                cmd.volume = item.volume;
                [cmd addCommand];
            }
        }
    }
}

- (void)updateAudios
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddAudio];
    if (cs.count > 0) {
//        [self.commandsArray removeObjectsInArray:cs];
    }
}

- (void)editAutios:(int)pitch
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddAudio];
    for (NSDictionary *c in cs) {
        QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)c[@"object"];
        [cmd setPitch:pitch];
        [cmd editCommand];
    }
}

- (void)editAutiosSpeed:(int)speed
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddAudio];
    for (NSDictionary *c in cs) {
        QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)c[@"object"];
        [cmd setSpeed:speed];
        [cmd editCommand];
    }
}

- (void)editAutiosVolume:(int)volume
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddAudio];
    for (NSDictionary *c in cs) {
        QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)c[@"object"];
        [cmd setVolume:volume];
        [cmd editCommand];
    }
}

- (void)deleteAudios
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddAudio];
    for (NSDictionary *c in cs) {
        QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)c[@"object"];
        [cmd deleteCommand];
    }
    if (cs.count > 0) {
        [self.commandsArray removeObjectsInArray:cs];
    }
}

#define kTransferDuration 2000

#pragma mark Transfer
- (void)addTransfers:(NSArray<QHVCEditSegmentItem *> *)transfers
{
    NSInteger i = 0;
    for (QHVCEditSegmentItem *item in transfers) {
        
        if(i+1 >= transfers.count)
        {
            return;
        }
        QHVCEditSegmentItem *originalSegment = transfers[i+1];

        if (item.transferIndex == 0) {
             [self deleteFile:i+1];
            
            QHVCEditCommandAddFileSegment *fileCommand = [[QHVCEditCommandAddFileSegment alloc] initCommand:self.commandFactory];
            fileCommand.filePath = originalSegment.filePath;
            fileCommand.fileIndex = i+1;
            fileCommand.durationMs = [self isFilePhoto:originalSegment.filePath] ? kImageFileDurationMS : 0;
            fileCommand.slowMotionVideoInfos = originalSegment.slowMotionVideoInfos;
            fileCommand.startTimestampMs = originalSegment.segmentStartTime;
            fileCommand.endTimestampMs = originalSegment.segmentEndTime;
            [fileCommand addCommand];
            
            [self recoverEffect:i+1];
        }
        else
        {
            [self deleteFile:i+1];
            
            QHVCEditCommandOverlaySegment *overlaySegment = [[QHVCEditCommandOverlaySegment alloc]initCommand:self.commandFactory];
            overlaySegment.filePath = originalSegment.filePath;
            overlaySegment.durationMs = [self isFilePhoto:originalSegment.filePath] ? kImageFileDurationMS : 0;
            overlaySegment.slowMotionVideoInfos = originalSegment.slowMotionVideoInfos;
            overlaySegment.startTimestampMs = 0.0;
            overlaySegment.endTimestampMs = kTransferDuration;
            overlaySegment.insertTimestampMs = MAX(originalSegment.segmentStartTime - kTransferDuration, 0);
            [overlaySegment addCommand];
            
            if (originalSegment.fileDuration > kTransferDuration) {
                QHVCEditCommandAddFileSegment *fileCommand = [[QHVCEditCommandAddFileSegment alloc] initCommand:self.commandFactory];
                fileCommand.filePath = originalSegment.filePath;
                fileCommand.fileIndex = i+1;
                fileCommand.durationMs = overlaySegment.durationMs;
                fileCommand.slowMotionVideoInfos = overlaySegment.slowMotionVideoInfos;
                fileCommand.startTimestampMs = kTransferDuration;
                fileCommand.endTimestampMs = originalSegment.fileDuration;
                [fileCommand addCommand];
                
                [self recoverEffect:i+1];
            }
            
            QHVCEditCommandTransition *transferCommand = [[QHVCEditCommandTransition alloc]initCommand:self.commandFactory];
            transferCommand.overlayCommandId = overlaySegment.commandId;
            transferCommand.transitionName = item.transferName;
            transferCommand.startTimestampMs = MAX(originalSegment.segmentStartTime - kTransferDuration, 0) ;
            transferCommand.endTimestampMs = originalSegment.segmentStartTime;
            [transferCommand addCommand];
        }
        i++;
    }
}

- (BOOL)isFilePhoto:(NSString *)filePath
{
    return [QHVCEditGetFileInfo getFileInfo:filePath].isPicture;
}

#pragma mark Tailor

- (void)updateOutputSize:(CGSize)size
{
    [self.outputParams setSize:size];
}

- (void)updateOutputRenderMode:(QHVCEditOutputRenderMode)renderMode
{
    [self.outputParams setRenderMode:renderMode];
}

- (void)updateOutputBackgroudMode:(NSString *)colorHex
{
    if ([colorHex isEqualToString:@"blur"])
    {
        self.outputParams.backgroundMode = QHVCEditOutputBackgroundMode_Blur;
    }
    else
    {
        self.outputParams.backgroundMode = QHVCEditOutputBackgroundMode_Color;
        self.outputParams.backgroundInfo = colorHex;
    }
}

- (void)recoverEffect:(NSInteger)index
{
    if (index == -1) {
        //recover all file effect
    }
    else
    {
        QHVCEditCommandOperation operation = QHVCEditCommandOperationAdjustQuality;
        for (NSInteger i = operation; i < QHVCEditCommandOperationAddMosaic; i++) {
            NSArray<NSDictionary *> *cs = [self filterCommand:i];
            if (i == QHVCEditCommandOperationAddAudio||
                i == QHVCEditCommandOperationAddMosaic) {
                
                NSTimeInterval start = 0;
                NSTimeInterval end = 0;
                
                NSArray<NSDictionary *> *fs = [self filterCommand:QHVCEditCommandOperationAddFile];
                for (NSInteger i = 0;i <= index;i++) {
                    NSDictionary *f = fs[i];
                    QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)f[@"object"];
                    start = end;
                    end = start + cmd.endTimestampMs - cmd.startTimestampMs;
                }
                for (NSDictionary *c in cs) {
                    QHVCEditCommandAudio *cmd = (QHVCEditCommandAudio *)c[@"object"];
                    if ((cmd.insertStartTime > start && cmd.insertStartTime < end)||
                        (cmd.insertEndTime > start && cmd.insertEndTime < end)) {
                        [cmd addCommand];
                    }
                }
            }
            if (cs.count > index) {
                QHVCEditCommand *cmd = cs[index][@"object"];
                [cmd addCommand];
            }
        }
    }
}

#pragma mark - Overlay

- (NSInteger)addOverlayFile:(QHVCEditPhotoItem *)file
{
    QHVCEditCommandOverlaySegment* cmd = [[QHVCEditCommandOverlaySegment alloc] initCommand:self.commandFactory];
    cmd.filePath = file.filePath;
    cmd.photoFileIdentifier = file.photoFileIdentifier;
    cmd.durationMs = file.endMs - file.startMs;
    cmd.slowMotionVideoInfos = file.slowMotionVideoInfos;
    cmd.startTimestampMs = file.asset.mediaType == PHAssetMediaTypeImage ? 0 : file.startMs;
    cmd.endTimestampMs = file.asset.mediaType == PHAssetMediaTypeImage ? 0 : file.endMs;
    cmd.insertTimestampMs = 0;
    cmd.slowMotionVideoInfos = file.slowMotionVideoInfos;
    [cmd addCommand];
    
    NSDictionary *command = [self formatCommand:QHVCEditCommandOperationAddOverlay object:cmd status:QHVCEditCommandStatusAdd];
    [self.commandsArray addObject:command];
    
    //just for test
    QHVCEditSegmentInfo* info = [self getOverlaySegmentInfo:cmd.commandId];
    
    return cmd.commandId;
}

- (void)updateOverlayFile:(QHVCEditPhotoItem *)file overlayId:(NSInteger)overlayId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
        if (cmd.commandId == overlayId)
        {
            cmd.filePath = file.filePath;
            cmd.durationMs = file.endMs - file.startMs;
            cmd.startTimestampMs = file.asset.mediaType == PHAssetMediaTypeImage ? 0 : file.startMs;
            cmd.endTimestampMs = file.asset.mediaType == PHAssetMediaTypeImage ? 0 : file.endMs;
            cmd.insertTimestampMs = 0;
            [cmd editCommand];
            *stop = YES;
        }
    }];
}

- (void)editOverlayPitch:(int)pitch
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
         cmd.pitch = pitch;
         [cmd editCommand];
     }];
}

- (void)editOverlayVolume:(int)volume
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
         cmd.volume = volume;
         [cmd editCommand];
     }];
}

- (void)deleteOverlayFile:(NSInteger)overlayId
{
    __block NSDictionary* command = nil;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
         if (cmd.commandId == overlayId)
         {
             command = obj;
             [cmd deleteCommand];
             *stop = YES;
         }
     }];
    
    [self.commandsArray removeObject:command];
}

- (void)updateOverlaySpeed:(CGFloat)speed overlayId:(NSInteger)overlayId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
         if (cmd.commandId == overlayId)
         {
             cmd.speed = speed;
             [cmd editCommand];
             *stop = YES;
         }
     }];
}

- (void)updateOverlayVolume:(CGFloat)volume overlayId:(NSInteger)overlayId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
         if (cmd.commandId == overlayId)
         {
             cmd.volume = volume;
             [cmd editCommand];
             *stop = YES;
         }
     }];
}

- (void)addOverlayFadeInOut:(NSInteger)overlayId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMatrix];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandMatrixFilter *cmd = (QHVCEditCommandMatrixFilter *)obj[@"object"];
         if (cmd.overlayCommandId == overlayId)
         {
             NSTimeInterval duration = cmd.endTimestampMs - cmd.startTimestampMs;
             NSTimeInterval lastTime = MIN(500, duration/2.0);
             QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
             fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeIn.startTime = 0;
             fadeIn.endTime = lastTime;
             fadeIn.startValue = 0;
             fadeIn.endValue = 1.0;
             
             QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
             fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeOut.startTime = duration - lastTime;
             fadeOut.endTime = duration;
             fadeOut.startValue = 1.0;
             fadeOut.endValue = 0;
             
             NSArray* animations = @[fadeIn, fadeOut];
             [cmd setAnimation:animations];
             
             [cmd editCommand];
             *stop = YES;
         }
     }];
}

- (void)addOverlayMoveInOut:(NSInteger)overlayId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMatrix];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandMatrixFilter* cmd = (QHVCEditCommandMatrixFilter *)obj[@"object"];
         if (cmd.overlayCommandId == overlayId)
         {
             NSTimeInterval duration = cmd.endTimestampMs - cmd.startTimestampMs;
             NSTimeInterval lastTime = MIN(500, duration/2.0);
             QHVCEditCommandAnimation* moveIn = [[QHVCEditCommandAnimation alloc] init];
             moveIn.animationType = QHVCEditCommandAnimationType_OffsetX;
             moveIn.curveType = QHVCEditCommandAnimationCurveType_Curve;
             moveIn.startTime = 0;
             moveIn.endTime = lastTime;
             moveIn.startValue = -kOutputVideoWidth/10.0;
             moveIn.endValue = 0;
             
             QHVCEditCommandAnimation* moveOut = [[QHVCEditCommandAnimation alloc] init];
             moveOut.animationType = QHVCEditCommandAnimationType_OffsetX;
             moveOut.curveType = QHVCEditCommandAnimationCurveType_Curve;
             moveOut.startTime = duration - lastTime;
             moveOut.endTime = duration;
             moveOut.startValue = 0;
             moveOut.endValue = kOutputVideoWidth/10.0;
             
             QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
             fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeIn.curveType = QHVCEditCommandAnimationCurveType_Curve;
             fadeIn.startTime = 0;
             fadeIn.endTime = lastTime;
             fadeIn.startValue = 0;
             fadeIn.endValue = 1.0;
             
             QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
             fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeOut.curveType = QHVCEditCommandAnimationCurveType_Curve;
             fadeOut.startTime = duration - lastTime;
             fadeOut.endTime = duration;
             fadeOut.startValue = 1.0;
             fadeOut.endValue = 0;
             
             QHVCEditCommandAnimation* scaleIn = [[QHVCEditCommandAnimation alloc] init];
             scaleIn.animationType = QHVCEditCommandAnimationType_Scale;
             scaleIn.curveType = QHVCEditCommandAnimationCurveType_Curve;
             scaleIn.startTime = 0;
             scaleIn.endTime = lastTime;
             scaleIn.startValue = 0.6;
             scaleIn.endValue = 1.0;
             
             QHVCEditCommandAnimation* scaleOut = [[QHVCEditCommandAnimation alloc] init];
             scaleOut.animationType = QHVCEditCommandAnimationType_Scale;
             scaleOut.curveType = QHVCEditCommandAnimationCurveType_Curve;
             scaleOut.startTime = duration - lastTime;
             scaleOut.endTime = duration;
             scaleOut.startValue = 1.0;
             scaleOut.endValue = 0.6;
             
             NSArray* animations = @[moveIn, moveOut, scaleIn, scaleOut, fadeIn, fadeOut];
             [cmd setAnimation:animations];
             
             [cmd editCommand];
             *stop = YES;
         }
    }];
}

- (void)addOverlayJumpInOut:(NSInteger)overlayId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMatrix];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandMatrixFilter* cmd = (QHVCEditCommandMatrixFilter *)obj[@"object"];
         if (cmd.overlayCommandId == overlayId)
         {
             NSTimeInterval duration = cmd.endTimestampMs - cmd.startTimestampMs;
             NSTimeInterval lastTime = MIN(500, duration/2.0);
             
             QHVCEditCommandAnimation* jumpIn = [[QHVCEditCommandAnimation alloc] init];
             jumpIn.animationType = QHVCEditCommandAnimationType_OffsetY;
             jumpIn.startTime = 0;
             jumpIn.endTime = lastTime;
             jumpIn.startValue = kOutputVideoHeight/10.0;
             jumpIn.endValue = 0;
             
             QHVCEditCommandAnimation* jumpOut = [[QHVCEditCommandAnimation alloc] init];
             jumpOut.animationType = QHVCEditCommandAnimationType_OffsetY;
             jumpOut.startTime = duration - lastTime;
             jumpOut.endTime = duration;
             jumpOut.startValue = 0;
             jumpOut.endValue = -kOutputVideoHeight/10.0;
             
             QHVCEditCommandAnimation* scaleIn = [[QHVCEditCommandAnimation alloc] init];
             scaleIn.animationType = QHVCEditCommandAnimationType_Scale;
             scaleIn.startTime = 0;
             scaleIn.endTime = lastTime;
             scaleIn.startValue = 0.1;
             scaleIn.endValue = 1.0;
             
             QHVCEditCommandAnimation* scaleOut = [[QHVCEditCommandAnimation alloc] init];
             scaleOut.animationType = QHVCEditCommandAnimationType_Scale;
             scaleOut.startTime = duration - lastTime;
             scaleOut.endTime = duration;
             scaleOut.startValue = 1.0;
             scaleOut.endValue = 0.1;
             
             QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
             fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeIn.startTime = 0;
             fadeIn.endTime = lastTime;
             fadeIn.startValue = 0;
             fadeIn.endValue = 1.0;
             
             QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
             fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeOut.startTime = duration - lastTime;
             fadeOut.endTime = duration;
             fadeOut.startValue = 1.0;
             fadeOut.endValue = 0;
             
             NSArray* animations = @[jumpIn, jumpOut, scaleIn, scaleOut, fadeIn, fadeOut];
             [cmd setAnimation:animations];
             
             [cmd editCommand];
             *stop = YES;
         }
    }];
}

- (void)addOverlayRotateInOut:(NSInteger)overlayId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMatrix];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandMatrixFilter* cmd = (QHVCEditCommandMatrixFilter *)obj[@"object"];
         if (cmd.overlayCommandId == overlayId)
         {
             NSTimeInterval duration = cmd.endTimestampMs - cmd.startTimestampMs;
             NSTimeInterval lastTime = MIN(500, duration/2.0);
             
             QHVCEditCommandAnimation* rotateIn = [[QHVCEditCommandAnimation alloc] init];
             rotateIn.animationType = QHVCEditCommandAnimationType_Radian;
             rotateIn.startTime = 0;
             rotateIn.endTime = lastTime;
             rotateIn.startValue = 30.0/180.0*M_PI;
             rotateIn.endValue = 0;
             
             QHVCEditCommandAnimation* rotateOut = [[QHVCEditCommandAnimation alloc] init];
             rotateOut.animationType = QHVCEditCommandAnimationType_Radian;
             rotateOut.startTime = duration - lastTime;
             rotateOut.endTime = duration;
             rotateOut.startValue = 0;
             rotateOut.endValue = -30./180.0*M_PI;
             
             QHVCEditCommandAnimation* scaleIn = [[QHVCEditCommandAnimation alloc] init];
             scaleIn.animationType = QHVCEditCommandAnimationType_Scale;
             scaleIn.startTime = 0;
             scaleIn.endTime = lastTime;
             scaleIn.startValue = 1.2;
             scaleIn.endValue = 1.0;
             
             QHVCEditCommandAnimation* scaleOut = [[QHVCEditCommandAnimation alloc] init];
             scaleOut.animationType = QHVCEditCommandAnimationType_Scale;
             scaleOut.startTime = duration - lastTime;
             scaleOut.endTime = duration;
             scaleOut.startValue = 1.0;
             scaleOut.endValue = 1.2;
             
             QHVCEditCommandAnimation* fadeIn = [[QHVCEditCommandAnimation alloc] init];
             fadeIn.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeIn.startTime = 0;
             fadeIn.endTime = lastTime;
             fadeIn.startValue = 0;
             fadeIn.endValue = 1.0;
             
             QHVCEditCommandAnimation* fadeOut = [[QHVCEditCommandAnimation alloc] init];
             fadeOut.animationType = QHVCEditCommandAnimationType_Alpha;
             fadeOut.startTime = duration - lastTime;
             fadeOut.endTime = duration;
             fadeOut.startValue = 1.0;
             fadeOut.endValue = 0;
             
             NSArray* animations = @[rotateIn, rotateOut, scaleIn, scaleOut, fadeIn, fadeOut];
             [cmd setAnimation:animations];
             
             [cmd editCommand];
             *stop = YES;
         }
     }];
}

- (void)addOverlayBlendMode:(NSInteger)overlayId blendMode:(NSInteger)blendMode progres:(CGFloat)progress
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMatrix];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandMatrixFilter *cmd = (QHVCEditCommandMatrixFilter *)obj[@"object"];
         if (cmd.overlayCommandId == overlayId)
         {
             [cmd setBlendType:blendMode];
             [cmd setBlendProgress:progress];
             [cmd editCommand];
             *stop = YES;
         }
     }];
}

#pragma mark - Matrix

- (void)addMatrix:(QHVCEditMatrixItem *)item
{
    if (item.overlayCommandId == kMainTrackId)
    {
        NSTimeInterval start = 0.0;
        NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
        for (NSDictionary *c in cs) {
            QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)c[@"object"];
            QHVCEditCommandMatrixFilter *f = [[QHVCEditCommandMatrixFilter alloc] initCommand:self.commandFactory];
            f.overlayCommandId = kMainTrackId;
            f.frameRotateAngle = item.frameRadian;
            f.flipX = item.flipX;
            f.flipY = item.flipY;
            f.renderRect = item.renderRect;
            f.sourceRect = item.sourceRect;
            f.renderZOrder = item.zOrder;
            f.outputParams = item.outputParams;
            f.startTimestampMs = start;
            f.endTimestampMs =  f.startTimestampMs + (cmd.endTimestampMs - cmd.startTimestampMs);
            [f addCommand];
            
            [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddMatrix object:f status:QHVCEditCommandStatusAdd]];
            start = f.endTimestampMs;
        }
    }
    else
    {
        QHVCEditCommandMatrixFilter* cmd = [[QHVCEditCommandMatrixFilter alloc] initCommand:self.commandFactory];
        cmd.overlayCommandId = item.overlayCommandId;
        cmd.frameRotateAngle = item.frameRadian;
        cmd.previewRotateAngle = item.previewRadian;
        cmd.flipX = item.flipX;
        cmd.flipY = item.flipY;
        cmd.renderRect = item.renderRect;
        cmd.sourceRect = item.sourceRect;
        cmd.renderZOrder = item.zOrder;
        cmd.outputParams = item.outputParams;
        cmd.startTimestampMs = item.startTimestampMs;
        cmd.endTimestampMs = item.endTiemstampMs;
        [cmd addCommand];
        
        NSDictionary *command = [self formatCommand:QHVCEditCommandOperationAddMatrix object:cmd status:QHVCEditCommandStatusAdd];
        [self.commandsArray addObject:command];
    }
}

- (void)updateMatrix:(QHVCEditMatrixItem *)item
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMatrix];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandMatrixFilter *cmd = (QHVCEditCommandMatrixFilter *)obj[@"object"];
         if (cmd.overlayCommandId == item.overlayCommandId)
         {
             cmd.frameRotateAngle = item.frameRadian;
             cmd.previewRotateAngle = item.previewRadian;
             cmd.flipX = item.flipX;
             cmd.flipY = item.flipY;
             cmd.renderRect = item.renderRect;
             cmd.sourceRect = item.sourceRect;
             cmd.renderZOrder = item.zOrder;
             cmd.outputParams = item.outputParams;
             if (item.overlayCommandId != kMainTrackId)
             {
                 cmd.startTimestampMs = item.startTimestampMs;
                 cmd.endTimestampMs = item.endTiemstampMs;
                 *stop = YES;
             }
             [cmd editCommand];
         }
     }];
}

- (void)deleteMatrix:(QHVCEditMatrixItem *)item
{
    __block NSDictionary* command = nil;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMatrix];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandMatrixFilter *cmd = (QHVCEditCommandMatrixFilter *)obj[@"object"];
         if (cmd.overlayCommandId == item.overlayCommandId)
         {
             command = obj;
             [cmd deleteCommand];
             if (item.overlayCommandId != kMainTrackId)
             {
                *stop = YES;
             }
         }
     }];
    
    [self.commandsArray removeObject:command];
}

- (void)addChromakeyWithColor:(NSString*)argb
                    threshold:(int)threshold
                       extend:(int)extend
             overlayCommandId:(NSInteger)overlayCommandId
             startTimestampMs:(int)startTimestampMs
               endTimestampMs:(int)endTimestampMs
{
    QHVCEditCommandChromakey* cmd = [[QHVCEditCommandChromakey alloc] initCommand:self.commandFactory];
    cmd.overlayCommandId = overlayCommandId;
    cmd.color = argb;
    cmd.threshold = threshold;
    cmd.startTimestampMs = startTimestampMs;
    cmd.endTimestampMs = endTimestampMs;
    [cmd addCommand];
    
    NSDictionary *command = [self formatCommand:QHVCEditCommandOperationAddChromakey object:cmd status:QHVCEditCommandStatusAdd];
    [self.commandsArray addObject:command];
}

- (void)updateChromakeyWithColor:(NSString*)argb threshold:(int)threshold extend:(int)extend overlayCommandId:(NSInteger)overlayCommandId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddChromakey];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandChromakey *cmd = (QHVCEditCommandChromakey *)obj[@"object"];
         if (cmd.overlayCommandId == overlayCommandId)
         {
             cmd.color = argb;
             cmd.threshold = threshold;
             [cmd editCommand];
             *stop = YES;
         }
     }];
}

- (void)deleteChromakey:(NSInteger)overlayCommandId
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddChromakey];
    [cs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandChromakey *cmd = (QHVCEditCommandChromakey *)obj[@"object"];
         if (cmd.overlayCommandId == overlayCommandId)
         {
             [cmd deleteCommand];
             [self.commandsArray removeObject:obj];
             *stop = YES;
         }
     }];
}

#pragma mark 美颜
- (void)openBeauty:(float)softLevel white:(float)whiteLevel
{
    
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    float startFile = 0.0f;
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)cs[i][@"object"];
        QHVCEditCommandBeauty *f = [[QHVCEditCommandBeauty alloc] initCommand:self.commandFactory];
        f.overlayCommandId = 0;
        f.softLevel = softLevel;
        f.whiteLevel = whiteLevel;
        f.startTimestampMs = startFile;
        f.endTimestampMs = f.startTimestampMs + cmd.endTimestampMs;
        [f addCommand];
        startFile = f.endTimestampMs;
        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddBeauty object:f status:QHVCEditCommandStatusAdd]];
    }
    
    NSArray<NSDictionary *>* overlay = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [overlay enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
         QHVCEditCommandBeauty *f = [[QHVCEditCommandBeauty alloc] initCommand:self.commandFactory];
         f.softLevel = softLevel;
         f.whiteLevel = whiteLevel;
         f.overlayCommandId = cmd.commandId;
         f.startTimestampMs = cmd.startTimestampMs;
         f.endTimestampMs =  cmd.endTimestampMs;
         [f addCommand];
         [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddBeauty object:f status:QHVCEditCommandStatusAdd]];
     }];
}

- (void)adjustBeauty:(float)softLevel white:(float)whiteLevel
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddBeauty];
    
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandBeauty *cmd = (QHVCEditCommandBeauty *)cs[i][@"object"];
        cmd.softLevel = softLevel;
        cmd.whiteLevel = whiteLevel;
        [cmd editCommand];
    }
}

#pragma mark 特效
- (void)addEffect:(NSString *)effectName
{
    float start = 0.0f;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)cs[i][@"object"];
        QHVCEditCommandEffectFilter *f = [[QHVCEditCommandEffectFilter alloc] initCommand:self.commandFactory];
        f.effectName = effectName;
        f.startTimestampMs = start;
        f.endTimestampMs =  f.startTimestampMs +cmd.endTimestampMs;
        [f addCommand];
        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddEffect object:f status:QHVCEditCommandStatusAdd]];
        start = f.endTimestampMs;
    }
    
    NSArray<NSDictionary *>* overlay = [self filterCommand:QHVCEditCommandOperationAddOverlay];
    [overlay enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         QHVCEditCommandOverlaySegment *cmd = (QHVCEditCommandOverlaySegment *)obj[@"object"];
         QHVCEditCommandEffectFilter *f = [[QHVCEditCommandEffectFilter alloc] initCommand:self.commandFactory];
         f.effectName = effectName;
         f.startTimestampMs = cmd.startTimestampMs;
         f.endTimestampMs =  cmd.endTimestampMs;
         [f addCommand];
         [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddEffect object:f status:QHVCEditCommandStatusAdd]];
     }];
}

- (void)adjustEffect:(NSString *)effectName
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddEffect];
    
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandEffectFilter *cmd = (QHVCEditCommandEffectFilter *)cs[i][@"object"];
        cmd.effectName = effectName;
        [cmd editCommand];
    }
}

#pragma mark - 马赛克

- (void)updateMosaic:(CGRect)region degree:(CGFloat)degree
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddMosaic];
    if ([cs count] == 0)
    {
        [self addMosaic:region degree:degree];
        return;
    }
    
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandMosaic *cmd = (QHVCEditCommandMosaic *)cs[i][@"object"];
        cmd.region = region;
        cmd.degree = degree;
        [cmd editCommand];
    }
}

- (void)addMosaic:(CGRect)region degree:(CGFloat)degree
{
    float start = 0.0f;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandAddFileSegment* cmd = (QHVCEditCommandAddFileSegment *)cs[i][@"object"];
        QHVCEditCommandMosaic* f = [[QHVCEditCommandMosaic alloc] initCommand:self.commandFactory];
        f.startTimestampMs = start;
        f.endTimestampMs = f.startTimestampMs + cmd.endTimestampMs;
        f.region = region;
        f.degree = degree;
        [f addCommand];
        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddMosaic object:f status:QHVCEditCommandStatusAdd]];
        start = f.endTimestampMs;
    }
}

#pragma mark - 去水印

- (void)updateDelogo:(CGRect)region
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddDelogo];
    if ([cs count] == 0)
    {
        [self addDelogo:region];
        return;
    }
    
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandDelogo* cmd = (QHVCEditCommandDelogo *)cs[i][@"object"];
        cmd.region = region;
        [cmd editCommand];
    }
}

- (void)addDelogo:(CGRect)region
{
    float start = 0.0f;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandAddFileSegment* cmd = (QHVCEditCommandAddFileSegment *)cs[i][@"object"];
        QHVCEditCommandDelogo* f = [[QHVCEditCommandDelogo alloc] initCommand:self.commandFactory];
        f.startTimestampMs = start;
        f.endTimestampMs = f.startTimestampMs + cmd.endTimestampMs;
        f.region = region;
        [f addCommand];
        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddDelogo object:f status:QHVCEditCommandStatusAdd]];
        start = f.endTimestampMs;
    }
}

#pragma mark - Kenburns

- (void)addKenburnsEffect:(NSDictionary *)kenburnsInfo
{
    float start = 0.0f;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSInteger i = 0; i < cs.count; i++)
    {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)cs[i][@"object"];
        QHVCEditCommandEffectFilter *f = [[QHVCEditCommandEffectFilter alloc] initCommand:self.commandFactory];
        f.effectName = @"effect_18";
        f.effectInfo = kenburnsInfo;
        f.startTimestampMs = start;
        f.endTimestampMs =  f.startTimestampMs +cmd.endTimestampMs;
        f.overlayCommandId = 0;
        [f addCommand];
        [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddKenburns object:f status:QHVCEditCommandStatusAdd]];
        start = f.endTimestampMs;
    }
}

- (void)updateKenburnsEffect:(NSDictionary *)kenburnsInfo
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddKenburns];
    if ([cs count] == 0)
    {
        [self addKenburnsEffect:kenburnsInfo];
        return;
    }
    
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandEffectFilter *cmd = (QHVCEditCommandEffectFilter *)cs[i][@"object"];
        cmd.effectName = @"effect_18";
        cmd.effectInfo = kenburnsInfo;
        [cmd editCommand];
    }
}

- (void)deleteKenburnsEffect
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddKenburns];
    for (NSInteger i = 0; i < cs.count; i++) {
        QHVCEditCommandEffectFilter *cmd = (QHVCEditCommandEffectFilter *)cs[i][@"object"];
        [cmd deleteCommand];
        [self.commandsArray removeObject:cs[i]];
    }
}

#pragma mark - 动态字幕

- (void)addDynamicSubtitle:(NSString *)filePath
{
    NSTimeInterval duration = 0.0;
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddFile];
    for (NSDictionary* c in cs)
    {
        QHVCEditCommandAddFileSegment *cmd = (QHVCEditCommandAddFileSegment *)c[@"object"];
        duration = duration + cmd.endTimestampMs - cmd.startTimestampMs;
    }
    
    QHVCEditCommandDynamicSubtitle* f = [[QHVCEditCommandDynamicSubtitle alloc] initCommand:self.commandFactory];
    f.configFilePath = filePath;
    f.startTimestampMs = 0;
    f.endTimestampMs = duration;
    [f addCommand];
    [self.commandsArray addObject:[self formatCommand:QHVCEditCommandOperationAddDynamicSubtitle object:f status:QHVCEditCommandStatusAdd]];
}

- (void)deleteDynamicSubtitle
{
    NSArray<NSDictionary *>* cs = [self filterCommand:QHVCEditCommandOperationAddDynamicSubtitle];
    for (NSDictionary* c in cs)
    {
        QHVCEditCommandDynamicSubtitle *cmd = (QHVCEditCommandDynamicSubtitle *)c[@"object"];
        [cmd deleteCommand];
        [self.commandsArray removeObject:c];
    }
}

#pragma mark - 移除所有指令

- (void)removeAllCommands
{
    if (self.commandFactory) {
        [self.commandFactory removeAllCommands];
    }
}

@end
