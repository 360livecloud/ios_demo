//
//  QHVCEditTailorFormatView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QHVCEditTailorFormatViewRefreshPlayer)(void);

@interface QHVCEditTailorFormatView : UIView

@property (nonatomic,   copy) QHVCEditTailorFormatViewRefreshPlayer refreshPlayerBlock;

@end
