//
//  QHVCEffectBase.h
//  QHVCEffectKit
//
//  Created by liyue-g on 2018/10/30.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCEffectBase : NSObject

@property (nonatomic, assign) NSInteger initialStartTime;       //初始开始时间，不受变速等影响
@property (nonatomic, assign) NSInteger initialEndTime;         //初始结束时间，不受变速等影响
@property (nonatomic, assign) NSInteger renderStartTime;        //开始渲染时间，受变速等影响
@property (nonatomic, assign) NSInteger renderEndTime;          //结束渲染时间，受变速等影响
@property (nonatomic, retain) CIImage* targetImage;

- (CIImage *)processImage:(CIImage *)image timestamp:(NSInteger)timestamp;

@end

NS_ASSUME_NONNULL_END
