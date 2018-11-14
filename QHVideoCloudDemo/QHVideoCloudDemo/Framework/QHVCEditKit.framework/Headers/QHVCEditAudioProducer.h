//
//  QHVCEditAudioProducer.h
//  QHVCEditKit
//
//  Created by yinchaoyu on 2018/5/23.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCEditCommand.h"

typedef NS_ENUM(NSUInteger, QHVCEditAudioProducerError)
{
    QHVCEditAudioProducerError_NoError           = 1, //无错误
    QHVCEditAudioProducerError_ParamError        = 2, //参数错误
    QHVCEditAudioProducerError_InitError         = 3, //初始化失败
    QHVCEditAudioProducerError_ReadPCMError      = 4, //PCM数据读取失败
};


/**
 状态
 */
typedef NS_ENUM(NSUInteger, QHVCEditAudioProducerStatus)
{
    QHVCEditAudioProducerStatus_OpenFailed      = 0, //文件打开失败
    QHVCEditAudioProducerStatus_NoAudio         = 1, //无音频数据
    QHVCEditAudioProducerStatus_DecodeFailed    = 2, //解码失败
    QHVCEditAudioProducerStatus_Complete        = 3, //完成
    QHVCEditAudioProducerStatus_UnKnown         = 100,
};

@protocol QHVCEditAudioProducerDelegate <NSObject>

- (void)onPCMData:(unsigned char *)pcm size:(int)size;

@optional
- (void)onProducerStatus:(QHVCEditAudioProducerStatus)status;

@end

@interface QHVCEditAudioProducer : NSObject

@property (nonatomic, weak) id<QHVCEditAudioProducerDelegate> delegate;
@property (nonatomic, assign) int fileIndex;
@property (nonatomic, assign) int overlayCommandId;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, assign) NSTimeInterval timeIntervalMs;//粒度间隔，毫秒,默认是0，会回调每一帧数据

/**
 初始化合成器
 
 @param commandFactory 指令工厂
 @return 合成器实例对象
 */
- (instancetype)initWithCommandFactory:(QHVCEditCommandFactory *)commandFactory;

/**
 开始读取pcm
 */
- (QHVCEditAudioProducerError)startProducer;

/**
 停止
 */
- (QHVCEditAudioProducerError)stopProducer;

@end
