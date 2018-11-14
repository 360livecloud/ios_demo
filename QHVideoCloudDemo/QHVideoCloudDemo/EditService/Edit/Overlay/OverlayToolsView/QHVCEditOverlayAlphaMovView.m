//
//  QHVCEditOverlayAlphaMovView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/3/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayAlphaMovView.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditPhotoManager.h"

static NSString* fileCellIdentifier = @"QHVCEditOverlayMovItemCell";

@interface QHVCEditOverlayAlphaMovView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *fileCollection;
@property (nonatomic, retain) NSMutableArray* fileArray;

@end

@implementation QHVCEditOverlayAlphaMovView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.fileCollection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:fileCellIdentifier];
    [self.fileCollection setDataSource:self];
    [self.fileCollection setDelegate:self];
    self.fileArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray* items = @[@[@"alpha_mov.mov", @"edit_overlay_photo", @"mov"],
                       @[@"alpha_webm1.webm", @"edit_overlay_photo", @"webm1"],
                       @[@"alpha_webm2.webm", @"edit_overlay_photo", @"webm2"]];
    [self.fileArray addObjectsFromArray:items];
}

- (IBAction)clickedBackBtn:(UIButton *)sender
{
    [self removeFromSuperview];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.fileArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:fileCellIdentifier forIndexPath:indexPath];
    if ([self.fileArray count] > indexPath.row)
    {
        UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 75)];
        
        NSString* thumbStr = self.fileArray[indexPath.row][1];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setImage:[UIImage imageNamed:thumbStr]];
        [contentView addSubview:imageView];
        
        NSString* title = self.fileArray[indexPath.row][2];
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 55, 20)];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:12]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setText:title];
        [contentView addSubview:titleLabel];
        
        [cell.contentView addSubview:contentView];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* fileNameStr = self.fileArray[indexPath.row][0];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileNameStr ofType:nil];
    SAFE_BLOCK(self.changeAlphaMovAction, filePath);
}

@end
