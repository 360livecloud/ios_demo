//
//  QHVCEditCutView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditCutView.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"

#define kFrameCnt 4
#define kCellWidth 43.0
#define kCellHeight 43.0

@interface QHVCEditCutView()
{
    __weak IBOutlet UIButton *_playBtn;
    __weak IBOutlet UILabel *_nowLabel;
    __weak IBOutlet UILabel *_endLabel;
    __weak IBOutlet UICollectionView *_collectionView;
    NSTimer *_timer;
    NSTimeInterval _currentStartMs;
    BOOL _isDrag;
}
@property (nonatomic, strong) NSArray<NSDictionary *> *filesArray;
@property (nonatomic, strong) NSMutableArray<QHVCEditThumbnailItem *> *framesArray;

@end

static NSString * const frameCellIdentifier = @"QHVCEditFrameCell";

@implementation QHVCEditCutView

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
    
    [_collectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    _nowLabel.text = @"00:00";
    
    _framesArray = [NSMutableArray array];
    _currentStartMs = 0;
    _isDrag = NO;
    
    [self fetchThumbs];
}

#pragma mark Public

- (void)freshView
{
    _endLabel.text = [QHVCEditPrefs timeFormatMs:self.duration];
}

- (NSTimeInterval)fetchCurrentTimeStampMs
{
    return _currentStartMs;
}

- (void)fetchThumbs
{
    self.filesArray = [[QHVCEditCommandManager manager] fetchFiles];
    if (self.filesArray.count > 0) {
        __weak typeof(self) weakSelf = self;
        QHVCEditCommandAddFileSegment *item = self.filesArray[0][@"object"];
        NSTimeInterval offsetS = ceil(item.endTimestampMs - item.startTimestampMs);
        [[QHVCEditCommandManager manager] fetchThumbs:item.filePath start:item.startTimestampMs end:item.endTimestampMs frameCnt:offsetS*kFrameCnt thumbSize:CGSizeMake(100, 200) completion:^(NSArray<QHVCEditThumbnailItem *> *thumbnails) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.framesArray = [NSMutableArray arrayWithArray:thumbnails];
                [weakSelf updateUI];
            });
        }];
    }
}

- (void)updateUI
{
    [_collectionView reloadData];
}

- (IBAction)cutAction:(UIButton *)sender
{
    if (self.cutCompletion) {
        self.cutCompletion();
    }
}

- (IBAction)playAction:(UIButton *)sender
{
    _isDrag = NO;
    if (!_timer) {
        if (_collectionView.contentOffset.x >= self.framesArray.count*kCellWidth) {
            _collectionView.contentOffset = CGPointMake(0, 0);
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateCollectionViewOffset) userInfo:nil repeats:YES];
        [_playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
    }
    else
    {
        [self stopAutoPlay];
    }
}

- (IBAction)cancelAction:(UIButton *)sender
{
    if (self.cancelCompletion) {
        self.cancelCompletion();
    }
}

- (IBAction)doneAction:(UIButton *)sender
{
    if (self.doneCompletion) {
        self.doneCompletion();
    }
}

- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)stopAutoPlay
{
    [self stopTimer];
    [_playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
}

- (void)updateCollectionViewOffset
{
    CGFloat x = _collectionView.contentOffset.x + kCellWidth/kFrameCnt;
    if (x > self.framesArray.count*kCellWidth) {
        [self stopAutoPlay];
        return;
    }
    [_collectionView setContentOffset:CGPointMake(x, 0) animated:YES];
    if (x >= 0) {
        _currentStartMs = x/(kCellWidth*kFrameCnt);
        _nowLabel.text = [QHVCEditPrefs timeFormatMs:x/(kCellWidth*kFrameCnt)];
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _framesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_framesArray[indexPath.row].thumbnail highlightViewType:QHVCEditFrameHighlightViewTypeNone];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCellWidth, kCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isDrag = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollView %@",[NSValue valueWithCGPoint:scrollView.contentOffset]);
    if (!_isDrag) {
        return;
    }
    [self stopAutoPlay];
    
    CGFloat x = MAX(scrollView.contentOffset.x, 0) ;
    _currentStartMs = x/(kCellWidth*kFrameCnt);
    NSLog(@"scrollViewDidScroll %@",@(_currentStartMs));
    _nowLabel.text = [QHVCEditPrefs timeFormatMs:x/(kCellWidth*kFrameCnt)];
}
@end
