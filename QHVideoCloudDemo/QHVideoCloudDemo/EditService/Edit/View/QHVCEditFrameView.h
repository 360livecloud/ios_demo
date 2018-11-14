//
//  QHVCEditFrameView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QHVCEditFrameStatus) {
    QHVCEditFrameStatusAdd = 1,
    QHVCEditFrameStatusEdit,
    QHVCEditFrameStatusDone
};

typedef void(^AddAction)(NSTimeInterval insertStartMs);
typedef void(^EditAction)(void);
typedef void(^DoneAction)(NSTimeInterval insertEndMs);
typedef void(^DiscardAction)(void);

@interface QHVCEditFrameView : UIView

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *timeStamp;

@property (nonatomic, copy) AddAction addCompletion;
@property (nonatomic, copy) EditAction editCompletion;
@property (nonatomic, copy) DoneAction doneCompletion;
@property (nonatomic, copy) DiscardAction discardCompletion;

- (void)setUIStatus:(QHVCEditFrameStatus)status;
- (NSTimeInterval)fetchCurrentTimeStampMs;
- (void)stopAutoPlay;
- (void)removeUncompleteTimestamp;

@end
