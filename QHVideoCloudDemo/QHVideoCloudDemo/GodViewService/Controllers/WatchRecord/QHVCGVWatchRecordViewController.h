//
//  QHVCGVWatchRecordViewController.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/9/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCGVBaseViewController.h"

@class QHVCGVDeviceModel;
@interface QHVCGVWatchRecordViewController : QHVCGVBaseViewController

@property(nonatomic, strong) NSMutableArray<NSDictionary *>* timelineArray;
@property(nonatomic, strong) NSString* currentSelectDay;
@property(nonatomic, assign) NSUInteger currentSeekTime;
@property (nonatomic,strong) QHVCGVDeviceModel *deviceModel;

- (void) selectRecordTime:(NSString *)selectDay seekTime:(NSUInteger)seekTime;

@end
