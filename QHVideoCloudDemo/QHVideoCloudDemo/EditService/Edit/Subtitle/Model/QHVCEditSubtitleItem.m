//
//  QHVCEditSubtitleItem.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/12.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSubtitleItem.h"

@implementation QHVCEditSubtitleItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _styleIndex = -1;
        _colorIndex = 0;
        _fontValue = 10;
    }
    return self;
}

@end
