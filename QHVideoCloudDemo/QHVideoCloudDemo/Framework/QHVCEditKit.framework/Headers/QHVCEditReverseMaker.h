//
//  QHVCEditReverseMaker.h
//  QHVCEditKit
//
//  Created by yinchaoyu on 2018/7/30.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QHVCEditSlowMotionVideoInfo;

typedef NS_ENUM(NSUInteger, QHVCEditReverseMakerError)
{
    QHVCEditReverseMakerError_NoError       = 1, //无错误
    QHVCEditReverseMakerError_ParamsError     = 3, //参数错误
    QHVCEditReverseMakerError_InitError     = 3, //初始化失败
};

typedef NS_ENUM (NSInteger, QHVCEditReverseStatus)
{
    QHVCEditReverseStatus_Processing,
    QHVCEditReverseStatus_Complete,
    QHVCEditReverseStatus_Cancel,
    QHVCEditReverseStatus_Error = -100,
};

@protocol QHVCEditReverseMakerDelegate <NSObject>
@required
- (void)onReverseMakerStatus:(QHVCEditReverseStatus)status;

@optional
- (void)onReverseMakerProgress:(float)progress;
@end

@interface QHVCEditReverseMaker : NSObject

@property (nonatomic, strong) NSString *fileName;        //原始文件
@property (nonatomic, strong) NSString *photoFileIdentifier;//相册文件标识符，与fileName同时存在时，优先使用photoFileIdentifier
@property (nonatomic, strong) NSString *reverseFileName; //倒放文件生成的沙盒全路径
@property (nonatomic, strong) NSString *tempFilePath;    //业务上根据自己的需求管理改目录
@property (nonatomic, assign) NSTimeInterval startMs;    //相对于物理文件开始时间
@property (nonatomic, assign) NSTimeInterval endMs;      //相对于物理文件结束时间
@property (nonatomic, retain) NSArray<QHVCEditSlowMotionVideoInfo *>* slowMotionVideoInfos;  //慢视频物理文件倍速信息

@property (nonatomic, weak) id<QHVCEditReverseMakerDelegate> delegate;


/**
 开始转换

 @return 错误码
 */
- (QHVCEditReverseMakerError)makerStart;

/**
 停止maker，用于中断转换过程

 @return 错误码
 */
- (QHVCEditReverseMakerError)makerStop;


/**
 释放

 @return 一个maker只能用于一个转换过程，转换过程中断或者结束要free
 */
- (QHVCEditReverseMakerError)free;

@end
