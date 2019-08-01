//
//  QHVCEditQuality.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/3/13.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditQualityView.h"
#import "QHVCEditQualityItem.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig+Advanced.h"

static NSString* qualityItemCellIdentifier = @"QHVCEditQualityItemCell";

@interface QHVCEditQualityView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) NSArray* qualityItemArray;

@end

@implementation QHVCEditQualityView

- (void)prepareSubviews
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"QHVCEditQualityItem" bundle:nil] forCellWithReuseIdentifier:qualityItemCellIdentifier];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    NSString* listPath = [[NSBundle mainBundle] pathForResource:@"QHVCEditQualityList" ofType:@"plist"];
    NSArray* listArray = [NSArray arrayWithContentsOfFile:listPath];
    if ([listArray count] > 0)
    {
        self.qualityItemArray = listArray;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.qualityItemArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditQualityItem* cell = [collectionView dequeueReusableCellWithReuseIdentifier:qualityItemCellIdentifier
                                                                          forIndexPath:indexPath];
    NSDictionary* item = self.qualityItemArray[indexPath.row];
    if (item)
    {
        NSString* name = [item objectForKey:@"name"];
        NSNumber* min = [item objectForKey:@"min"];
        NSNumber* max = [item objectForKey:@"max"];
        
        QHVCEditQualityEffect* qualityEffect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] qualityEffect];
        NSInteger value = [self getQualityValue:qualityEffect index:(int)indexPath.row];
        [cell updateCell:name
                     tag:(int)indexPath.row
                minValue:[min intValue]
                maxValue:[max intValue]
                curValue:(int)value];
        
        WEAK_SELF
        [cell setValueChanged:^(int tag, int value)
        {
            STRONG_SELF
            [self updateQualityEffect:tag value:value];
        }];
    }
    return cell;
}

#pragma mark - Media Editor Methods

- (void)updateQualityEffect:(int)index value:(int)value
{
    QHVCEditQualityEffect* qualityEffect = [[QHVCEditMediaEditorConfigAdvanced sharedInstance] qualityEffect];
    if (qualityEffect)
    {
        //update
        [self updateQualityValue:qualityEffect index:index value:value];
        [[QHVCEditMediaEditor sharedInstance] updateMainVideoTrackEffect:qualityEffect];
        SAFE_BLOCK(self.refreshPlayerBlock, YES);
    }
    else
    {
        //add
        QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
        QHVCEditTrack* videoTrack = [[QHVCEditMediaEditor sharedInstance] mainTrack];
        QHVCEditQualityEffect* effect = [[QHVCEditQualityEffect alloc] initEffectWithTimeline:timeline];
        [self updateQualityValue:effect index:index value:value];
        [effect setStartTime:0];
        [effect setEndTime:[videoTrack duration]];
        [[QHVCEditMediaEditor sharedInstance] addEffectToMainVideoTrack:effect];
        [[QHVCEditMediaEditorConfigAdvanced sharedInstance] setQualityEffect:effect];
        SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
    }
}

- (void)updateQualityValue:(QHVCEditQualityEffect *)effect index:(int)index value:(int)value
{
    if (!effect)
    {
        return;
    }
    
    NSString* func = [self.qualityItemArray[index] objectForKey:@"func"];
    NSString* funcName = [NSString stringWithFormat:@"set%@:", func];
    
    SEL funcSelector = NSSelectorFromString(funcName);
    if ([effect respondsToSelector:funcSelector])
    {
        IMP imp = [effect methodForSelector:funcSelector];
        void (*func)(id, SEL, NSInteger) = (void *)imp;
        func(effect, funcSelector, value);
    }
}

- (NSInteger)getQualityValue:(QHVCEditQualityEffect *)effect index:(int)index
{
    if (!effect)
    {
        return 0;
    }
    
    NSString* func = [self.qualityItemArray[index] objectForKey:@"func"];
    NSString* firstLetter = [func substringToIndex:1];
    NSString* funcName = [NSString stringWithFormat:@"%@%@",
                          [firstLetter lowercaseString],
                          [func substringFromIndex:1]];
    NSInteger value = 0;
    
    SEL funcSelector = NSSelectorFromString(funcName);
    if ([effect respondsToSelector:funcSelector])
    {
        IMP imp = [effect methodForSelector:funcSelector];
        NSInteger (*func)(id, SEL) = (void *)imp;
        value = func(effect, funcSelector);
    }
    
    return value;
}

@end
