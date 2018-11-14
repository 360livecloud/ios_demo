//
//  QHVCEditAddAudioView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAddAudioView.h"
#import "QHVCEditAddAudioCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditAudioItem.h"

static NSString * const audioCellIdentifier = @"QHVCEditAddAudioCell";

@interface QHVCEditAddAudioView()
{
    __weak IBOutlet UISlider *_originSlider;
    __weak IBOutlet UISlider *_audioSlider;
    __weak IBOutlet UICollectionView *_collectionView;
    NSArray *_audiosArray;
    NSInteger _audioIndex;
}
@end

@implementation QHVCEditAddAudioView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    _audiosArray = @[@[@"edit_audio_none",@"",@""],@[@"edit_audio_fresh",@"Forever",@"153000"],@[@"edit_audio_recall",@"Disco",@"181000"]];
    [_collectionView registerNib:[UINib nibWithNibName:audioCellIdentifier bundle:nil] forCellWithReuseIdentifier:audioCellIdentifier];
    _originSlider.value = [QHVCEditPrefs sharedPrefs].originAudioVolume;
    _audioSlider.value = [QHVCEditPrefs sharedPrefs].musicAudioVolume;
}

- (IBAction)originAction:(UISlider *)sender
{
    [QHVCEditPrefs sharedPrefs].originAudioVolume = sender.value;
}

- (IBAction)audioAction:(UISlider *)sender
{
    [QHVCEditPrefs sharedPrefs].musicAudioVolume = sender.value;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _audiosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCEditAddAudioCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:audioCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_audiosArray[indexPath.row] isSelected:indexPath.row == _audioIndex];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 60);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_audioIndex == indexPath.row) {
        return;
    }
    _audioIndex = indexPath.row;
    self.audioItem.audiofile = _audiosArray[_audioIndex][1];
    self.audioItem.audioDuration = [_audiosArray[_audioIndex][2] doubleValue];
    self.audioItem.volume = (indexPath.row == 0)?_originSlider.value:_audioSlider.value;
    [_collectionView reloadData];
    if (_audioSelectBlock) {
        _audioSelectBlock(self.audioItem);
    }
}

@end
