//
//  QHVCEditDynamicSubtitleView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/9.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditDynamicSubtitleView.h"
#import "QHVCEditMediaEditorConfig+Advanced.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditPlayerBaseVC.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditDynamicSubtitleTimelineView.h"
#import "QHVCEditCollectionCell.h"

static NSString* const QHVCEditDynamicSubtitleCellIdentifier = @"QHVCEditCollectionCell";

@interface QHVCEditDynamicSubtitleView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *timelineContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) QHVCEditDynamicSubtitleTimelineView* timelineView;
@property (nonatomic, retain) NSMutableArray* effects;
@property (nonatomic, retain) NSArray* resArray;

@end

@implementation QHVCEditDynamicSubtitleView

- (void)dealloc
{
    [self.timelineView removeFromSuperview];
}

- (void)prepareSubviews
{
    [super prepareSubviews];
    [self.collectionView registerNib:[UINib nibWithNibName:@"QHVCEditCollectionCell" bundle:nil] forCellWithReuseIdentifier:QHVCEditDynamicSubtitleCellIdentifier];
    
    [self setCancelButtonState:NO];
    SAFE_BLOCK(self.seekPlayerBlock, YES, 0);
    SAFE_BLOCK(self.pausePlayerBlock);
    SAFE_BLOCK(self.hidePlayButtonBolck, YES);
    
    //timeline view
    self.timelineView = [[QHVCEditDynamicSubtitleTimelineView alloc] init];
    [self.timelineView setFrame:CGRectMake(0, 0,
                                           self.timelineContainer.frame.size.width,
                                           self.timelineContainer.frame.size.height)];
    [self.timelineContainer addSubview:self.timelineView];
    [self.timelineView setPlayerBaseVC:self.playerBaseVC];
    
    self.effects = [NSMutableArray array];
    self.resArray = @[@[@"test1.ass", @(26650)],
                      @[@"test2.ass", @(1020)],
                      @[@"test3.ass", @(9000)]];
}

- (void)confirmAction
{
    [super confirmAction];
    SAFE_BLOCK(self.pausePlayerBlock);
    SAFE_BLOCK(self.seekPlayerBlock, YES, 0);
    SAFE_BLOCK(self.hidePlayButtonBolck, NO);
}

- (void)cancelAction
{
    [super cancelAction];
    [self clearAllEffects];
    SAFE_BLOCK(self.pausePlayerBlock);
    SAFE_BLOCK(self.seekPlayerBlock, YES, 0);
    SAFE_BLOCK(self.hidePlayButtonBolck, NO);
}

#pragma mark - Media Editor Methods

- (void)addEffect:(NSString *)path duration:(NSInteger)duration
{
    QHVCEditTrack* track = [[QHVCEditMediaEditor sharedInstance] mainTrack];
    NSInteger curTime = [self.playerBaseVC curPlayerTime];
    NSInteger endTime = curTime + MIN([track duration], duration);
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    QHVCEditDynamicSubtitleEffect* effect = [[QHVCEditDynamicSubtitleEffect alloc] initEffectWithTimeline:timeline];
    [effect setStartTime:curTime];
    [effect setEndTime:endTime];
    [effect setConfigFilePath:path];
    [[QHVCEditMediaEditor sharedInstance] addEffectToMainVideoTrack:effect];
    [self.playerBaseVC refreshPlayerForEffectBasicParams];
    [self.effects addObject:effect];
}

- (void)clearAllEffects
{
    [self.effects enumerateObjectsUsingBlock:^(QHVCEditDynamicSubtitleEffect* obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [[QHVCEditMediaEditor sharedInstance] deleteMainVideoTrackEffect:obj];
    }];
    [self.playerBaseVC refreshPlayerForEffectBasicParams];
}

#pragma mark - Collection Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_resArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(35, 50);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:QHVCEditDynamicSubtitleCellIdentifier forIndexPath:indexPath];
    [cell updateCell:[NSString stringWithFormat:@"字幕%d", (int)indexPath.row + 1] imageName:@"edit_item"];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* item = [_resArray objectAtIndex:indexPath.row];
    NSString* name = item[0];
    NSInteger duration = [item[1] integerValue];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    [self.timelineView addMaskWithDuration:duration];
    [self addEffect:path duration:duration];
}

@end
