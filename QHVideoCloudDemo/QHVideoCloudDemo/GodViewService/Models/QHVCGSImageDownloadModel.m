//
//  QHVCGSImageDownloadModel.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/6.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSImageDownloadModel.h"

@implementation QHVCGSImageDownloadModel

- (void) cancelTask {
    if (_downloadTask) {
        [_downloadTask cancel];
    }
}

@end
