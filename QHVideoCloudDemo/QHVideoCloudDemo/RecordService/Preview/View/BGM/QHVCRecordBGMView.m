//
//  QHVCRecordBGMView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/11/28.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordBGMView.h"
#import "QHVCRecordBGMCell.h"
#import <QHVCRecordKit/QHVCRecordKit.h>

@interface QHVCRecordBGMView()
{
    IBOutlet UICollectionView *_collectionView;
    NSMutableArray<NSDictionary *> *_BGMArray;
    NSMutableDictionary *_currentBGMItem;
    
    NSInteger _selectedIndex;
    
    IBOutlet UISwitch *_loopSwitch;
    IBOutlet UISlider *_startSlider;
    IBOutlet UILabel *_startLabel;
    IBOutlet UISlider *_endSlider;
    IBOutlet UILabel *_endLabel;
    
    IBOutlet UISlider *_volumeSlider;
    IBOutlet UILabel *_volumeLabel;
}
@end

static NSString *BGMCellIdenitifer = @"QHVCRecordBGMCell";

@implementation QHVCRecordBGMView

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
    [_collectionView registerNib:[UINib nibWithNibName:BGMCellIdenitifer bundle:nil] forCellWithReuseIdentifier:BGMCellIdenitifer];
    
    _selectedIndex = -1;
    _BGMArray = [NSMutableArray arrayWithObjects:@{@"name":@"Disco",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"Disco"],@"duration":[self getDuration:@"Disco"],@"volume":@"100"},@{@"name":@"Forever",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"Forever"],@"duration":[self getDuration:@"Forever"],@"volume":@"100"},@{@"name":@"P",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"P"],@"duration":[self getDuration:@"P"],@"volume":@"100"},@{@"name":@"R",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"R"],@"duration":[self getDuration:@"R"],@"volume":@"100"},@{@"name":@"N",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"N"],@"duration":[self getDuration:@"N"],@"volume":@"100"},@{@"name":@"H",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"H"],@"duration":[self getDuration:@"H"],@"volume":@"100"},@{@"name":@"A",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"A"],@"duration":[self getDuration:@"A"],@"volume":@"100"},@{@"name":@"B",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"B"],@"duration":[self getDuration:@"B"],@"volume":@"100"},@{@"name":@"C",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"C"],@"duration":[self getDuration:@"C"],@"volume":@"100"},@{@"name":@"D",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"D"],@"duration":[self getDuration:@"D"],@"volume":@"100"},@{@"name":@"E",@"loop":@"1",@"start":@"0",@"end":[self getDuration:@"E"],@"duration":[self getDuration:@"E"],@"volume":@"100"},nil];
}

- (NSString *)getDuration:(NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    if (!filePath) {
        filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    }
    QHVCRecordFileInfo *info = [QHVCRecord fetchFileInfo:filePath];
    NSLog(@"audioDurationMS %@",@(info.audioDuration));
    return @(info.audioDuration).stringValue;
}

#pragma mark Action
- (IBAction)sliderAction:(UISlider *)sender
{
    NSString *value = [NSString stringWithFormat:@"%.0f",sender.value];
    if (sender.tag == 0) {
        _startLabel.text = value;
        [_currentBGMItem setObject:_startLabel.text forKey:@"start"];
        if (self.cutMusic) {
            self.cutMusic(value.intValue, -1);
        }
    }
    else if (sender.tag == 1)
    {
        _endLabel.text = value;
        [_currentBGMItem setObject:_endLabel.text forKey:@"end"];
        if (self.cutMusic) {
            self.cutMusic(-1, value.intValue);
        }
    }
    else if (sender.tag == 2)
    {
        _volumeLabel.text = value;
        [_currentBGMItem setObject:_volumeLabel.text forKey:@"volume"];
        if (self.volumeMusic) {
            self.volumeMusic(value.intValue);
        }
    }
}

- (IBAction)switchAction:(UISwitch *)sender
{
    [_currentBGMItem setObject:@(sender.on).stringValue forKey:@"loop"];
    if (self.loopMusic) {
        self.loopMusic(sender.on);
    }
}

- (IBAction)submitAction:(UIButton *)sender
{
    if (self.confirmMusic) {
        self.confirmMusic(_currentBGMItem);
    }
    self.hidden = YES;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _BGMArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCRecordBGMCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:BGMCellIdenitifer forIndexPath:indexPath];
    NSDictionary *item = _BGMArray[indexPath.row];
    [cell updateCell:item[@"name"] isHighlight:(_selectedIndex == indexPath.row)];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 30);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex == indexPath.row) {
        return;
    }
    NSDictionary *item = _BGMArray[indexPath.row];
    [self updateMusicInfo:item];
    
    _selectedIndex = indexPath.row;
    _currentBGMItem = [NSMutableDictionary dictionaryWithDictionary:item];
    
    [_collectionView reloadData];
}

- (void)updateMusicInfo:(NSDictionary *)info
{
    _loopSwitch.on = [info[@"loop"] intValue];
    
    _startSlider.maximumValue = [info[@"end"] intValue];
    _startLabel.text = info[@"start"];
    _startSlider.value = 0;
    
    _endSlider.maximumValue = [info[@"end"] intValue];
    _endLabel.text = info[@"end"];
    _endSlider.value = _endSlider.maximumValue;
    
    _volumeLabel.text = info[@"volume"];
    
    _loopSwitch.enabled = YES;
    _startSlider.enabled = YES;
    _endSlider.enabled = YES;
    _volumeSlider.enabled = YES;
    
    if (self.playMusic) {
        self.playMusic(info);
    }
}

@end
