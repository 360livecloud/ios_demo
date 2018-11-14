//
//  QHVCToolLifeCycle.h
//  QHVCToolKit
//
//  Created by parker on 15/3/12.
//  Copyright (c) 2015年 parker. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QHVCToolLifeCycleDelegate <NSObject>

@optional

- (void)didBecomeActive:(NSNotification*)notification;
- (void)willResignActive:(NSNotification*)notification;
- (void)didEnterBackground:(NSNotification*)notification;
- (void)willEnterForeground:(NSNotification*)notification;
- (void)willTerminate:(NSNotification*)notification;
- (void)didReceiveMemoryWarning:(NSNotification*)notification;
- (BOOL)applicationOpenURL:(NSNotification*)notification;
- (void)audioSessionInterrupt:(NSNotification *)notification;
- (void)dataWillBecomeUnavailable:(NSNotification *)notification;

@end


@interface QHVCToolLifeCycle : NSObject<QHVCToolLifeCycleDelegate>

+ (void)registerLifeCycleListener:(id<QHVCToolLifeCycleDelegate>)obj;
+ (void)unregisterLifeCycleListener:(id<QHVCToolLifeCycleDelegate>)obj;

@end
