//
//  QHVCPlayingTableViewCellOne.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/4.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCPlayingTableViewCellOne : UITableViewCell

@property (nonatomic, copy) void (^callback)(NSString *);

- (void)updateCellDetail:(NSMutableDictionary *)item;

@end
