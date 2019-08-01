//
//  QHVCEditSlowMotionVideoInfo.h
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/26.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHVCSlowMotionVideoInfo : NSObject

@property (nonatomic, assign) NSInteger startTime;    //物理文件开始时间点（单位：毫秒）
@property (nonatomic, assign) NSInteger endTime;      //物理文件结束时间点（单位：毫秒）
@property (nonatomic, assign) CGFloat speed;            //物理文件原始速率

@end
