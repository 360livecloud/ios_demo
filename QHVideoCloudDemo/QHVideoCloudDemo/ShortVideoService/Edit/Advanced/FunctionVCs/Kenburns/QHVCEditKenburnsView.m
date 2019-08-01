//
//  QHVCEditKenburnsView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/18.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditKenburnsView.h"
#import "QHVCEditCollectionCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig+Advanced.h"

static NSString * const kenburnsCellIdentifier = @"QHVCEditCollectionCell";

@interface QHVCEditKenburnsView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, retain) NSArray* effectArray;

@end

@implementation QHVCEditKenburnsView

- (void)prepareSubviews
{
    [_collectionView registerNib:[UINib nibWithNibName:kenburnsCellIdentifier bundle:nil] forCellWithReuseIdentifier:kenburnsCellIdentifier];
    NSString* listPath = [[NSBundle mainBundle] pathForResource:@"QHVCEditKenburnsList" ofType:@"plist"];
    NSArray* listArray = [NSArray arrayWithContentsOfFile:listPath];
    if ([listArray count] > 0)
    {
        self.effectArray = listArray;
    }
    
    CGFloat intensity = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsIntensity];
    [self.slider setValue:intensity];
}


- (IBAction)onSliderValueChanged:(UISlider *)sender
{
    NSInteger index = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsIndex];
    [self updateEffect:index intensity:sender.value];
}

#pragma mark - CollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _effectArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kenburnsCellIdentifier forIndexPath:indexPath];
    if (indexPath.row < [_effectArray count])
    {
        NSDictionary* item = self.effectArray[indexPath.row];
        NSString* title = [item objectForKey:@"name"];
        NSString* imageName = [item objectForKey:@"icon"];
        [cell updateCell:title imageName:imageName];
        
        NSInteger curIndex = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsIndex];
        [cell setSelected:(curIndex == indexPath.row ? YES:NO)];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(45, 65);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat intensity = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsIntensity];
    [self updateEffect:indexPath.row intensity:intensity];
    [self.collectionView reloadData];
}

#pragma mark - Media Edit Methods

- (void)updateEffect:(NSInteger)index intensity:(CGFloat)intensity
{
    NSInteger curIndex = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsIndex];
    CGFloat curIntensity = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsIntensity];
    if (curIndex == index && curIntensity == intensity)
    {
        return;
    }
    
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setKenburnsIntensity:intensity];
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setKenburnsIndex:index];
    QHVCEditKenburnsEffect* effect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsEffect];
    if (index == 0)
    {
        //delete
        if (effect)
        {
            [[QHVCEditMediaEditor sharedInstance] deleteMainVideoTrackEffect:effect];
            [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setKenburnsEffect:nil];
            SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
        }
    }
    else
    {
        CGFloat intensity = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] kenburnsIntensity];
        if (effect)
        {
            //update
            [self updateEffectParam:effect index:index intensity:intensity];
            [[QHVCEditMediaEditor sharedInstance] updateMainVideoTrackEffect:effect];
            SAFE_BLOCK(self.refreshPlayerBlock, YES);
        }
        else
        {
            //add
            QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
            effect = [[QHVCEditKenburnsEffect alloc] initEffectWithTimeline:timeline];
            [self updateEffectParam:effect index:index intensity:intensity];
            
            QHVCEditTrack* mainTrack = [[QHVCEditMediaEditor sharedInstance] mainTrack];
            [effect setStartTime:0];
            [effect setEndTime:[mainTrack duration]];
            
            [[QHVCEditMediaEditor sharedInstance] addEffectToMainVideoTrack:effect];
            [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setKenburnsEffect:effect];
            SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
        }
    }
}

- (void)updateEffectParam:(QHVCEditKenburnsEffect *)effect index:(NSInteger)index intensity:(CGFloat)intensity
{
    NSDictionary* item = [self.effectArray[index] objectForKey:@"info"];
    CGFloat fromScale = [[item objectForKey:@"fromScale"] floatValue];
    CGFloat toScale = [[item objectForKey:@"toScale"] floatValue];
    CGFloat fromX = [[item objectForKey:@"fromX"] floatValue] * intensity;
    CGFloat toX = [[item objectForKey:@"toX"] floatValue] * intensity;
    CGFloat fromY = [[item objectForKey:@"fromY"] floatValue] * intensity;
    CGFloat toY = [[item objectForKey:@"toY"] floatValue] * intensity;
    
    if (index == 1)
    {
        //拉远
        fromScale = fromScale * intensity;
    }
    else if (index == 2)
    {
        //推近
        toScale = toScale * intensity;
    }

    [effect setFromScale:fromScale];
    [effect setToScale:toScale];
    [effect setFromX:fromX];
    [effect setToX:toX];
    [effect setFromY:fromY];
    [effect setToY:toY];
}

@end
