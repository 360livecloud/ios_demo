//
//  QHVCEditFrameView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditFrameView.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"

#define kFrameCnt 4
#define kCellWidth 43.0
#define kCellHeight 43.0
#define kTimer 0.5

@interface QHVCEditFrameView()
{
    __weak IBOutlet UIButton *_playBtn;
    __weak IBOutlet UIButton *_editBtn;
    __weak IBOutlet UIButton *_addBtn;
    __weak IBOutlet UIButton *_discardBtn;
    __weak IBOutlet UILabel *_nowLabel;
    __weak IBOutlet UILabel *_endLabel;
    __weak IBOutlet UIActivityIndicatorView *_loading;
    __weak IBOutlet UICollectionView *_collectionView;
    QHVCEditFrameStatus _viewType;
    NSTimer *_timer;
    NSTimeInterval _currentStartMs;
    BOOL _isDrag;
    CGFloat _baseContentOffset;
}

@property (nonatomic, strong) NSArray<NSDictionary *> *filesArray;
@property (nonatomic, strong) NSMutableArray<QHVCEditThumbnailItem *> *framesArray;

@end

static NSString * const frameCellIdentifier = @"QHVCEditFrameCell";

@implementation QHVCEditFrameView

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
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 300);

    _framesArray = [NSMutableArray array];
    _viewType = QHVCEditFrameStatusAdd;
    _currentStartMs = 0;
    _isDrag = NO;
    _baseContentOffset = 0.0;
    
    self.filesArray = [[QHVCEditCommandManager manager] fetchFiles];
    if (self.filesArray.count > 0) {
        [self fetchThumbs:0];
    }
}

#pragma mark Public

- (NSTimeInterval)fetchCurrentTimeStampMs
{
    return _currentStartMs;
}

- (void)setUIStatus:(QHVCEditFrameStatus)status
{
    _endLabel.text = [QHVCEditPrefs timeFormatMs:self.duration];
    if (status == QHVCEditFrameStatusAdd) {
        _editBtn.hidden = YES;
        _discardBtn.hidden = YES;
        [_addBtn setImage:[UIImage imageNamed:@"edit_add"] forState:UIControlStateNormal];
    }
    else if (status == QHVCEditFrameStatusDone)
    {
        _editBtn.hidden = NO;
        _discardBtn.hidden = NO;
        [_addBtn setImage:[UIImage imageNamed:@"edit_done"] forState:UIControlStateNormal];
    }
    _viewType = status;
}

- (void)fetchThumbs:(NSInteger)index
{
    if (index >= self.filesArray.count) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [_loading startAnimating];
    _loading.hidden = NO;
    
    static NSInteger cnt = 0;
    QHVCEditCommandAddFileSegment *item = self.filesArray[index][@"object"];
    NSTimeInterval offsetS = ceil(item.endTimestampMs - item.startTimestampMs)/1000;
    [[QHVCEditCommandManager manager] fetchThumbs:item.filePath start:item.startTimestampMs end:item.endTimestampMs frameCnt:offsetS*kFrameCnt thumbSize:CGSizeMake(100, 200) completion:^(NSArray<QHVCEditThumbnailItem *> *thumbnails) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cnt++;
            [weakSelf.framesArray addObjectsFromArray:thumbnails];
            [weakSelf updateUI];
            [self fetchThumbs:cnt];
        });
    }];
}

- (void)updateUI
{
    [_loading stopAnimating];
    _loading.hidden = YES;
    
    [_collectionView reloadData];
}

- (IBAction)addAction:(UIButton *)sender
{
    [self stopAutoPlay];
    if (_viewType == QHVCEditFrameStatusAdd) {
        [_timeStamp addObject:[NSMutableArray arrayWithObject:@(_currentStartMs)]];
        if (self.addCompletion) {
            self.addCompletion(_currentStartMs);
        }
    }
    else if (_viewType == QHVCEditFrameStatusDone)
    {
        for (NSMutableArray *item in _timeStamp) {
            if (item.count == 1) {
                [item addObject:@(_currentStartMs)];
                break;
            }
        }
        if (self.doneCompletion) {
            self.doneCompletion(_currentStartMs);
        }
    }
}

- (IBAction)playAction:(UIButton *)sender
{
    _isDrag = NO;
    if (!_timer) {
        if (_collectionView.contentOffset.x >= self.framesArray.count*kCellWidth) {
            _collectionView.contentOffset = CGPointMake(0, 0);
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTimer target:self selector:@selector(updateCollectionViewOffset) userInfo:nil repeats:YES];
        [_playBtn setImage:[UIImage imageNamed:@"edit_pause"] forState:UIControlStateNormal];
    }
    else
    {
        [self stopAutoPlay];
    }
}

- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        _baseContentOffset = _collectionView.contentOffset.x;
    }
}

- (void)stopAutoPlay
{
    [self stopTimer];
    [_playBtn setImage:[UIImage imageNamed:@"edit_play"] forState:UIControlStateNormal];
}

- (void)updateCollectionViewOffset
{
    NSTimeInterval nowMs = _currentStartMs + kTimer * 1000/kFrameCnt;
    if (nowMs > self.duration) {
        nowMs = self.duration;
        [self stopAutoPlay];
    }
    CGFloat x = nowMs * kFrameCnt *kCellWidth/1000.0;
    [_collectionView setContentOffset:CGPointMake(x, 0) animated:YES];
    _currentStartMs = nowMs;
    _nowLabel.text = [QHVCEditPrefs timeFormatMs:_currentStartMs];

//    [_collectionView reloadData];
}

- (IBAction)editAction:(UIButton *)sender
{
    [self stopAutoPlay];
    if (self.editCompletion) {
        self.editCompletion();
    }
}

- (IBAction)discardAction:(UIButton *)sender
{
    [self stopAutoPlay];
    [self removeUncompleteTimestamp];
    if (self.discardCompletion) {
        self.discardCompletion();
    }
}

- (void)removeUncompleteTimestamp
{
    for (NSMutableArray *item in _timeStamp) {
        if (item.count == 1) {
            [_timeStamp removeObject:item];
            break;
        }
    }
}

- (BOOL)isFrameHighlight:(NSInteger)index
{
    NSTimeInterval offsetMs = index*1000.0/kFrameCnt;
    for (NSMutableArray *item in _timeStamp) {
        if (item.count == 2) {
            if (offsetMs >= [item[0] doubleValue] && offsetMs <= [item[1] doubleValue]) {
                return YES;
            }
        }
        else if (item.count == 1)
        {
            if (offsetMs >= [item[0] doubleValue] && offsetMs <= _currentStartMs)
            {
                return YES;
            }
        }
    }
    return NO;
}
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _framesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_framesArray[indexPath.row].thumbnail highlightViewType:[self isFrameHighlight:indexPath.row]?QHVCEditFrameHighlightViewTypeMask:QHVCEditFrameHighlightViewTypeNone];
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
    if (!_isDrag) {
        return;
    }
    [self stopAutoPlay];
    
    CGFloat x = MAX(scrollView.contentOffset.x, 0) ;
    NSTimeInterval offsetMs = x*1000.0/(kFrameCnt*kCellWidth);
    _currentStartMs = offsetMs;
    _baseContentOffset = x;
    _nowLabel.text = [QHVCEditPrefs timeFormatMs:MAX(_currentStartMs, 0)];
//    [_collectionView reloadData];
}

@end
