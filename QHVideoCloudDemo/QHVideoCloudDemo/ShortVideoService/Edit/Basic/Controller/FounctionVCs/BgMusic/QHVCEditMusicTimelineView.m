//
//  QHVCEditMusicTimelineView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2019/7/3.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditMusicTimelineView.h"
#import "QHVCEditTimelineView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditMusicTimelineView ()
@property (weak, nonatomic) IBOutlet UIView *timelineContainer;
@property (nonatomic, retain) QHVCEditTimelineView* timelineView;
@end

@implementation QHVCEditMusicTimelineView

- (void)dealloc
{
    [self.timelineView removeFromSuperview];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.timelineView = [[NSBundle mainBundle] loadNibNamed:@"QHVCEditTimelineView" owner:self options:nil][0];
    [self.timelineView setFrame:CGRectMake(0, 0,
                                           self.timelineContainer.frame.size.width,
                                           self.timelineContainer.frame.size.height)];
    [self.timelineContainer addSubview:self.timelineView];
    [self.timelineView setPlayerBaseVC:self.playerBaseVC];
}

- (void)pause
{
    [self.timelineView pause];
}

- (void)play
{
    [self.timelineView play];
}

- (IBAction)onAddBtnClicked:(id)sender
{
    SAFE_BLOCK(self.addAction);
}

@end
