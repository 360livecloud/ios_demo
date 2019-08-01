//
//  QHVCEditReorderViewController.m
//  QHVideoCloudToolSet
//
//  Created by yinchaoyu on 2018/6/26.
//  Copyright © 2017年 qihoo 360. All rights reserved.
//

#import "QHVCEditReorderVC.h"
#import "QHVCPhotoManager.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditTrackClipView.h"
#import "UIViewAdditions.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMainEditVC.h"
#import "QHVCEditMediaEditorConfig.h"

#define kThumbCount 8
#define kThumbTotalCount 15

typedef NS_ENUM(NSInteger, QHVCEditShiftDirection)
{
    QHVCEditShiftDirectionLeft = 1,
    QHVCEditShiftDirectionRight,
};

@interface QHVCEditReorderVC ()
{
    __weak IBOutlet UIView *_playerView;
    __weak IBOutlet UICollectionView *_orderCollectionView;
    __weak IBOutlet UIView *_clipContainerView;
    __weak IBOutlet UIButton *_leftShiftBtn;
    __weak IBOutlet UIButton *_rightShiftBtn;
}

@property (nonatomic, weak) IBOutlet UIView* previewView;
@property (nonatomic, weak) IBOutlet UICollectionView *clipCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewWidthConstraint;

@property (nonatomic, retain) QHVCEditTrackClipView* clipView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL hasChange;
@property (nonatomic, assign) BOOL readyToPlay;
@property (nonatomic, strong) QHVCEditThumbnail* thumbnail;
@property (nonatomic, strong) NSMutableArray<QHVCPhotoItem *>* resourceArray;
@property (nonatomic, strong) NSMutableArray<QHVCEditTrackClipItem *>* clipsArray;
@property (nonatomic, assign) BOOL isPlayingBeforeInterrupt;

@end

static NSString * const frameCellIdentifier = @"QHVCEditFrameCell";

@implementation QHVCEditReorderVC

#pragma mark - Life Circle Methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithItems:(NSArray<QHVCPhotoItem *> *)items
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    self.resourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.resourceArray addObjectsFromArray:items];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_orderCollectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    [_clipCollectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupt:) name:AVAudioSessionInterruptionNotification object:nil];
    
    //默认参数
    self.titleLabel.text = @"排序";
    _selectedIndex = 0;
    _hasChange = NO;
    [self.playerViewTopConstraint setConstant:[self topBarHeight]];
}

- (void)audioSessionInterrupt:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    AVAudioSessionInterruptionType type = [[info objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan)
    {
        self.isPlayingBeforeInterrupt = [self isPlaying];
        [self stop];
    }
    else
    {
        if (self.isPlayingBeforeInterrupt)
        {
            [self play];
        }
    }
}

- (void)prepareSubviews
{
    [super prepareSubviews];
    
    //播放器preview高度适配
    CGFloat maxHeight = MIN(kScreenHeight - [self topBarHeight] - 200, CGRectGetHeight(_playerView.frame));
    CGFloat maxWidth = kScreenWidth;
    CGFloat height = 0;
    CGFloat width = 0;
    CGFloat outputWidth = [[QHVCEditMediaEditorConfig sharedInstance] outputSize].width;
    CGFloat outputHeight = [[QHVCEditMediaEditorConfig sharedInstance] outputSize].height;
    if (outputWidth > outputHeight)
    {
        width = maxWidth;
        height = width * outputHeight / outputWidth;
    }
    else
    {
        height = maxHeight;
        width = height * outputWidth / outputHeight;
    }
    [self.previewWidthConstraint setConstant:width];
    [self.previewHeightConstraint setConstant:height];
    
    if (![self isPlaying])
    {
        [self play];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self freeEditor];
    [self startMediaEditorSession];
    if (![self isPlaying])
    {
        [self resetPlayer:0];
        [self play];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Media Editor Methods

- (void)freeEditor
{
    [self freePlayer];
    [[QHVCEditMediaEditorConfig sharedInstance] cleanParams];
    [[QHVCEditMediaEditor sharedInstance] freeTimeline];
    [[QHVCEditMediaEditor sharedInstance] cancelThumbnailRequest];
    [[QHVCEditMediaEditor sharedInstance] freeThumbnailBuilder];
}

- (void)startMediaEditorSession
{
    [self createTimelineAndAppendClips];
    self.clipsArray = [[QHVCEditMediaEditor sharedInstance] getMainTrackClips];
    if ([self.clipsArray count] > 0)
    {
        [self updateClipView];
        [self fetchThumbs];
        [self updateShiftBtnStatus:self.selectedIndex];
        
        //初始化播放器
        [self createPlayerWithPreview:self.previewView];
        [self play];
    }
}

- (void)createTimelineAndAppendClips
{
    [[QHVCEditMediaEditor sharedInstance] createTimeline];
    [[QHVCEditMediaEditor sharedInstance] createMainTrack];
    
    [self.resourceArray enumerateObjectsUsingBlock:^(QHVCPhotoItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if (obj.assetPlayable)
        {
            QHVCEditTrackClipItem* clipItem = [[QHVCEditTrackClipItem alloc] initWithPhotoItem:obj];
            clipItem.clipIndex = idx;
            clipItem.startMs = 0;
            clipItem.endMs = clipItem.durationMs;
            clipItem.thumbnail = obj.thumbImage;
            [[QHVCEditMediaEditor sharedInstance] mainTrackAppendClip:clipItem];
        }
    }];
}

#pragma mark - Player Methods

- (void)playerComplete
{
    [self seekTo:0.0];
    [self play];
}

- (void)playerRenderedFirstFrame
{
    self.readyToPlay = YES;
}

#pragma mark - Thumbnail Methods

- (void)fetchThumbs
{
    if (_selectedIndex < self.clipsArray.count && self.clipsArray[_selectedIndex].thumbs.count > 0) {
        [self.clipCollectionView reloadData];
        [self updateClipView];
        return;
    }
    
    __block QHVCEditTrackClipItem *clip = self.clipsArray[_selectedIndex];
    if (![[QHVCEditMediaEditorConfig sharedInstance] usePhotoIdentifier] || !clip.fileIdentifier)
    {
        [[QHVCEditMediaEditor sharedInstance] requestThumbsFromFilePath:clip.filePath
                                                                  start:0
                                                                    end:clip.durationMs
                                                               frameCnt:kThumbTotalCount
                                                              thumbSize:CGSizeMake(200, 400) thumbCallback:^(QHVCEditThumbnailItem *thumbnail)
         {
             [clip.thumbs addObject:thumbnail];
             WEAK_SELF
             SAFE_BLOCK_IN_MAIN_QUEUE(^{
                 STRONG_SELF
                 [self.clipCollectionView reloadData];
                 [self updateClipView];
             });
         }];
    }
    else
    {
        [[QHVCEditMediaEditor sharedInstance] requestThumbsFromFileIdentifier:clip.fileIdentifier
                                                                        start:0
                                                                          end:clip.durationMs
                                                                     frameCnt:kThumbTotalCount
                                                                    thumbSize:CGSizeMake(200, 400)
                                                                thumbCallback:^(QHVCEditThumbnailItem *thumbnail)
        {
            [clip.thumbs addObject:thumbnail];
            WEAK_SELF
            SAFE_BLOCK_IN_MAIN_QUEUE(^{
                STRONG_SELF
                [self.clipCollectionView reloadData];
                [self updateClipView];
            });
        }];
    }
}

#pragma mark - Action

- (void)nextAction:(UIButton *)btn
{
    [self stop];
    [self confirmResourceArray];
    [self.clipsArray enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         [obj.clip setFileStartTime:obj.startMs];
         [obj.clip setFileEndTime:obj.endMs];
        [[QHVCEditMediaEditor sharedInstance] mainTrackUpdateClip:obj];
    }];
    
    [self resetPlayer:0];
    QHVCEditMainEditVC* vc = [[QHVCEditMainEditVC alloc] initWithNibName:@"QHVCEditMainEditVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)backAction:(UIButton *)btn
{
    [self freeEditor];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shiftBtnAction:(UIButton *)sender
{
    NSInteger beforeIndex = _selectedIndex;
    if (sender.tag == QHVCEditShiftDirectionLeft)
    {
        _selectedIndex--;
    }
    else if (sender.tag == QHVCEditShiftDirectionRight)
    {
        _selectedIndex++;
    }
    
    [self updateShiftBtnStatus:_selectedIndex];
    [[QHVCEditMediaEditor sharedInstance] mainTrackMoveClip:_selectedIndex toIndex:beforeIndex];
    [self exchangePhotosAndClips:_selectedIndex exchangeTo:beforeIndex];
    [_orderCollectionView reloadData];
    [self updateClipView];
}

- (void)confirmResourceArray
{
    NSInteger i = 0;
    for (QHVCPhotoItem *item in _resourceArray)
    {
        item.photoIndex = i;
        i++;
    }
    
    i = 0;
    for (QHVCEditTrackClipItem *item in _clipsArray)
    {
        item.clipIndex = i;
        i++;
    }
}

#pragma mark - Reorder

- (void)updateClipView
{
    if (!_clipView)
    {
        _clipView = [[QHVCEditTrackClipView alloc]initWithFrame:CGRectMake(0, 10, kScreenWidth , _clipContainerView.height - 10)];
        [_clipContainerView addSubview:_clipView];
    }
    
    if ([self.clipsArray count] > _selectedIndex)
    {
        [_clipView updateUI:self.clipsArray[_selectedIndex]];
    }
}

- (void)updateShiftBtnStatus:(NSInteger)currentIndex
{
    if (currentIndex == 0)
    {
        [self updateLeftShiftBtnStatus:NO];
        [self updateRightShiftBtnStatus:_resourceArray.count > 1];
    }
    else if(currentIndex == _resourceArray.count - 1)
    {
        [self updateLeftShiftBtnStatus:_resourceArray.count > 1];
        [self updateRightShiftBtnStatus:NO];
    }
    else
    {
        [self updateLeftShiftBtnStatus:YES];
        [self updateRightShiftBtnStatus:YES];
    }
}

- (void)updateLeftShiftBtnStatus:(BOOL)isEnabled
{
    if (isEnabled)
    {
        [_leftShiftBtn setImage:[UIImage imageNamed:@"edit_order_left_enable"] forState:UIControlStateNormal];
    }
    else
    {
        [_leftShiftBtn setImage:[UIImage imageNamed:@"edit_order_left"] forState:UIControlStateNormal];
    }
    _leftShiftBtn.enabled = isEnabled;
}

- (void)updateRightShiftBtnStatus:(BOOL)isEnabled
{
    if (isEnabled)
    {
        [_rightShiftBtn setImage:[UIImage imageNamed:@"edit_order_right_enable"] forState:UIControlStateNormal];
    }
    else
    {
        [_rightShiftBtn setImage:[UIImage imageNamed:@"edit_order_right"] forState:UIControlStateNormal];
    }
    _rightShiftBtn.enabled = isEnabled;
}

- (void)resetResourceArray
{
    NSSortDescriptor *sortDescriptorPhoto = [[NSSortDescriptor alloc] initWithKey:@"photoIndex" ascending:YES];
    NSSortDescriptor *sortDescriptorClip = [[NSSortDescriptor alloc] initWithKey:@"clipIndex" ascending:YES];
    NSArray *sortDescriptorsPhoto = [[NSArray alloc] initWithObjects:sortDescriptorPhoto, nil];
    NSArray *sortDescriptorsClip = [[NSArray alloc] initWithObjects:sortDescriptorClip, nil];
    [_resourceArray sortUsingDescriptors:sortDescriptorsPhoto];
    [_clipsArray sortUsingDescriptors:sortDescriptorsClip];
    [self updateClipView];
    _selectedIndex = 0;
    NSArray *clipsArray = [[NSArray alloc] initWithArray:_clipsArray];
    [clipsArray enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[QHVCEditMediaEditor sharedInstance] mainTrackDeleteClip:obj];
    }];
    [clipsArray enumerateObjectsUsingBlock:^(QHVCEditTrackClipItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[QHVCEditMediaEditor sharedInstance] mainTrackAppendClip:obj];
    }];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _orderCollectionView)
    {
        return self.resourceArray.count;
    }
    else if (collectionView == _clipCollectionView && self.clipsArray.count > _selectedIndex)
    {
        return self.clipsArray[_selectedIndex].thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _orderCollectionView)
    {
        QHVCPhotoItem *item = self.resourceArray[indexPath.row];
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
        [cell updateCell:item.thumbImage highlightViewType:(_selectedIndex == indexPath.row)?QHVCEditFrameHighlightViewTypeSquare:QHVCEditFrameHighlightViewTypeNone];
        return cell;
    }
    else if (collectionView == _clipCollectionView)
    {
        NSArray<QHVCEditThumbnailItem *> *thumbs = self.clipsArray[_selectedIndex].thumbs;
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
        [cell updateCell:thumbs[indexPath.row].thumbnail highlightViewType:QHVCEditFrameHighlightViewTypeNone];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _orderCollectionView)
    {
        return CGSizeMake(94, 60);
    }
    else
    {
        CGFloat w = kScreenWidth/kThumbCount;
        CGFloat h = w;
        return CGSizeMake(w,h);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _orderCollectionView)
    {
        if (_selectedIndex != indexPath.row)
        {
            _selectedIndex = indexPath.row;
            [_orderCollectionView reloadData];
            [self updateShiftBtnStatus:_selectedIndex];
            [self fetchThumbs];
        }
    }
}

- (void)exchangePhotosAndClips:(NSInteger)index1 exchangeTo:(NSInteger)index2
{
    if (index1 == index2)
    {
        return;
    }
    
    [_resourceArray exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [_clipsArray exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

@end
