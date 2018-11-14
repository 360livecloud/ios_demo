//
//  QHVCEditMaker.h
//  QHVCEditKit
//
//  Created by liyue-g on 2017/9/14.
//  Copyright © 2017年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QHVCEditCommand.h"

typedef NS_ENUM(NSUInteger, QHVCEditMakerError)
{
    QHVCEditMakerError_NoError       = 1, //无错误
    QHVCEditMakerError_FactoryError  = 2, //指令工厂错误
    QHVCEditMakerError_InitError     = 3, //初始化失败
};

typedef NS_ENUM(NSUInteger, QHVCEditMakerStatus)
{
    QHVCEditMakerStatus_Normal,           //正常
    QHVCEditMakerStatus_Cancel,           //业务取消合成操作
    QHVCEditMakerStatus_Complete,         //合成完成
    QHVCEditMakerStatus_Error,            //合成错误
};

@protocol QHVCEditMakerDelegate <NSObject>
@optional

/**
 合成回调

 @param status 当前合成状态
 @param progress 当前合成进度（0-100）
 */
- (void)onMakerProcessing:(QHVCEditMakerStatus)status progress:(float)progress;

@end

@interface QHVCEditMaker : NSObject


/**
 初始化合成器

 @param commandFactory 指令工厂
 @return 合成器实例对象
 */
- (instancetype)initWithCommandFactory:(QHVCEditCommandFactory *)commandFactory;


/**
 设置合成器代理对象

 @param delegate 代理对象
 @return 是否调用成功
 */
- (QHVCEditMakerError)setMakerDelegate:(id<QHVCEditMakerDelegate>)delegate;


/**
 关闭合成器

 @return 是否调用成功
 */
- (QHVCEditMakerError)free;


/**
 开始合成

 @return 是否调用成功
 */
- (QHVCEditMakerError)makerStart;


/**
 停止合成，用于打断操作

 @return 是否调用成功
 */
- (QHVCEditMakerError)makerStop;

@end
