//
//  QHVCEditDynamicSubtitleTimelineView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/11.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditDynamicSubtitleTimelineView.h"
#import "QHVCEditTimelineView.h"
#import "QHVCEditPlayerBaseVC.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditDynamicSubtitleTimelineView ()
@property (nonatomic, retain) QHVCEditTimelineView* timelineView;
@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerBaseVC;

@end

@implementation QHVCEditDynamicSubtitleTimelineView

- (void)dealloc
{
    [self.timelineView removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    self.timelineView =[[NSBundle mainBundle] loadNibNamed:@"QHVCEditTimelineView" owner:self options:nil][0];
    [self.timelineView setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self.timelineView setPlayerBaseVC:self.playerBaseVC];
    [self addSubview:self.timelineView];
}

- (void)setPlayerBaseVC:(QHVCEditPlayerBaseVC *)playerBaseVC
{
    _playerBaseVC = playerBaseVC;
}

- (void)addMaskWithDuration:(NSInteger)duration
{
    NSInteger curTime = [self.timelineView timelineTimestamp];
    NSInteger totalTime = self.playerBaseVC.playerDuration;
    NSInteger actualDuration = MIN(totalTime - curTime, duration);
    CGSize size = self.timelineView.collectionView.contentSize;
    CGFloat x = (float)curTime * size.width/totalTime;
    CGFloat w = (float)actualDuration * size.width/totalTime;
    
    float random = (arc4random()%100)/100.0;
    UIColor* color = [UIColor colorWithHue:random saturation:1.0 brightness:1.0 alpha:0.3];
    
    CGRect rect = CGRectMake(x, 0, w, size.height);
    UIView* mask = [[UIView alloc] initWithFrame:rect];
    [mask setBackgroundColor:color];
    [self.timelineView.collectionView addSubview:mask];
}

@end
