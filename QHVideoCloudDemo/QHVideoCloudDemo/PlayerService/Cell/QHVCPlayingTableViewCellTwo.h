//
//  QHVCPlayingTableViewCellTwo.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/8/4.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCPlayingTableViewCellTwo : UITableViewCell

- (void)setTitle:(NSString *)title;
- (void)setRigthButtonHidden:(BOOL)hide;
- (void)setRigthButtonHidden:(BOOL)hide withTarget:(id)target action:(SEL)action;

@end
