//
//  QHVCShortVideoToolTableCell.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/23.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QHVCStateChangedAction)(void);

@interface QHVCShortVideoToolTableCell : UITableViewCell

- (void)setCellTitle:(NSString *)title;
- (void)setStateButtonTitle:(NSString *)title;

@property (nonatomic,   copy) QHVCStateChangedAction stateChangedAction;

@end

NS_ASSUME_NONNULL_END
