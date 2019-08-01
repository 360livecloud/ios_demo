//
//  QHVCLiveMainCellOne.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/6/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHVCLiveMainCellOne : UITableViewCell

@property (nonatomic, strong) NSMutableDictionary *liveItem;

- (void)updateCell:(NSMutableDictionary *)item encryptProcesString:(NSString *)encryptString;

@end
