//
//  QHVCEditOverlayBlendView.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/9.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QHVCEditOverlayItemView;
@class QHVCEditPlayerBaseVC;

@interface QHVCEditOverlayBlendView : UIView

@property (nonatomic, retain) QHVCEditOverlayItemView* itemView;
@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerVC;

@end

NS_ASSUME_NONNULL_END
