//
//  QHVCEditOverlayBlendView.m
//  QHVideoCloudToolSetDebug
//
//  Created by liyue-g on 2018/5/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayBlendView.h"
#import "QHVCEditCommonCell.h"
#import "QHVCEditPrefs.h"

static NSString* fileCellIdentifier = @"QHVCEditOverlayBlendModeCell";

@interface QHVCEditOverlayBlendView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *blendModeCollection;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (nonatomic, retain) NSMutableArray* blendModeArray;
@property (nonatomic, assign) NSInteger curModeIndex;

@end

@implementation QHVCEditOverlayBlendView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.blendModeCollection registerNib:[UINib nibWithNibName:@"QHVCEditCommonCell" bundle:nil] forCellWithReuseIdentifier:fileCellIdentifier];
    [self.blendModeCollection setDataSource:self];
    [self.blendModeCollection setDelegate:self];

    self.blendModeArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableArray* array0 = [[NSMutableArray alloc] initWithCapacity:0];
    [array0 addObject:@"正常"];
    [array0 addObject:@"edit_overlay_normal"];
    [array0 addObject:@1];
    [self.blendModeArray addObject:array0];
    
    NSMutableArray* array1 = [[NSMutableArray alloc] initWithCapacity:0];
    [array1 addObject:@"叠加"];
    [array1 addObject:@"edit_overlay_overlay"];
    [array1 addObject:@1];
    [self.blendModeArray addObject:array1];
    
    NSMutableArray* array2 = [[NSMutableArray alloc] initWithCapacity:0];
    [array2 addObject:@"多倍"];
    [array2 addObject:@"edit_overlay_multiply"];
    [array2 addObject:@1];
    [self.blendModeArray addObject:array2];
    
    NSMutableArray* array3 = [[NSMutableArray alloc] initWithCapacity:0];
    [array3 addObject:@"屏幕"];
    [array3 addObject:@"edit_overlay_screen"];
    [array3 addObject:@1];
    [self.blendModeArray addObject:array3];
    
    NSMutableArray* array4 = [[NSMutableArray alloc] initWithCapacity:0];
    [array4 addObject:@"柔光"];
    [array4 addObject:@"edit_overlay_softLight"];
    [array4 addObject:@1];
    [self.blendModeArray addObject:array4];
    
    NSMutableArray* array5 = [[NSMutableArray alloc] initWithCapacity:0];
    [array5 addObject:@"强光"];
    [array5 addObject:@"edit_overlay_hardLight"];
    [array5 addObject:@1];
    [self.blendModeArray addObject:array5];
    
    NSMutableArray* array6 = [[NSMutableArray alloc] initWithCapacity:0];
    [array6 addObject:@"变暗"];
    [array6 addObject:@"edit_overlay_darken"];
    [array6 addObject:@1];
    [self.blendModeArray addObject:array6];
    
    NSMutableArray* array7 = [[NSMutableArray alloc] initWithCapacity:0];
    [array7 addObject:@"颜色加深"];
    [array7 addObject:@"edit_overlay_colorBurn"];
    [array7 addObject:@1];
    [self.blendModeArray addObject:array7];
    
    NSMutableArray* array8 = [[NSMutableArray alloc] initWithCapacity:0];
    [array8 addObject:@"变亮"];
    [array8 addObject:@"edit_overlay_lighten"];
    [array8 addObject:@1];
    [self.blendModeArray addObject:array8];
    
    NSMutableArray* array9 = [[NSMutableArray alloc] initWithCapacity:0];
    [array9 addObject:@"更亮"];
    [array9 addObject:@"edit_overlay_linearDodge"];
    [array9 addObject:@1];
    [self.blendModeArray addObject:array9];
    
    NSMutableArray* array10 = [[NSMutableArray alloc] initWithCapacity:0];
    [array10 addObject:@"更暗"];
    [array10 addObject:@"edit_overlay_linearBurn"];
    [array10 addObject:@1];
    [self.blendModeArray addObject:array10];
}

- (IBAction)clickedBackBtn:(UIButton *)sender
{
    [self removeFromSuperview];
}

- (IBAction)onProgressChanged:(UISlider *)sender
{
    NSMutableArray* array = [self.blendModeArray objectAtIndex:self.curModeIndex];
    array[2] = @(sender.value);
    SAFE_BLOCK(self.blendAction, self.curModeIndex, sender.value);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.blendModeArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditCommonCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:fileCellIdentifier forIndexPath:indexPath];
    if ([self.blendModeArray count] > indexPath.row)
    {
        NSString* thumbStr = self.blendModeArray[indexPath.row][1];
        NSString* title = self.blendModeArray[indexPath.row][0];
        [cell updateCell:title imageName:thumbStr];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.curModeIndex = indexPath.row;
    NSArray* dict = [self.blendModeArray objectAtIndex:indexPath.row];
    CGFloat progress = [dict[2] floatValue];
    [self.progressSlider setValue:progress];
    SAFE_BLOCK(self.blendAction, indexPath.row, progress);
}

@end
