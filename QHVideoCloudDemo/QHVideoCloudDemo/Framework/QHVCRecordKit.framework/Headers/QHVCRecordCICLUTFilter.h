//
//  QHVCEditCICLUTFilter.h
//  QHVCEditKit
//
//  Created by liyue-g on 2018/9/30.
//  Copyright © 2018年 liyue-g. All rights reserved.
//

#import "QHVCRecordFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecordCICLUTFilter : QHVCRecordFilter

@property (nonatomic, retain) CIImage *clutImage;
@property (nonatomic, assign) CGFloat progress;

@end

NS_ASSUME_NONNULL_END
