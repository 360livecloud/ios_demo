
#import <Foundation/Foundation.h>

@interface QHVCToolDeviceModel : NSObject

/**
 获取当前设备的名字。eg:iphone7,1

 @return 设备的名字
 */
+ (NSString *)getCurrentDeviceName;

/**
 获取操作系统名称

 @return 操作系统名称
 */
+ (NSString *)getSystemName;


/**
 获取操作系统版本号

 @return 操作系统版本号
 */
+ (NSString *)getSystemVersion;


/**
 获取设备的UUID，唯一，只要使用视频云SDK，UUID都是唯一的
 
 @return 设备UUID
 */
+ (NSString *)getDeviceUUID;

/**
 判断设备是否低于某个指定的型号
 
 @param modelPlatform 设备型号
 @return YES：低于指定设备，NO：高于指定设备
 */
+ (BOOL)isDeviceBelowModel:(NSString *)modelPlatform;

/**
 是否是ARM64架构
 */
+ (BOOL)isARM64;

/**
 获取userAgent
 
 @return 需要统计的本机参数信息
 */
+ (NSString *)getUserAgent;

/**
 获取bundle Id信息
 
 @return bundle identifier
 */
+ (NSString *)getBundleIdentifier;

@end
