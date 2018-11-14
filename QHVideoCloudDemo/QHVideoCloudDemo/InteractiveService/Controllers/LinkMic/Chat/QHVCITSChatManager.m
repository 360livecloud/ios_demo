//
//  QHVCITSChatManager.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSChatManager.h"
#import "QHVCITSUserSystem.h"

static QHVCITSChatManager *_sharedManager = nil;

@implementation QHVCITSChatManager

+ (QHVCITSChatManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)setChatMessageDelegate:(id<QHVCIMMessageDelegate>)delegate
{
    [[QHVCIM sharedInstance] setMessageDelegate:delegate];
}

+ (void)connect:(void (^)(NSString *userId))successBlock
          error:(void (^)(QHVCIMConnectErrorCode status))errorBlock
{
    QHVCITSUserModel *model = [QHVCITSUserSystem sharedInstance].userInfo;
    [[QHVCIM sharedInstance] setIMContexts:model.imContext];
    
    NSDictionary *user = @{@"userId":model.userId,@"name":model.nickName,@"protraitUrl":model.portraint};
    [[QHVCIM sharedInstance] setUserInfos:user];
    
    [[QHVCIM sharedInstance] connect:^(NSString * _Nonnull userId) {
        NSLog(@"connect sucess %@",userId);
        if (successBlock) {
            successBlock(userId);
        }
    } error:^(QHVCIMConnectErrorCode status) {
        NSLog(@"connect fail %@",@(status));
        if (errorBlock) {
            errorBlock(status);
        }
    }];
}

+ (void)disconnect
{
    [[QHVCIM sharedInstance] disconnect:NO];
}

+ (void)joinChatroom:(NSString *)roomId
{
    [[QHVCIM sharedInstance] joinChatroom:roomId messageCount:0 success:^{
        NSLog(@"joinroom sucess");
    } error:^(QHVCIMErrorCode status) {
        NSLog(@"joinroom fail %@",@(status));
    }];
}

+ (void)quitChatroom:(NSString *)roomId
{
    [[QHVCIM sharedInstance] quitChatroom:roomId success:^{
        NSLog(@"quitroom sucess");
    } error:^(QHVCIMErrorCode status) {
        NSLog(@"quitroom fail %@",@(status));
    }];
}

+ (void)sendCommandMessage:(QHVCIMConversationType)conversationType
                   cmdType:(QHVCITSCommand)cmdType
                  targetId:(NSString *)targetId
                   success:(void (^)(long messageId))successBlock
                     error:(void (^)(QHVCIMErrorCode errorCode,
                                     long messageId))errorBlock
{
    QHVCIMCommandContent *msg = [[QHVCIMCommandContent alloc] init];
    msg.name = @(cmdType).stringValue;
    NSString *roomId = [QHVCITSUserSystem sharedInstance].roomInfo.roomId?:@"";
    NSDictionary *dict = @{@"cmd":@(cmdType),
                         @"cmd_tip":@"",
                         @"os_type":@"ios",
                         @"ver":@"1.0",
                           @"target":roomId,
                         @"extra":@""
                         };
    msg.data = [QHVCITSChatManager dicFormatTojson:dict];
    [QHVCITSChatManager sendMessage:conversationType targetId:targetId content:msg success:successBlock error:errorBlock];
}

+ (void)sendMessage:(QHVCIMConversationType)conversationType
           targetId:(NSString *)targetId
            content:(QHVCIMMessageContent *)msg
            success:(void (^)(long messageId))successBlock
              error:(void (^)(QHVCIMErrorCode errorCode,
                              long messageId))errorBlock
{
    [[QHVCIM sharedInstance] sendMessage:conversationType targetId:targetId content:msg success:^(long messageId) {
        
        NSLog(@"send msg sucess %@",@(messageId));
        if (successBlock) {
            successBlock(messageId);
        }
    } error:^(QHVCIMErrorCode errorCode, long messageId) {
        NSLog(@"send msg fail %@",@(messageId));
        if (errorBlock) {
            errorBlock(errorCode,messageId);
        }
    }];
}

+ (NSString *)dicFormatTojson:(NSDictionary *)dict
{
    if (!dict||dict.count <=0) {
        return nil;
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json str %@",jsonString);
    return jsonString;
}

+ (NSDictionary *)jsonFormatToDic:(NSData *)data
{
    NSError *error;
    NSDictionary *dic;
    BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
    if (data.length > 0 && !isSpace) {
        dic = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingMutableContainers
                                                error:&error];
        if (dic&&[dic isKindOfClass:[NSDictionary class]]&&dic.count > 0) {
            return dic;
        }
    }
    return nil;
}

@end
