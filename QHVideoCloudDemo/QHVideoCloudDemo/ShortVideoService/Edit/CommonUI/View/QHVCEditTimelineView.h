//
//  QHVCEditTimelineView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QHVCEditTimelineViewPlayAction)(void);
typedef void(^QHVCEditTimelineViewPauseAction)(void);
typedef void(^QHVCEditTimelineViewPlayProgressAction)(NSInteger timestamp);

@class QHVCEditPlayerBaseVC;
@interface QHVCEditTimelineView : UIView

@property (nonatomic,   weak) IBOutlet UICollectionView* collectionView;

@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerBaseVC;
@property (nonatomic,   copy) QHVCEditTimelineViewPlayAction playAction;
@property (nonatomic,   copy) QHVCEditTimelineViewPauseAction pauseAction;
@property (nonatomic,   copy) QHVCEditTimelineViewPlayProgressAction playingAction;

- (void)pause;
- (void)play;
- (NSInteger)timelineTimestamp;

@end
