//
//  QHVCCommonScheduleEntry.h
//  QHVCCommonKit
//
//  Created by deng on 2017/9/8.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "theschedule_entryS.h"

@interface QHVCCommonScheduleEntry : NSObject

/**
 * 开始预调度
 * @param params 调度参数
 * @return true表示成功 false表示失败
 */
+ (BOOL)prepareScheduling:(const schedule_pre_params *)params;

/**
 * 开始调度
 * @param sessionId 会话唯一标识
 * @param params 调度参数
 * @return true表示成功 false表示失败
 */
+ (BOOL)doScheduling:(NSString *)sessionId
              params:(const schedule_params *)params;

/**
 * 销毁调度 必须在整个会话结束时才销毁
 * @param sessionId 会话唯一标识
 */
+ (void)destroy:(NSString *)sessionId;

/**
 * 停止调度 保证在该函数返回后，不会再调用该sessionId对应的调度回调函数（注意不能在调度回调函数里直接调用该接口）
 * @param sessionId 会话唯一标识
 */
+ (void)stop:(NSString *)sessionId;

/**
 * 是否需要调度
 * @param resourceId 资源标识
 * @return true表示需要调度 false表示不需要
 */
+ (BOOL)isNeedSchedule:(NSString *)resourceId;

@end
