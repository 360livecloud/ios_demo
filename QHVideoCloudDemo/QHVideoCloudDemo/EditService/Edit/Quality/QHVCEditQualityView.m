//
//  QHVCEditQualityView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditQualityView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditQualityItem.h"

static NSString* qualityItemCellIdentifier = @"QHVCEditQualityItemCell";

@interface QHVCEditQualityView() <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
{
    __weak IBOutlet UIView *_containerView;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) NSArray* qualityItemArray;

@end

@implementation QHVCEditQualityView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    NSInteger i = 0;
//    for (NSNumber *v in [QHVCEditPrefs sharedPrefs].qualitys) {
//        UIView *view = [_containerView viewWithTag:i+1];
//        UISlider *slider = [view viewWithTag:i];
//        slider.value = v.floatValue;
//        i++;
//    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"QHVCEditQualityItem" bundle:nil] forCellWithReuseIdentifier:qualityItemCellIdentifier];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    self.qualityItemArray = @[@[@"亮度", @(-100), @(100)],
                              @[@"对比度", @(-100), @(100)],
                              @[@"曝光度", @(-100), @(100)],
                              @[@"补偿", @(-100), @(100)],
                              @[@"色温", @(-100), @(100)],
                              @[@"色调", @(-100), @(100)],
                              @[@"饱和度", @(-100), @(100)],
                              @[@"色相", @(-180), @(180)],
                              @[@"鲜艳度", @(-100), @(100)],
                              @[@"暗角", @(0), @(100)],
                              @[@"色散", @(0), @(100)],
                              @[@"褪色", @(0), @(100)],
                              @[@"高光减弱", @(0), @(100)],
                              @[@"阴影补偿", @(0), @(100)],
                              @[@"肤色", @(-100), @(100)],
                              @[@"锐度", @(0), @(100)],
                              @[@"颗粒噪声", @(0), @(100)],
                              @[@"高光橙色", @(0), @(100)],
                              @[@"高光奶油色", @(0), @(100)],
                              @[@"高光黄色", @(0), @(100)],
                              @[@"高光绿色", @(0), @(100)],
                              @[@"高光蓝色", @(0), @(100)],
                              @[@"高光洋红色", @(0), @(100)],
                              @[@"阴影红色", @(0), @(100)],
                              @[@"阴影橙色", @(0), @(100)],
                              @[@"阴影黄色", @(0), @(100)],
                              @[@"阴影绿色", @(0), @(100)],
                              @[@"阴影蓝色", @(0), @(100)],
                              @[@"阴影紫色", @(0), @(100)]];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.qualityItemArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditQualityItem* cell = [collectionView dequeueReusableCellWithReuseIdentifier:qualityItemCellIdentifier forIndexPath:indexPath];
    NSString* name = self.qualityItemArray[indexPath.row][0];
    int min = [self.qualityItemArray[indexPath.row][1] intValue];
    int max = [self.qualityItemArray[indexPath.row][2] intValue];
    [cell updateCell:name tag:(int)indexPath.row minValue:min maxValue:max];
    [cell setValueChanged:^(int tag, float value)
    {
        SAFE_BLOCK(self.changeCompletion, tag, value);
    }];
    return cell;
}

@end
