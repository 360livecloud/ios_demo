//
//  QHVCGSRegisterViewController.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/4/17.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QHVCGSRegisterSuccessBlock)(NSString* userName, NSString* password);

@interface QHVCGSRegisterViewController : UIViewController

@property (nonatomic,copy) QHVCGSRegisterSuccessBlock successBlock;

@end

NS_ASSUME_NONNULL_END
