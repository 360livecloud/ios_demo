//
//  QHVCEditSubtitleView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditSubtitleItem;

typedef void(^RefreshAction)(QHVCEditSubtitleItem *item);

@interface QHVCEditSubtitleView : UIView

@property (nonatomic, strong) QHVCEditSubtitleItem *subtitleItem;
@property (nonatomic, strong) NSArray *colorsArray;
@property (nonatomic, copy) RefreshAction refreshCompletion;

- (void)resetView;

@end
