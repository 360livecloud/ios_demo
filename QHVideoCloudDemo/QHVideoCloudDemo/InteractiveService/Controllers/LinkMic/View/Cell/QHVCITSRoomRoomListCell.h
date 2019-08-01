//
//  QHVCITSRoomRoomListCell.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/7/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JoinAction)(NSDictionary *info);

@interface QHVCITSRoomRoomListCell : UITableViewCell

@property (nonatomic, copy) JoinAction joinCompletion;

- (void)updateCell:(NSDictionary *)dict;

@end
