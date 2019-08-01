//
//  QHVCEditFilterView.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/29.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditFilterView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditFilterCell.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"

static NSString * const filterCellIdentifier = @"QHVCEditFilterCell";

@interface  QHVCEditFilterView()
{
    __weak IBOutlet UICollectionView *_filterCollectionView;
    NSInteger _selectedIndex;
}

@property (nonatomic, strong) NSArray<NSDictionary *> *filters;

@end

@implementation QHVCEditFilterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_filterCollectionView registerNib:[UINib nibWithNibName:filterCellIdentifier bundle:nil] forCellWithReuseIdentifier:filterCellIdentifier];
    _selectedIndex = [QHVCEditMediaEditorConfig sharedInstance].filterIndex;
    
    _filters = @[@{@"title":@"原图",@"name":@""},
                 @{@"title":@"自然",@"name":@"lut_1.png"},
                 @{@"title":@"清新",@"name":@"lut_2.png"},
                 @{@"title":@"水光",@"name":@"lut_3.png"},
                 @{@"title":@"粉嫩",@"name":@"lut_4.png"},
                 @{@"title":@"白皙",@"name":@"lut_5.png"},
                 @{@"title":@"纯真",@"name":@"lut_6.png"},
                 @{@"title":@"初恋",@"name":@"lut_7.png"},
                 @{@"title":@"蜜桃",@"name":@"lut_8.png"},
                 @{@"title":@"暖光",@"name":@"lut_9.png"},
                 @{@"title":@"糖果",@"name":@"lut_10.png"},
                 @{@"title":@"淡雅",@"name":@"lut_11.png"},
                 @{@"title":@"酒红",@"name":@"lut_12.png"},
                 @{@"title":@"焦糖",@"name":@"lut_13.png"},
                 @{@"title":@"湖畔",@"name":@"lut_14.png"},
                 @{@"title":@"日落",@"name":@"lut_15.png"},
                 @{@"title":@"薄荷",@"name":@"lut_16.png"},
                 @{@"title":@"黑白",@"name":@"lut_17.png"},
                 ];
}

- (void)confirmAction
{
    SAFE_BLOCK(self.confirmBlock, self);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _filters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCEditFilterCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:filterCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_filters[indexPath.row] filterIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70, 90);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedIndex == indexPath.row)
    {
        return;
    }

    [self updateFilter:indexPath.row];
    [_filterCollectionView reloadData];
}

- (void)updateFilter:(NSInteger)index
{
    //更新当前index
    _selectedIndex = index;
    [QHVCEditMediaEditorConfig sharedInstance].filterIndex = index;
    QHVCEditFilterEffect* filter = [[QHVCEditMediaEditorConfig sharedInstance] effectFilter];
    
    //原图，删除特效
    if (index == 0)
    {
        if (!filter)
        {
            return;
        }
        
        [[QHVCEditMediaEditor sharedInstance] deleteTimelineEffect:filter];
        [[QHVCEditMediaEditorConfig sharedInstance] setEffectFilter:nil];
        SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
        return;
    }

    //更新特效
    NSDictionary *item = _filters[index];
    NSString* name = [item objectForKey:@"name"];
    NSString* path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], name];
    if (filter)
    {
        //更新
        [filter setFilePath:path];
        [[QHVCEditMediaEditor sharedInstance] updateTimelineEffect:filter];
        SAFE_BLOCK(self.refreshPlayerBlock, YES);
    }
    else
    {
        //新增
        QHVCEditFilterEffect* filter = [self createEffectFilter];
        [filter setFilePath:path];
        [filter setStartTime:0];
        [filter setEndTime:[[QHVCEditMediaEditor sharedInstance] getTimelineDuration]];
        [[QHVCEditMediaEditorConfig sharedInstance] setEffectFilter:filter];
        [[QHVCEditMediaEditor sharedInstance] addEffectToTimeline:filter];
        SAFE_BLOCK(self.refreshForEffectBasicParamsBlock);
    }
}

//滤镜
- (QHVCEditFilterEffect *)createEffectFilter
{
    QHVCEditTimeline* timeline = [[QHVCEditMediaEditor sharedInstance] timeline];
    QHVCEditFilterEffect* filter = [[QHVCEditFilterEffect alloc] initEffectWithTimeline:timeline];
    return filter;
}

@end
