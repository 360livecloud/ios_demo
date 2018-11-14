//
//  QHVCEditOverlayFreedomItemView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayToolsView.h"
#import "UIView+Toast.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMainFunctionCell.h"
#import "QHVCEditMatrixItem.h"
#import "QHVCEditPhotoItem.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditPhotoManager.h"
#import "QHVCEditOverlayAlphaMovView.h"
#import "QHVCEditOverlaySpeedView.h"
#import "QHVCEditOverlayVolumeView.h"
#import "QHVCEditOverlayChromakeyView.h"
#import "QHVCEditAudioItem.h"
#import "QHVCEditOverlayItemPreview.h"
#import "QHVCEditOverlayBlendView.h"

static NSString* freedomItemCellIdentifier = @"QHVCEditFreedomItemCell";

@interface QHVCEditOverlayToolsView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *freedomItemCollection;
@property (nonatomic, retain) NSArray* freedomItemArray;
@property (nonatomic, retain) QHVCEditOverlayAlphaMovView* alphaMovView;
@property (nonatomic, retain) QHVCEditOverlaySpeedView* speedView;
@property (nonatomic, retain) QHVCEditOverlayVolumeView* volumeView;
@property (nonatomic, retain) QHVCEditOverlayChromakeyView* chromakeyView;
@property (nonatomic, retain) QHVCEditOverlayBlendView* blendView;

@end

@implementation QHVCEditOverlayToolsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.freedomItemCollection registerNib:[UINib nibWithNibName:@"QHVCEditMainFunctionCell" bundle:nil] forCellWithReuseIdentifier:freedomItemCellIdentifier];
    [self.freedomItemCollection setDataSource:self];
    [self.freedomItemCollection setDelegate:self];
    self.freedomItemArray = @[@[@"透明文件", @"edit_overlay_alpha_file"],
                              @[@"相册", @"edit_overlay_photo"],
                              @[@"旋转", @"edit_overlay_rotate"],
                              @[@"上下镜像", @"edit_overlay_flipy"],
                              @[@"左右镜像", @"edit_overlay_flipx"],
                              @[@"自由裁剪", @"edit_overlay_cut"],
                              @[@"变速", @"edit_overlay_speed"],
                              @[@"音量", @"edit_overlay_volume"],
                              @[@"置顶", @"edit_overlay_top"],
                              @[@"置底", @"edit_overlay_bottom"],
                              @[@"删除", @"edit_overlay_delete"],
                              @[@"抠图", @"edit_overlay_chromakey"],
                              @[@"淡入淡出", @"edit_overlay_fade"],
                              @[@"滑入滑出", @"edit_overlay_fade"],
                              @[@"弹入弹出", @"edit_overlay_fade"],
                              @[@"旋入旋出", @"edit_overlay_fade"],
                              @[@"混合模式", @"edit_overlay_blend"]];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.freedomItemArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditMainFunctionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:freedomItemCellIdentifier forIndexPath:indexPath];
    NSArray* item = self.freedomItemArray[indexPath.row];
    if (item.count > 1)
    {
        [cell updateCell:item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            //透明mov
            [self clickedAlpahMovItem];
            break;
        }
        case 1:
        {
            //相册
            [self clickedPhotoItem];
            break;
        }
        case 2:
        {
            //旋转
            [self clickedRotateItem];
            break;
        }
        case 3:
        {
            //上下镜像
            [self clickedFlipYItem];
            break;
        }
        case 4:
        {
            //左右镜像
            [self clickedFlipXItem];
            break;
        }
        case 5:
        {
            //自由裁剪
            [self clickedCropItem];
            break;
        }
        case 6:
        {
            //变速
            [self clickedSpeedItem];
            break;
        }
        case 7:
        {
            //音量
            [self clickedVolumeItem];
            break;
        }
        case 8:
        {
            //置顶
            [self clickedTopItem];
            break;
        }
        case 9:
        {
            //置底
            [self clickedBottomItem];
            break;
        }
        case 10:
        {
            //删除
            [self clickedDeleteItem];
            break;
        }
        case 11:
        {
            //抠图
            [self clickedChromaKeyItem];
            break;
        }
        case 12:
        {
            //淡入淡出
            [self clickedFadeInOutItem];
            break;
        }
        case 13:
        {
            //滑入滑出
            [self clickedMoveInOutItem];
            break;
        }
        case 14:
        {
            //弹入弹出
            [self clickedJumpInOutItem];
            break;
        }
        case 15:
        {
            //旋入旋出
            [self clickedRotateInOutItem];
            break;
        }
        case 16:
        {
            //混合模式
            [self clickedBlendItem];
            break;
        }
        default:
            break;
    }
}

- (void)clickedAlpahMovItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能替换透明mov"];
        return;
    }
    
    if (!self.alphaMovView)
    {
        self.alphaMovView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayAlphaMovView class] description] owner:self options:nil][0];
    }
    [self addSubview:self.alphaMovView];
    
    WEAK_SELF
    [self.alphaMovView setChangeAlphaMovAction:^(NSString *filePath)
    {
        STRONG_SELF
        QHVCEditPhotoItem* item = [[QHVCEditPhotoItem alloc] init];
        item.filePath = filePath;
        item.startMs = self.item.startTimestampMs;
        item.endMs = self.item.endTiemstampMs;
        [[QHVCEditPhotoManager manager] writeAssetsToSandbox:@[item] complete:^{
            [[QHVCEditCommandManager manager] updateOverlayFile:item overlayId:self.item.overlayCommandId];
            SAFE_BLOCK(self.resetPlayerAction);
        }];
    }];
}

- (void)clickedPhotoItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能替换文件"];
        return;
    }
    SAFE_BLOCK(self.showPhotoAlbumAction, self.item);
}

- (void)clickedRotateItem
{
    self.item.frameRadian += M_PI_2;
    if (self.item.frameRadian == 2*M_PI)
    {
        self.item.frameRadian = 0;
    }
    [[QHVCEditCommandManager manager] updateMatrix:self.item];
    SAFE_BLOCK(self.refreshPlayerAction);
}

- (void)clickedFlipYItem
{
    self.item.flipY = !self.item.flipY;
    [[QHVCEditCommandManager manager] updateMatrix:self.item];
    SAFE_BLOCK(self.refreshPlayerAction);
}

- (void)clickedFlipXItem
{
    self.item.flipX = !self.item.flipX;
    [[QHVCEditCommandManager manager] updateMatrix:self.item];
    SAFE_BLOCK(self.refreshPlayerAction);
}

- (void)clickedCropItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能裁剪"];
        return;
    }
    SAFE_BLOCK(self.cropAction, self.item);
}

- (void)clickedSpeedItem
{
    if (!self.speedView)
    {
        self.speedView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlaySpeedView class] description] owner:self options:nil][0];
    }
    [self addSubview:self.speedView];
    
    WEAK_SELF
    [self.speedView setChangeSpeedAction:^(CGFloat speed)
    {
        STRONG_SELF
        if (self.item.overlayCommandId == kMainTrackId)
        {
            [[QHVCEditCommandManager manager] adjustSpeed:speed];
        }
        else
        {
            [[QHVCEditCommandManager manager] updateOverlaySpeed:speed overlayId:self.item.overlayCommandId];
        }
        SAFE_BLOCK(self.resetPlayerAction);
    }];
}

- (void)clickedVolumeItem
{
    if (!self.volumeView)
    {
        self.volumeView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayVolumeView class] description] owner:self options:nil][0];
    }
    [self addSubview:self.volumeView];
    
    WEAK_SELF
    [self.volumeView setChangeVolumeAction:^(int volume)
    {
        STRONG_SELF
        if (self.item.overlayCommandId == kMainTrackId)
        {
            QHVCEditAudioItem* item = [[QHVCEditAudioItem alloc] init];
            item.volume = volume;
            [[QHVCEditCommandManager manager] addAudios:@[item]];
        }
        else
        {
            [[QHVCEditCommandManager manager] updateOverlayVolume:volume overlayId:self.item.overlayCommandId];
        }
        SAFE_BLOCK(self.refreshPlayerAction);
    }];
}

- (void)clickedTopItem
{
    SAFE_BLOCK(self.toTopAction, self.item);
}

- (void)clickedBottomItem
{
    SAFE_BLOCK(self.toBottomAction, self.item);
}

- (void)clickedDeleteItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能被删除"];
        return;
    }
    
    [(UIView *)self.item.preview removeFromSuperview];
    self.item.preview = nil;
    [[QHVCEditCommandManager manager] deleteMatrix:self.item];
    [[QHVCEditCommandManager manager] deleteOverlayFile:self.item.overlayCommandId];
    SAFE_BLOCK(self.resetPlayerAction);
}

- (void)clickedChromaKeyItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能抠图"];
        return;
    }
    
    if (!self.chromakeyView)
    {
        self.chromakeyView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayChromakeyView class] description] owner:self options:nil][0];
        
        WEAK_SELF
        [self.chromakeyView setChromakeyAction:^(int threshold, int extend)
         {
             STRONG_SELF
             [self.item.preview updateChromakey:threshold extend:extend];
         }];
        
        [self.chromakeyView setChromakeyStoppedAction:^{
            STRONG_SELF
            [self.item.preview hideColorPicker];
        }];
    }
    
    [self.item.preview showColorPicker];
    [self.item.preview updateChromakey:25 extend:0];
    [self addSubview:self.chromakeyView];
}

- (void)clickedFadeInOutItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能设置淡入淡出"];
        return;
    }
    
    [[QHVCEditCommandManager manager] addOverlayFadeInOut:self.item.overlayCommandId];
    SAFE_BLOCK(self.refreshPlayerAction);
}

- (void)clickedMoveInOutItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能设置滑入滑出"];
        return;
    }
    
    [[QHVCEditCommandManager manager] addOverlayMoveInOut:self.item.overlayCommandId];
}

- (void)clickedJumpInOutItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能设置弹入弹出"];
        return;
    }
    
    [[QHVCEditCommandManager manager] addOverlayJumpInOut:self.item.overlayCommandId];
}

- (void)clickedRotateInOutItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能设置旋入旋出"];
        return;
    }
    
    [[QHVCEditCommandManager manager] addOverlayRotateInOut:self.item.overlayCommandId];
}

- (void)clickedBlendItem
{
    if (self.item.overlayCommandId == kMainTrackId)
    {
        [self makeToast:@"主视频不能设置混合模式"];
        return;
    }
    
    if (!self.blendView)
    {
        self.blendView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayBlendView class] description] owner:self options:nil][0];
        WEAK_SELF
        [self.blendView setBlendAction:^(NSInteger modeIndex, CGFloat progress)
        {
            STRONG_SELF
            [[QHVCEditCommandManager manager] addOverlayBlendMode:self.item.overlayCommandId blendMode:modeIndex progres:progress];
            SAFE_BLOCK(self.refreshPlayerAction);
        }];
    }
    
    [self addSubview:self.blendView];
}

@end
