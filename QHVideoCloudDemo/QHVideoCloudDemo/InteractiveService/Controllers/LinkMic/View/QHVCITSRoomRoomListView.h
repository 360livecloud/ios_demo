//
//  QHVCITSRoomRoomListView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/7/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHVCITSRoomRoomListCell.h"

@interface QHVCITSRoomRoomListView : UIView

@property (nonatomic, copy) JoinAction joinCompletion;

- (void)setUsersData:(NSArray<NSDictionary *> *)lists;

@end
