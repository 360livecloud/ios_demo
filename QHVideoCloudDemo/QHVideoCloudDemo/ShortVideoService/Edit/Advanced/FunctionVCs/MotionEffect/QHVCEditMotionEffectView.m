//
//  QHVCEditMotionEffectView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/29.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditMotionEffectView.h"
#import "QHVCEditCollectionCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig+Advanced.h"

static NSString * const motionEffectCellIdentifier = @"QHVCEditCollectionCell";

@interface QHVCEditMotionEffectView ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) NSArray* effectArray;

@end

@implementation QHVCEditMotionEffectView

- (void)prepareSubviews
{
    [_collectionView registerNib:[UINib nibWithNibName:motionEffectCellIdentifier bundle:nil] forCellWithReuseIdentifier:motionEffectCellIdentifier];
    NSString* listPath = [[NSBundle mainBundle] pathForResource:@"QHVCEditMotionEffectList" ofType:@"plist"];
    NSArray* listArray = [NSArray arrayWithContentsOfFile:listPath];
    if ([listArray count] > 0)
    {
        self.effectArray = listArray;
    }
}

#pragma mark - CollectionView Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _effectArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:motionEffectCellIdentifier forIndexPath:indexPath];
    if (indexPath.row < [_effectArray count])
    {
        NSDictionary* item = self.effectArray[indexPath.row];
        NSString* title = [item objectForKey:@"name"];
        NSString* imageName = [item objectForKey:@"icon"];
        [cell updateCell:title imageName:imageName];
        
        NSInteger curIndex = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] motionEffectIndex];
        [cell setSelected:(curIndex == indexPath.row ? YES:NO)];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 74);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateEffect:indexPath.row];
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setMotionEffectIndex:indexPath.row];
    [self.collectionView reloadData];
}

#pragma mark - Media Editor Methods

- (void)updateEffect:(NSInteger)index
{
    QHVCEditMotionEffect* effect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] motionEffect];
    if (index == 0)
    {
        //delete
        if (effect)
        {
            [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setMotionEffect:nil];
            [[QHVCEditMediaEditor sharedInstance] deleteMainVideoTrackEffect:effect];
            SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
        }
        return;
    }
    
    NSDictionary* item = self.effectArray[index];
    NSString* effectName = [item objectForKey:@"effect"];
    if (effect)
    {
        //update
        if (![effectName isEqualToString:effect.effectName])
        {
            [effect setEffectName:effectName];
            [[QHVCEditMediaEditor sharedInstance] updateMainVideoTrackEffect:effect];
            SAFE_BLOCK(self.refreshPlayerBlock, YES);
        }
    }
    else
    {
        //add
        QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
        QHVCEditTrack* videoTrack = [[QHVCEditMediaEditor sharedInstance] getMainVideoTrack];
        effect = [[QHVCEditMotionEffect alloc] initEffectWithTimeline:timeline];
        [effect setEffectName:effectName];
        [effect setStartTime:0];
        [effect setEndTime:[videoTrack duration]];
        [[QHVCEditMediaEditor sharedInstance] addEffectToMainVideoTrack:effect];
        [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setMotionEffect:effect];
        SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
    }
}

@end
