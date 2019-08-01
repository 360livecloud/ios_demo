//
//  QHVCGSLANDeviceManager.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/15.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSLANDeviceManager.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGSLANDeviceModel.h"
#import <QHVCDeviceDiscoverKit/QHVCDeviceDiscover.h>

@interface QHVCGSLANDeviceManager ()<QHVCDeviceDiscoverDelegate>
@property (nonatomic,strong) NSMutableArray *authedDevices;
@property (nonatomic,strong) NSMutableArray *unauthedDevices;
@property (nonatomic,strong) NSTimer *testTimer;
@end

@implementation QHVCGSLANDeviceManager

+ (instancetype)sharedManager
{
    static QHVCGSLANDeviceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [QHVCGSLANDeviceManager new];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.authedDevices = [NSMutableArray new];
        self.unauthedDevices = [NSMutableArray new];
        [[QHVCDeviceDiscover sharedInstance] startServer:@"jasutointeki-iPhone" enableIpv6:NO];
        [QHVCDeviceDiscover sharedInstance].delegate = self;
    }
    return self;
}

- (void)startDiscover
{
    // 启动设备发现模块
    [[QHVCDeviceDiscover sharedInstance] browserService:@"_http._tcp" domain:nil];
    
//    kQHVCWeakSelf(ws);
//    // 模拟设备发现回调
//    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        [ws testDiscoverSDKCallback];
//    }];
}

- (void)stopDiscover
{
    // 停止设备发现模块
    [[QHVCDeviceDiscover sharedInstance] cancelBrowserService:@"_http._tcp" domain:nil];
    
    // 停止测试用的Timer
    [self.testTimer invalidate];
    self.testTimer = nil;
    
    // 清除数据
    [self.authedDevices removeAllObjects];
    [self.unauthedDevices removeAllObjects];
}

/**
 * 获取本地已认证的设备列表
 */
- (NSArray  *)getLocalAuthedLANDeviceList
{
    return [self getTestAuthedList];
}

#pragma mark QHVCDeviceDiscoverDelegate
- (void)browserCallBack:(QHVCErrorCode)err browserEvent:(QHVCBrowserEvent)event data:(QHVCBrowserRecord *)data
{
    QHVCGSLANDeviceModel *model = [[QHVCGSLANDeviceModel alloc] init];
    model.name = [NSString stringWithUTF8String:data->name];
    model.type = [NSString stringWithUTF8String:data->type];
    model.domain = [NSString stringWithUTF8String:data->domain];
    model.isOnline = YES;
    
    switch(event)
    {
        case QHVC_DEVICE_SERVICE_EVENT_FOUND:
        {
            BOOL exited = NO;
            for (int i = 0; i < _unauthedDevices.count; i++)
            {
                QHVCGSLANDeviceModel *oldModel = _unauthedDevices[i];
                if ([oldModel.name isEqualToString:model.name])
                {
                    exited = YES;
                    break;
                }
            }
            if (!exited)
            {
                [_unauthedDevices addObject:model];
            }
            if (data)
            {
                fprintf(stderr,
                        "++++++++++FOUND++++++++++++++\n"
                        "\t%s:%u (%s)\n"
                        "\tTXT=%s\n"
                        "\tname is: %s\n"
                        "\ttype is: %s\n"
                        "\tdomain is: %s\n",
                        data->host_name, data->port, data->ip_addr,
                        data->txt, data->name, data->type,  data->domain);
                
            }
            else
            {
                fprintf(stderr, "++++++++FOUND ERROR+++++++++");
            }
            break;
        }
            
        case QHVC_DEVICE_SERVICE_EVENT_DISAPPEAR:
        {
            for (int i = 0; i < _unauthedDevices.count; i++)
            {
                QHVCGSLANDeviceModel *oldModel = _unauthedDevices[i];
                if ([oldModel.name isEqualToString:model.name])
                {
                    [_unauthedDevices removeObject:oldModel];
                    break;
                }
            }
            if (data)
            {
                fprintf(stderr,
                        "+++++++++DISAPPEAR++++++++++++"
                        "\tname is: %s\n"
                        "\ttype is: %s\n"
                        "\tdomain is: %s\n",
                        data->name, data->type,  data->domain);
                
            }
            else
            {
                fprintf(stderr, "++++++++DISAPPEAR ERROR+++++++++");
            }
            break;
        }
        case QHVC_DEVICE_SERVICE_EVENT_ERROR:
            fprintf(stderr, "++++++++error+++++++++%ld", (long)err);
            break;
            // browser_record_free(bs);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(lanDeviceManager:didUpdateAuthedDevices:unauthedDevices:)]) {
            [self.delegate lanDeviceManager:self didUpdateAuthedDevices:[_authedDevices copy] unauthedDevices:[_unauthedDevices copy]];
        }
    });
}

- (void)publishCallBack:(QHVCErrorCode)err publishEvent:(QHVCPublishEvent)event data:(nonnull QHVCPublishRecord *)data
{
    //
}

#pragma mark - 测试数据
- (void)testDiscoverSDKCallback
{
    QHVCGSLANDeviceModel *newModel = [self getTestModel];
    newModel.isOnline = YES;
    
    NSArray *autheds = [self.authedDevices copy];
    BOOL isExistInAuthed = NO;
    for (QHVCGSLANDeviceModel *model in autheds)
    {
        if ([model.serialNumber isEqualToString:newModel.serialNumber])
        {
            model.isOnline = YES;
            model.port = newModel.port;
            model.domain = newModel.domain;
            isExistInAuthed = YES;
            break;
        }
    }
    if (isExistInAuthed == NO)
    {
        BOOL isExistInUnauthed = NO;
        NSArray *unautheds = [self.unauthedDevices copy];
        for (QHVCGSLANDeviceModel *model in unautheds)
        {
            if ([model.serialNumber isEqualToString:newModel.serialNumber])
            {
                isExistInUnauthed = YES;
                break;
            }
        }
        if (isExistInUnauthed == NO) {
            [self.unauthedDevices addObject:newModel];
        }
    }
    if ([self.delegate respondsToSelector:@selector(lanDeviceManager:didUpdateAuthedDevices:unauthedDevices:)])
    {
        [self.delegate lanDeviceManager:self didUpdateAuthedDevices:self.authedDevices unauthedDevices:self.unauthedDevices];
    }
}


/**
 * 测试数据 - 已认证
 */
- (NSArray *)getTestAuthedList
{
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < 2; i++)
    {
        [array addObject:[self getTestModel]];
    }
    return array;
}

- (QHVCGSLANDeviceModel *)getTestModel
{
    QHVCGSLANDeviceModel *deviceModel = [QHVCGSLANDeviceModel new];
    deviceModel.port = @"1991";
    deviceModel.domain = @"12.232.123.322";
    deviceModel.name = [self getTestName];
    deviceModel.serialNumber = [self getTestSerialNumber];
    return deviceModel;
}

- (NSString *)getTestName
{
    NSArray *array = @[@"客厅左侧",@"厨房",@"二楼主卧",@"二楼次卧",@"一楼主卧",@"后院"];
    return array[(NSUInteger)arc4random_uniform((uint32_t)array.count)];
}

- (NSString *)getTestSerialNumber
{
    NSArray *array = @[@"1232",@"4232",@"4323232",@"23112",@"515123",@"918232"];
    return array[(NSUInteger)arc4random_uniform((uint32_t)array.count)];
}



@end
