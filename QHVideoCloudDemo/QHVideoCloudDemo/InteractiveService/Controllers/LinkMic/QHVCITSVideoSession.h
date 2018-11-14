//
//  QHVCITSVideoSession.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <QHVCInteractiveKit/QHVCInteractiveKit.h>

@interface QHVCITSVideoSession : NSObject

@property (strong, nonatomic, nullable) NSString* userId;
//正常渲染使用
@property (strong, nonatomic, nullable) UIView* videoView;//记录view是放在哪个上面的
@property (strong, nonatomic, nullable) QHVCITLVideoCanvas *canvas;

//外部渲染使用
@property (strong, nonatomic, nullable) GLKViewController* glViewController;

- (instancetype _Nullable )initWithUid:(NSString* _Nullable)userId
                                  view:(UIView * _Nullable)view
                            controller:(GLKViewController* _Nullable)controller;

- (instancetype _Nullable )initWithUid:(NSString* _Nullable)userId
                                  view:(UIView * _Nullable)view;

@end
