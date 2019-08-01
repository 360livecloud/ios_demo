//
//  QHVCGSLANDeviceManager.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/15.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QHVCGSLANDeviceModel;
@class QHVCGSLANDeviceManager;

@protocol QHVCGSLANDeviceManagerDelegate <NSObject>

//- (void)lanDeviceManager:(QHVCGSLANDeviceManager *)manager didDiscoverDevice:(NSString *)device;

/**
 * 发现新设备后，QHVCGSLANDeviceManager内部合并更新数据，并返回最后业务端需要的数据分类
 */
- (void)lanDeviceManager:(QHVCGSLANDeviceManager *)manager
          didUpdateAuthedDevices:(NSArray *)authedDevices
                 unauthedDevices:(NSArray *)unauthedDevices;

@end

@interface QHVCGSLANDeviceManager : NSObject
@property (nonatomic,weak) id<QHVCGSLANDeviceManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)startDiscover;

- (void)stopDiscover;

@end

NS_ASSUME_NONNULL_END
