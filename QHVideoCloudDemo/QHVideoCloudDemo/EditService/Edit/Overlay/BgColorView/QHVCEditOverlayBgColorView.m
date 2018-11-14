//
//  QHVCEditOverlayBgColorView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayBgColorView.h"
#import "QHVCEditOverlayBgColorCell.h"
#import "QHVCEditPrefs.h"

static NSString* bgColorCellIdentifier = @"QHVCEditBgColorCell";

@interface QHVCEditOverlayBgColorView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *bgColorCollection;
@property (nonatomic, retain) NSArray* bgColorArray;
@property (nonatomic, assign) NSInteger bgColorIndex;

@end

@implementation QHVCEditOverlayBgColorView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.bgColorCollection registerNib:[UINib nibWithNibName:@"QHVCEditOverlayBgColorCell" bundle:nil] forCellWithReuseIdentifier:bgColorCellIdentifier];
    [self.bgColorCollection setDataSource:self];
    [self.bgColorCollection setDelegate:self];
    self.bgColorIndex = [QHVCEditPrefs sharedPrefs].colorIndex;
    self.bgColorArray = @[@"FF000000",
                          @"FF272533",
                          @"FF332525",
                          @"FF253331"];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.bgColorArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditOverlayBgColorCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:bgColorCellIdentifier forIndexPath:indexPath];
    UIColor* color = [QHVCEditPrefs colorARGBHex:[self.bgColorArray objectAtIndex:indexPath.row]];
    [cell updateCell:color index:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.bgColorIndex == indexPath.row)
    {
        return;
    }
    
    self.bgColorIndex = indexPath.row;
    [[QHVCEditPrefs sharedPrefs] setOverlayBgColorIndex:indexPath.row];
    [collectionView reloadData];
    NSString* color = [self.bgColorArray objectAtIndex:indexPath.row];
    SAFE_BLOCK_IN_MAIN_QUEUE(self.changeColorAction, color);
}

@end
