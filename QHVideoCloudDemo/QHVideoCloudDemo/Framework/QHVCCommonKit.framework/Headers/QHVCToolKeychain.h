
#import <Foundation/Foundation.h>

@interface QHVCToolKeychain : NSObject

+ (BOOL)setValue:(id _Nonnull )value forKey:(NSString *_Nonnull)key;

+ (BOOL)setValue:(id _Nonnull)value forKey:(NSString *_Nonnull)key forAccessGroup:(nullable NSString *)group;


+ (id _Nullable )valueForKey:(NSString *_Nonnull)key;

+ (id _Nullable )valueForKey:(NSString *_Nonnull)key forAccessGroup:(nullable NSString *)group;

+ (BOOL)deleteValueForKey:(NSString *_Nonnull)key;

+ (BOOL)deleteValueForKey:(NSString *_Nonnull)key forAccessGroup:(nullable NSString *)group;

+ (NSString *_Nullable)getBundleSeedIdentifier;

@end
