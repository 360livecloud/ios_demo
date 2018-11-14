//
//  QHVCITGuestView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCITRoleView : UIView

@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSDate* joinRoomTime;

- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId;

@end
