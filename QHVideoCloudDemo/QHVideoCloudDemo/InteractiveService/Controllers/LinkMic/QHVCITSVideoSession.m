//
//  QHVCITSVideoSession.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSVideoSession.h"
#import "QHVCITRoleView.h"

@implementation QHVCITSVideoSession

- (instancetype _Nullable )initWithUid:(NSString* _Nullable)userId
                                  view:(UIView * _Nullable)view
                            controller:(GLKViewController* _Nullable)controller
{
    if (self = [super init]) {
        self.userId = userId;
        
        self.videoView = view;
        
        UIView* preview = view;
        if([view isKindOfClass:[QHVCITRoleView class]])
        {
            preview = ((QHVCITRoleView *)view).preview;
        }
        
        self.canvas = [[QHVCITLVideoCanvas alloc] init];
        self.canvas.uid = userId;
        self.canvas.view = preview;
        self.canvas.renderMode = QHVCITL_Render_ScaleAspectFill;
        
        self.glViewController = controller;
    }
    return self;
}

- (instancetype _Nullable )initWithUid:(NSString* _Nullable)userId
                                  view:(UIView * _Nullable)view
{
    return [self initWithUid:userId
                        view:view
                  controller:nil];
}

@end
