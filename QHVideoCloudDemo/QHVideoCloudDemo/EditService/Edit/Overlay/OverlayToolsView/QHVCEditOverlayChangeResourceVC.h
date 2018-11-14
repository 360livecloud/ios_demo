//
//  QHVCEditOverlayChangeResourceVC.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/6.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditViewController.h"

typedef void(^OverlayResetPlayerAction)();

@interface QHVCEditOverlayChangeResourceVC : QHVCEditViewController

@property (nonatomic, retain) QHVCEditMatrixItem* item;
@property (nonatomic, copy) OverlayResetPlayerAction resetPlayerAction;

@end

