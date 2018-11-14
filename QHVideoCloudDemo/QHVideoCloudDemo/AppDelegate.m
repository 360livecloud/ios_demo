//
//  AppDelegate.m
//  QHVideoCloudDemo
//
//  Created by niezhiqiang on 2017/8/28.
//  Copyright © 2017年 qihoo360. All rights reserved.
//

#import "AppDelegate.h"
#import <QHVCCommonKit/QHVCCommonCoreEntry.h>
#import "QHVCNavigationController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] init];
    ViewController * svc = [ViewController new];
    QHVCNavigationController *nav = [[QHVCNavigationController alloc] initWithRootViewController:svc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [self notifyAppStart];
    return YES;
}

- (void)notifyAppStart
{
    NSString *bid = @"demo";
    [QHVCCommonCoreEntry coreOnAppStart:bid
                                 appVer:@"3.0.0"
                               deviceId:@"deviceUDID-kdkkdkdkdkd333"
                                  model:@"iPhone x"
                         optionalParams:nil];
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    //除播放器屏蔽设备旋转事件
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = (UINavigationController *)(window.rootViewController);
        if ([nav.topViewController isKindOfClass:NSClassFromString(@"QHVCPlayerViewController")])
        {
            return _oriention;
        }
        else
        {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
