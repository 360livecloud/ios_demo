//
//  QHVCEditProducer.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/4/20.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCEditDefinitions.h"

#pragma mark - 代理方法

@protocol QHVCEditProducerDelegate <NSObject>
@optional


/**
 合成进度回调

 @param progress 当前合成进度（0-100）
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

#pragma mark - 合成器方法

@class QHVCEditTimeline;
@interface QHVCEditProducer : NSObject


/**
 初始化

 @param timeline 时间线对象
 @return 合成器实例对象
 */
- (instancetype)initWithTimeline:(QHVCEditTimeline *)timeline;


/**
 设置代理

 @param delegate 代理对象
 @return 返回值
 */
- (QHVCEditError)setDelegate:(id<QHVCEditProducerDelegate>)delegate;


/**
 释放

 @return 返回值
 */
- (QHVCEditError)free;


/**
 开始合成

 @return 返回值
 */
- (QHVCEditError)start;


/**
 停止合成，用于打断操作

 @return 返回值
 */
- (QHVCEditError)stop;

@end
