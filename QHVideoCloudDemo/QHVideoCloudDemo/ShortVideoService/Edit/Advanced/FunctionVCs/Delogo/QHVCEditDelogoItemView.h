//
//  QHVCEditDelogoItemView.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/21.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditGestureView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^QHVCEditDelogoItemRefreshPlayerBlock)(BOOL forceRefresh);

@interface QHVCEditDelogoItemView : QHVCEditGestureView
@property (nonatomic,   copy) QHVCEditDelogoItemRefreshPlayerBlock refreshBlock;

@end

NS_ASSUME_NONNULL_END
