//
//  QHVCITSGuestUserCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/20.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^KickoutGuestAction)(NSString *guestId);

@interface QHVCITSGuestUserCell : UITableViewCell

@property (nonatomic, copy) KickoutGuestAction kickoutCompletion;

- (void)updateCell:(NSDictionary *)dict;

@end
