//
//  QHVCGSImageDownloadModel.h
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/6.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QHVCCommonKit/QHVCCommonKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface QHVCGSImageDownloadModel : NSObject

@property (nonatomic, strong) NSString* imageName;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, assign) float totalSize;
@property (nonatomic, assign) float currentSize;
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;

- (void) cancelTask;

@end

NS_ASSUME_NONNULL_END
