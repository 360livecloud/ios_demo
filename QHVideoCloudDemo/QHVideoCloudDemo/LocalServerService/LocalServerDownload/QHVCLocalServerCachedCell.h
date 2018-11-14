//
//  QHVCLocalServerCachedCell.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/11/2.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DeleteFile)();

@interface QHVCLocalServerCachedCell : UITableViewCell

@property (nonatomic, copy) DeleteFile deleteFile;

- (void)setDetails:(NSDictionary *)item;

@end
