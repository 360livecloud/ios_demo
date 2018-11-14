//
//  QHVCLocalServerSettingCell.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/26.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ SwitchAction)(BOOL on);

@interface QHVCLocalServerSettingCell : UITableViewCell

@property (nonatomic, copy) SwitchAction switchAction;

- (void)setSwitchHidden:(BOOL)hidden;
- (void)setSwitchSelected:(BOOL)isSelected;

@end
