//
//  QHVCEditOverlayTemplateView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayTemplateView.h"
#import "QHVCEditOverlayTemplateCell.h"
#import "QHVCEditPrefs.h"

static NSString* templateCellIdentifier = @"QHVCEditTemplateCell";

@interface QHVCEditOverlayTemplateView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *templateCollection;
@property (nonatomic, retain) NSArray* templateArray;
@property (nonatomic, assign) NSInteger templateIndex;

@end

@implementation QHVCEditOverlayTemplateView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.templateCollection registerNib:[UINib nibWithNibName:@"QHVCEditOverlayTemplateCell" bundle:nil] forCellWithReuseIdentifier:templateCellIdentifier];
    [self.templateCollection setDataSource:self];
    [self.templateCollection setDelegate:self];
    self.templateIndex = [QHVCEditPrefs sharedPrefs].overlayTemplateIndex;
    self.templateArray = @[@"edit_overlay_template_1",
                           @"edit_overlay_template_2",
                           @"edit_overlay_template_3"];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.templateArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditOverlayTemplateCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:templateCellIdentifier forIndexPath:indexPath];
    UIImage* image = [UIImage imageNamed:[self.templateArray objectAtIndex:indexPath.row]];
    [cell updateCell:image index:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.templateIndex = indexPath.row;
    [[QHVCEditPrefs sharedPrefs] setOverlayTemplateIndex:indexPath.row];
    [collectionView reloadData];
}

@end
