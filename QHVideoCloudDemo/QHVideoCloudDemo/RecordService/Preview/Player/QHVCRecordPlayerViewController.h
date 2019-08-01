//
//  QHVCPlayerViewController.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/7.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCRecordPlayerViewController : UIViewController

@property (nonatomic,copy) void(^gotoRecord)(BOOL isRecord);

- (instancetype)initWithPlayerConfig:(NSDictionary *)config;
- (instancetype)initWithLivePlayerConfig:(NSDictionary *)config hasAddress:(BOOL)hasAddress;

@end
