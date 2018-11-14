//
//  QHVCLiveMainCellTwo.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/6/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ SwitchAction)(BOOL on);

@interface QHVCLiveMainCellTwo : UITableViewCell

@property (nonatomic, copy) SwitchAction switchAction;

- (void)updateCell:(NSMutableDictionary *)item;

@end
