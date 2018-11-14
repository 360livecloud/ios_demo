//
//  QHVCLocalServerDownloadingCell.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/2.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PauseResumeAction)(BOOL selected);
typedef void (^DeleteAction)();

@interface QHVCLocalServerDownloadingCell : UITableViewCell

@property (nonatomic, copy) PauseResumeAction pauseResumeAction;
@property (nonatomic, copy) DeleteAction deleteAction;

- (void)setDetails:(NSDictionary *)item;
- (void)setDownloading:(BOOL)isUpdating;

@end
