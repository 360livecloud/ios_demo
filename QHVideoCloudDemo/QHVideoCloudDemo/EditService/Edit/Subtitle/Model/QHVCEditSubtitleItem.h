//
//  QHVCEditSubtitleItem.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/12.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStylesName @"edit_subtitle_style"

@interface QHVCEditSubtitleItem : NSObject

@property (nonatomic, assign) NSInteger styleIndex;
@property (nonatomic, assign) NSInteger colorIndex;
@property (nonatomic, assign) NSInteger fontValue;
@property (nonatomic, strong) NSString *subtitleText;
@property (nonatomic, strong) UIImage *composeImage;
@property (nonatomic, assign) NSTimeInterval insertStartTimeMs;
@property (nonatomic, assign) NSTimeInterval insertEndTimeMs;

@end
