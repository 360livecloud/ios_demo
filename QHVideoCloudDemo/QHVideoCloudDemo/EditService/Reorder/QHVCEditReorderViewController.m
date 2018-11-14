//
//  QHVCEditReorderViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/12/25.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCEditReorderViewController.h"
#import "QHVCEditPhotoManager.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditMainViewController.h"
#import "QHVCEditClipView.h"
#import "UIViewAdditions.h"
#import "QHVCEditPrefs.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

#define kThumbCount 8

typedef NS_ENUM(NSInteger, QHVCEditShiftDirection) {
    QHVCEditShiftDirectionLeft = 1,
    QHVCEditShiftDirectionRight,
};

@interface QHVCEditReorderViewController ()
{
    __weak IBOutlet UIView *_playerView;
    __weak IBOutlet UICollectionView *_orderCollectionView;
    __weak IBOutlet UIView *_clipContainerView;
    __weak IBOutlet UIButton *_leftShiftBtn;
    __weak IBOutlet UIButton *_rightShiftBtn;
    __weak IBOutlet NSLayoutConstraint *_orderViewBottom;
    QHVCEditClipView *_clipView;
    NSInteger _selectedIndex;
}
@property (nonatomic, weak) IBOutlet UICollectionView *clipCollectionView;
@property (nonatomic, weak) IBOutlet UIView *confirmView;
@property (nonatomic, assign) BOOL hasChange;
@property (nonatomic, assign) BOOL autoPlay;

@end

static NSString * const frameCellIdentifier = @"QHVCEditFrameCell";

@implementation QHVCEditReorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = @"排序";
    
    [_orderCollectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    [_clipCollectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    
    _selectedIndex = 0;
    _hasChange = NO;
    
    [[QHVCEditCommandManager manager] initCommandFactory];
    
    [self writeAssetsToSandbox:^{
        [self updateShiftBtnStatus:_selectedIndex];
        [[QHVCEditCommandManager manager] addFiles:self.resourceArray];
        
        [self createPlayer:_playerView];
        [self fetchThumbs];
        self.autoPlay = YES;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stop];
}

- (void)playerRenderFirstFrame
{
    if (self.autoPlay)
    {
        [self play];
        self.autoPlay = NO;
    }
}

- (void)writeAssetsToSandbox:(void(^)())complete
{
    [[QHVCEditPhotoManager manager] writeAssetsToSandbox:self.resourceArray complete:complete];
}

- (void)fetchThumbs
{
    if (_selectedIndex < _resourceArray.count && _resourceArray[_selectedIndex].thumbs.count > 0) {
        [self.clipCollectionView reloadData];
        [self updateClipView];
        return;
    }
    __weak typeof(self) weakSelf = self;
    QHVCEditPhotoItem *item = self.resourceArray[_selectedIndex];
    if (![QHVCToolUtils isNullString:item.photoFileIdentifier]) {
        [[QHVCEditCommandManager manager] fetchPhotoFileThumbs:item.photoFileIdentifier start:0 end:item.durationMs frameCnt:15 thumbSize:CGSizeMake(100, 200) completion:^(NSArray<QHVCEditThumbnailItem *> *thumbnails) {
            item.thumbs = [NSMutableArray arrayWithArray:thumbnails];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.clipCollectionView reloadData];
                [weakSelf updateClipView];
            });
        }];
    } else {
        [[QHVCEditCommandManager manager] fetchThumbs:item.filePath start:0 end:item.durationMs frameCnt:15 thumbSize:CGSizeMake(100, 200) completion:^(NSArray<QHVCEditThumbnailItem *> *thumbnails) {
            item.thumbs = [NSMutableArray arrayWithArray:thumbnails];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.clipCollectionView reloadData];
                [weakSelf updateClipView];
            });
        }];
    }
}

- (void)updateClipView
{
    if (!_clipView) {
        _clipView = [[QHVCEditClipView alloc]initWithFrame:CGRectMake(0, 10,kScreenWidth , _clipContainerView.height - 10)];
        [_clipContainerView addSubview:_clipView];
        __weak typeof(self) weakSelf = self;
        _clipView.changeCompletion = ^(BOOL isChange) {
            if (isChange) {
                if (!weakSelf.hasChange) {
                    [weakSelf updateConfirmViewStatus:YES];
                }
            }
        };
    }
    [_clipView updateUI:self.resourceArray[_selectedIndex]];
}

#pragma mark Action
- (void)nextAction:(UIButton *)btn
{
    QHVCEditMainViewController *vc = [[QHVCEditMainViewController alloc]initWithNibName:@"QHVCEditPlayerMainViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)backAction:(UIButton *)btn
{
    [self freePlayer];
    [[QHVCEditCommandManager manager] freeCommandFactory];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shiftBtnAction:(UIButton *)sender
{
    NSInteger beforeIndex = _selectedIndex;
    if (sender.tag == QHVCEditShiftDirectionLeft) {
        _selectedIndex--;
    }
    else if (sender.tag == QHVCEditShiftDirectionRight)
    {
        _selectedIndex++;
    }
    [self updateShiftBtnStatus:_selectedIndex];
    
    [_resourceArray exchangeObjectAtIndex:_selectedIndex withObjectAtIndex:beforeIndex];
    [_orderCollectionView reloadData];
    [self updateConfirmViewStatus:YES];
}

- (IBAction)cancel:(UIButton *)sender
{
    if (_hasChange) {
        [self resetResourceArray];
        [_orderCollectionView reloadData];
        [_clipCollectionView reloadData];
        [_clipView updateUI:self.resourceArray[_selectedIndex]];
    }
    [self updateConfirmViewStatus:NO];
    [self updateShiftBtnStatus:_selectedIndex];
}

- (IBAction)confirm:(UIButton *)sender
{
    if (_hasChange) {
        [[QHVCEditCommandManager manager] addFiles:self.resourceArray];
        [self resetPlayer:0];
        [self play];
        [self confirmResourceArray];
    }
    [self updateConfirmViewStatus:NO];
}

#pragma mark Private

- (void)updateConfirmViewStatus:(BOOL)isEnable
{
    _orderViewBottom.constant = isEnable?40:0;
    _confirmView.hidden =!isEnable;
    _hasChange = isEnable;
}

- (void)updateShiftBtnStatus:(NSInteger)currentIndex
{
    if (currentIndex == 0) {
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
    if (isEnabled) {
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
    if (isEnabled) {
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [_resourceArray sortUsingDescriptors:sortDescriptors];
    NSInteger i = 0;
    for (QHVCEditPhotoItem *item in _resourceArray) {
        item.startMs = item.lastStartMs;
        item.endMs = item.lastEndMs;
        i++;
    }
    _selectedIndex = 0;
}

- (void)confirmResourceArray
{
    NSInteger i = 0;
    for (QHVCEditPhotoItem *item in _resourceArray) {
        item.sortIndex = i;
        item.lastStartMs = item.startMs;
        item.lastEndMs = item.endMs;
        i++;
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _orderCollectionView) {
        return self.resourceArray.count;
    }
    else if (collectionView == _clipCollectionView)
    {
        return self.resourceArray[_selectedIndex].thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _orderCollectionView) {
        QHVCEditPhotoItem *item = self.resourceArray[indexPath.row];
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
        [cell updateCell:item.thumbImage highlightViewType:(_selectedIndex == indexPath.row)?QHVCEditFrameHighlightViewTypeSquare:QHVCEditFrameHighlightViewTypeNone];
        return cell;
    }
    else if (collectionView == _clipCollectionView)
    {
        NSArray<QHVCEditThumbnailItem *> *thumbs = self.resourceArray[_selectedIndex].thumbs;
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
        [cell updateCell:thumbs[indexPath.row].thumbnail highlightViewType:QHVCEditFrameHighlightViewTypeNone];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _orderCollectionView) {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _orderCollectionView) {
        if (_selectedIndex != indexPath.row) {
            _selectedIndex = indexPath.row;
            [_orderCollectionView reloadData];
            [self updateShiftBtnStatus:_selectedIndex];
            [self fetchThumbs];
        }
    }
}

- (void)playerComplete
{
    [self seekTo:0.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
