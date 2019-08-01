//
//  QHVCEditOverlayFunctionManager.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/22.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QHVCEditOverlayItemView;
@class QHVCEditPlayerBaseVC;
typedef void(^QHVCEditOverlayUpdatePlayerDurationBlock)(void);
typedef void(^QHVCEditOverlayDeleteBlock)(void);

@interface QHVCEditOverlayFunctionManager : NSObject

@property (nonatomic,   copy) QHVCEditOverlayUpdatePlayerDurationBlock updatePlayerDuraionBlock;
@property (nonatomic,   copy) QHVCEditOverlayDeleteBlock deleteOverlayBlock;
@property (nonatomic, retain) QHVCEditOverlayItemView* itemView;
@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerVC;
@property (nonatomic,   weak) UIView* listView;

@end

NS_ASSUME_NONNULL_END
