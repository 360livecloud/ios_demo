//
//  QHVCGSLANDeviceModel.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/15.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCGSLANDeviceModel : NSObject
@property (nonatomic, copy) NSString *host_name;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *ip_addr;
@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *txt;

@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic,assign) BOOL isOnline;

@end

NS_ASSUME_NONNULL_END
