//
//  QHVCEditOverlayBlendView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/9.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditOverlayBlendView.h"
#import "QHVCEditCollectionCell.h"
#import "QHVCEditOverlayItemView.h"
#import "QHVCEditPlayerBaseVC.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig+Advanced.h"

static NSString* fileCellIdentifier = @"QHVCEditCollectionCell";

@interface QHVCEditOverlayBlendView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *blendModeCollection;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (nonatomic, retain) NSMutableArray* blendModeArray;

@end

@implementation QHVCEditOverlayBlendView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.blendModeCollection registerNib:[UINib nibWithNibName:fileCellIdentifier bundle:nil] forCellWithReuseIdentifier:fileCellIdentifier];
    [self.blendModeCollection setDataSource:self];
    [self.blendModeCollection setDelegate:self];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"QHVCEditOverlayBlendList" ofType:@"plist"];
    NSArray* array = [NSArray arrayWithContentsOfFile:path];
    if ([array count] > 0)
    {
        self.blendModeArray = [[NSMutableArray alloc] initWithArray:array];
    }
    
    CGFloat progress = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] blendValue];
    [self.progressSlider setValue:progress];
}

- (IBAction)clickedBackBtn:(UIButton *)sender
{
    [self removeFromSuperview];
}

- (IBAction)onProgressChanged:(UISlider *)sender
{
    NSInteger index = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] blendIndex];
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setBlendValue:sender.value];
    [self updateEffect:index isEnd:NO];
}

- (IBAction)onSliderTouchUpInside:(UISlider *)sender
{
    NSInteger index = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] blendIndex];
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setBlendValue:sender.value];
    [self updateEffect:index isEnd:YES];
}

#pragma mark - Collection Methods

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.blendModeArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:fileCellIdentifier forIndexPath:indexPath];
    if ([self.blendModeArray count] > indexPath.row)
    {
        NSString* thumbStr = self.blendModeArray[indexPath.row][1];
        NSString* title = self.blendModeArray[indexPath.row][0];
        [cell updateCell:title imageName:thumbStr];
        
        NSInteger selectIndex = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] blendIndex];
        [cell setSelected:(selectIndex == indexPath.row) ? YES:NO];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat defaultValue = 1.0;
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setBlendValue:defaultValue];
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setBlendIndex:indexPath.row];
    [self.progressSlider setValue:defaultValue];
    [self.blendModeCollection reloadData];
    [self updateEffect:indexPath.row isEnd:YES];
}

#pragma mark - Media Editor Methods

- (void)updateEffect:(NSInteger)index isEnd:(BOOL)isEnd
{
    QHVCEditBlendEffect* blendEffect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] blendEffect];
    CGFloat progress = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] blendValue];
    
    if (!blendEffect)
    {
        //add
        QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
        QHVCEditTrack* track = (QHVCEditTrack*)[self.itemView.clipItem.clip superObj];
        blendEffect = [[QHVCEditBlendEffect alloc] initEffectWithTimeline:timeline];
        [blendEffect setStartTime:0];
        [blendEffect setEndTime:[track duration]];
        [blendEffect setBlendType:(QHVCEffectBlendType)index];
        [blendEffect setIntensity:progress];
        [[QHVCEditMediaEditor sharedInstance] overlayTrack:self.itemView.clipItem addEffect:blendEffect];
        [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setBlendEffect:blendEffect];
        [self.playerVC refreshPlayerForEffectBasicParams];
    }
    else
    {
        //update
        [blendEffect setBlendType:(QHVCEffectBlendType)index];
        [blendEffect setIntensity:progress];
        [self.playerVC refreshPlayer:isEnd];
    }
    
}

@end
