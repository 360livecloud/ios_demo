//
//  QHVCEditTools.h
//  QHVCEditKit
//
//  Created by liyue-g on 2019/4/18.
//  Copyright © 2019 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "QHVCEditDefinitions.h"

@interface QHVCEditFileInfo : NSObject
@property (nonatomic, assign) BOOL isPicture;                //是否是图片
@property (nonatomic, assign) NSInteger width;               //宽度
@property (nonatomic, assign) NSInteger height;              //高度
@property (nonatomic, assign) NSInteger durationMs;          //文件总时长(单位：毫秒)
@property (nonatomic, assign) NSInteger videoBitrate;        //视频码率
@property (nonatomic, assign) NSInteger fps;                 //视频帧率
@property (nonatomic, assign) NSInteger audioBitrate;        //音频码率
@property (nonatomic, assign) NSInteger audioChannels;       //音频声道数
@property (nonatomic, assign) NSInteger audioSamplerate;     //音频采样率

@end

@interface QHVCEditTools : NSObject

#pragma mark - File Info

/**
 获取文件信息
 
 @param filePath 文件物理路径
 @return 文件信息
 */
+ (QHVCEditFileInfo *)getFileInfo:(NSString *)filePath;

/**
 根据相册唯一标识获取文件信息
 
 @param fileIdentifier 相册唯一标识
 @return 文件信息
 */
+ (QHVCEditFileInfo *)getFileInfoWithIdentifier:(NSString *)fileIdentifier;

#pragma mark - 滤镜缩略图

/**
 批量处理滤镜缩略图回调接口，会多次回调
 
 @param thumbnails 缩略图对象数组
 @param lutImagePaths 查色图路径数组
 */
typedef void(^QHVCEditLUTFilterThumbnailsCallback)(UIImage* thumbnails, NSString* lutImagePaths);

/**
 批量处理滤镜缩略图
 
 @param lutImageInfo 查色图信息数组，image和path同时存在优先读取path，image和path均为空（@“”）时返回不带任何特效的缩略图
 例如：
 @[
    @{
     @"path":path,         //lut路径
     @"image":image,       //lut图
     @"intensity":@1.0,     //滤镜程度
     @"dimension":@(64)}   //查色图色阶宽度
 ];
 @param size 生成缩略图尺寸
 @param block 数据回调
 */
+ (void)generateLUTFilterThumbnails:(UIImage *)inputImage
                       lutImageInfo:(NSArray<NSDictionary *>*)lutImageInfo
                             toSize:(CGSize)size
                           callback:(QHVCEditLUTFilterThumbnailsCallback)block;

@end

#pragma mark - 获取音频数据

@protocol QHVCEditAudioProducerDelegate <NSObject>
@optional

/**
 音频数据回调（双声道，44100HZ）
 
 @param pcm pcm数据
 @param size 数据长度
 */
- (void)onAudioProducerPCMData:(unsigned char *)pcm size:(int)size;


/**
 获取音频数据出错
 
 @param error 错误码
 */
- (void)onAudioProducerError:(QHVCEditError)error;


/**
 获取音频数据完成
 */
- (void)onAudioProducerComplete;

@end

@class QHVCEditTimeline;
@class QHVCEditTrackClip;
@interface QHVCEditAudioProducer : NSObject


/**
 初始化音频数据生成器，用于获取已添加音频效果后的音频数据（音量、变声、过渡等）
 
 @param timeline 时间线对象
 @return 音频数据生成器
 */
- (instancetype)initWithTimeline:(QHVCEditTimeline *)timeline;


/**
 设置代理
 
 @param delegate 代理对象
 @return 返回值
 */
- (QHVCEditError)setDelegate:(id<QHVCEditAudioProducerDelegate>)delegate;


/**
 开始读取音频数据，需和free方法成对使用
 
 @param clip 素材对象
 @param startTime 相对clip的音频数据开始时间，单位毫秒
 @param endTime 相对clip的音频数据结束时间，单位毫秒
 @param interval 间隔粒度，单位毫秒，默认为0即逐帧获取
 @return 返回值
 */
- (QHVCEditError)startWithClip:(QHVCEditTrackClip *)clip
                     startTime:(NSInteger)startTime
                       endTime:(NSInteger)endTime
                      interval:(NSInteger)interval;


/**
 停止并释放缓存数据，需和start方法成对使用
 
 @return 返回值
 */
- (QHVCEditError)free;

@end


#pragma mark - 文件倒放

@protocol QHVCEditReverseProducerDelegate <NSObject>
@optional

/**
 合成进度回调
 
 @param progress 当前进度（0-100）
 */
- (void)onProducerProgress:(float)progress;

/**
 合成出错
 
 @param error 错误码
 */
- (void)onProducerError:(QHVCEditError)error;

/**
 合成被打断
 用户主动调用stop接口会触发此回调函数
 */
- (void)onProducerInterrupt;

/**
 合成完成
 */
- (void)onProducerComplete;

@end

@interface QHVCEditReverseProducer : NSObject

/**
 设置代理对象
 
 @param delegate 代理对象
 @return 返回值
 */
- (QHVCEditError)setDelegate:(id<QHVCEditReverseProducerDelegate>)delegate;


/**
 开始生成倒放文件，需和free成对使用（沙盒文件）
 
 @param inputFilePath 输入文件沙盒路径
 @param reverseFilePath 输出倒放文件沙盒路径，例如/tmp/reverse.mp4
 @param startTime 输入文件裁剪入点，即相对于物理文件的开始时间点（单位：毫秒）
 @param endTime 输入文件裁剪出点，即相对于物理文件的结束时间点（单位：毫秒）
 @param slowMotionVideoInfos 视频慢视频信息（若文件为慢视频文件，需传入慢视频信息，否则为nil）
 @return 返回值
 */
- (QHVCEditError)startWithFilePath:(NSString *)inputFilePath
                   reverseFilePath:(NSString *)reverseFilePath
                inputFileStartTime:(NSInteger)startTime
                  inputFileEndTime:(NSInteger)endTime
     inputFileSlowMotionVideoInfos:(NSArray<QHVCEditSlowMotionVideoInfo *>*)slowMotionVideoInfos;


/**
 开始生成倒放文件，需和free成对使用（相册文件）
 
 @param fileIdentifier 输入文件相册唯一标识符
 @param reverseFilePath 输出倒放文件沙盒路径，例如/tmp/reverse.mp4
 @param startTime 输入文件裁剪入点，即相对于物理文件的开始时间点（单位：毫秒）
 @param endTime 输入文件裁剪出点，即相对于物理文件的结束时间点（单位：毫秒）
 @param slowMotionVideoInfos 视频慢视频信息（若文件为慢视频文件，需传入慢视频信息，否则为nil）
 @return 返回值
 */
- (QHVCEditError)startWithFileIdentifier:(NSString *)fileIdentifier
                         reverseFilePath:(NSString *)reverseFilePath
                      inputFileStartTime:(NSInteger)startTime
                        inputFileEndTime:(NSInteger)endTime
           inputFileSlowMotionVideoInfos:(NSArray<QHVCEditSlowMotionVideoInfo *>*)slowMotionVideoInfos;


/**
 停止生成倒放文件，用于打断操作
 
 @return 返回值
 */
- (QHVCEditError)stop;


/**
 释放缓存数据，需和start方法成对使用
 
 @return 返回值
 */
- (QHVCEditError)free;

@end

#pragma mark - 生成webm文件

@interface QHVCEditWebmFrame : NSObject

@property (nonatomic, strong) NSData*   data;                 //RGBA数据
@property (nonatomic, assign) NSInteger width;                //源视频帧宽
@property (nonatomic, assign) NSInteger height;               //源视频帧高
@property (nonatomic, assign) NSInteger pts;                  //时间戳，单位毫秒，首帧需为0

@end

@interface QHVCEditWebmProducer : NSObject

@property (nonatomic, assign) NSInteger outputWidth;           //输出宽度，默认为1280
@property (nonatomic, assign) NSInteger outputHeight;          //输出高度，默认为720
@property (nonatomic, assign) NSInteger outputVideoBitrate;    //码率，单位bit，默认为4500000

/**
 开始合成
 
 @param path 输出路径，例如：/tmp/output.webm
 @return 返回值
 */
- (QHVCEditError)startWithOutputFilePath:(NSString *)path;

/**
 结束合成
 
 @return 返回值
 */
- (QHVCEditError)stop;

/**
 发送需合成的数据帧
 
 @return 返回值
 */
- (QHVCEditError)sendFrame:(QHVCEditWebmFrame *)frame;


@end

#pragma mark - 生成Gif文件

@protocol QHVCEditGifProducerDelegate <NSObject>
@optional

/**
 合成进度回调
 
 @param progress 当前进度（0-100）
 */
- (void)onProducerProgress:(float)progress;

/**
 合成出错
 
 @param error 错误码
 */
- (void)onProducerError:(QHVCEditError)error;

/**
 合成被打断
 用户主动调用stop接口会触发此回调函数
 */
- (void)onProducerInterrupt;

/**
 合成完成
 */
- (void)onProducerComplete;

@end

@interface QHVCEditGifProducer : NSObject

@property (nonatomic, assign) NSInteger outputWidth;           //输出宽度，默认为1280
@property (nonatomic, assign) NSInteger outputHeight;          //输出高度，默认为720
@property (assign, nonatomic) NSUInteger outputFps;            //输出帧率，默认10

/**
 设置代理对象
 
 @param delegate 代理对象
 */
- (void)setDelegate:(id<QHVCEditGifProducerDelegate>)delegate;


/**
 开始生成gif文件，需和free成对使用（沙盒文件）
 
 @param inputFilePath 输入文件沙盒路径
 @param outputFilePath 输出gif文件沙盒路径，例如/tmp/output.gif
 @param startTime 输入文件裁剪入点，即相对于物理文件的开始时间点（单位：毫秒）
 @param endTime 输入文件裁剪出点，即相对于物理文件的结束时间点（单位：毫秒）
 @return 返回值
 */
- (QHVCEditError)startWithFilePath:(NSString *)inputFilePath
                    outputFilePath:(NSString *)outputFilePath
                inputFileStartTime:(NSInteger)startTime
                  inputFileEndTime:(NSInteger)endTime
                   inputFrameCount:(NSInteger)frameCount;


/**
 开始生成gif文件，需和free成对使用（相册文件）
 
 @param fileIdentifier 输入文件相册唯一标识符
 @param outputFilePath 输出倒放文件沙盒路径，例如/tmp/output.gif
 @param startTime 输入文件裁剪入点，即相对于物理文件的开始时间点（单位：毫秒）
 @param endTime 输入文件裁剪出点，即相对于物理文件的结束时间点（单位：毫秒）
 @return 返回值
 */
- (QHVCEditError)startWithFileIdentifier:(NSString *)fileIdentifier
                          outputFilePath:(NSString *)outputFilePath
                      inputFileStartTime:(NSInteger)startTime
                        inputFileEndTime:(NSInteger)endTime
                         inputFrameCount:(NSInteger)frameCount;


/**
 停止生成gif文件，用于打断操作
 
 @return 返回值
 */
- (QHVCEditError)stop;


/**
 释放缓存数据，需和start方法成对使用
 
 @return 返回值
 */
- (QHVCEditError)free;

@end
