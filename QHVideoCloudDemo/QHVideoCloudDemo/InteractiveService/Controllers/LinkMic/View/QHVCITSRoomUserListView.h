//
//  QHVCITSRoomUserListView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCITSGuestUserCell.h"

@interface QHVCITSRoomUserListView : UIView

@property (nonatomic, copy) KickoutGuestAction kickoutCompletion;

- (void)setUsersData:(NSArray<NSDictionary *> *)lists;

@end
