//
//  QHVCEditMusicTimelineView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditTimelineView.h"

typedef void(^QHVCEditMusicTimelineAddAction)(void);

@interface QHVCEditMusicTimelineView : UIView

@property (nonatomic,   copy) QHVCEditMusicTimelineAddAction addAction;
@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerBaseVC;

- (void)pause;
- (void)play;

@end

