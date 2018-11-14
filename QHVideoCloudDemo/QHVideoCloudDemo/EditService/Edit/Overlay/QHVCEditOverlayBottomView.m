//
//  QHVCEditOverlayBottomView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayBottomView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditOverlayBgColorView.h"
#import "QHVCEditOverlayTemplateView.h"
#import "QHVCEditOverlayToolsView.h"
#import "QHVCEditMatrixItem.h"

@interface QHVCEditOverlayBottomView ()

@property (weak, nonatomic) IBOutlet UIButton *templateBtn;
@property (weak, nonatomic) IBOutlet UIButton *freedomBtn;
@property (weak, nonatomic) IBOutlet UIView *freedomContentView;
@property (weak, nonatomic) IBOutlet UIView *templateContentView;
@property (weak, nonatomic) IBOutlet UIView *overlayToolsContentView;
@property (weak, nonatomic) IBOutlet UIView *confirmView;


@property (nonatomic, strong) QHVCEditOverlayBgColorView* bgColorView;
@property (nonatomic, strong) QHVCEditOverlayTemplateView* templateView;
@property (nonatomic, strong) QHVCEditOverlayToolsView* overlayToolsView;
@property (nonatomic, retain) QHVCEditMatrixItem* cropItem;

@end

@implementation QHVCEditOverlayBottomView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self createFreedomView];
    [self createTemplateView];
    [self createOverlayToolsView];
    [self.freedomBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
    [self.freedomContentView setHidden:NO];
    [self.templateContentView setHidden:YES];
    [self.overlayToolsContentView setHidden:YES];
    [self.confirmView setHidden:YES];
}

- (void)createFreedomView
{
    self.bgColorView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayBgColorView class] description] owner:self options:nil][0];
    self.bgColorView.frame = CGRectMake(0, 0, CGRectGetWidth(self.freedomContentView.frame), CGRectGetHeight(self.freedomContentView.frame));
    
    WEAK_SELF
    [self.bgColorView setChangeColorAction:^(NSString *argbColor) {
        STRONG_SELF
        SAFE_BLOCK_IN_MAIN_QUEUE(self.changeColorAction, argbColor);
    }];
    [self.freedomContentView addSubview:self.bgColorView];
}

- (void)createTemplateView
{
    self.templateView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayTemplateView class] description] owner:self options:nil][0];
    self.templateView.frame = CGRectMake(0, 0, CGRectGetWidth(self.templateContentView.frame), CGRectGetHeight(self.templateContentView.frame));
    [self.templateContentView addSubview:self.templateView];
}

- (void)createOverlayToolsView
{
    self.overlayToolsView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditOverlayToolsView class] description] owner:self options:nil][0];
    self.overlayToolsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.overlayToolsContentView.frame), CGRectGetHeight(self.overlayToolsContentView.frame));
    [self.overlayToolsContentView addSubview:self.overlayToolsView];
    
    WEAK_SELF
    [self.overlayToolsView setResetPlayerAction:^{
        STRONG_SELF
        SAFE_BLOCK(self.resetPlayerAction);
    }];
    
    [self.overlayToolsView setRefreshPlayerAction:^{
        STRONG_SELF
        SAFE_BLOCK(self.refreshPlayerAction);
    }];
    
    [self.overlayToolsView setShowPhotoAlbumAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        SAFE_BLOCK(self.showPhotoAlbumAction, item);
    }];
    
    [self.overlayToolsView setToTopAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        SAFE_BLOCK(self.toTopAction, item);
    }];
    
    [self.overlayToolsView setToBottomAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        SAFE_BLOCK(self.toBottomAction, item);
    }];
    
    [self.overlayToolsView setCropAction:^(QHVCEditMatrixItem *item)
    {
        STRONG_SELF
        self.cropItem = item;
        [self.confirmView setHidden:NO];
        SAFE_BLOCK(self.startCropAction, item);
    }];
}

- (void)showOverlayToolsView:(QHVCEditMatrixItem *)item
{
    [self.freedomContentView setHidden:YES];
    [self.templateContentView setHidden:YES];
    [self.overlayToolsContentView setHidden:NO];
    [self.overlayToolsView setItem:item];
}

- (void)hideOverlayToolsView
{
    if ([[self.freedomBtn titleColorForState:UIControlStateNormal] isEqual:[QHVCEditPrefs colorHighlight]])
    {
        [self clickedFreedomBtn:self.freedomBtn];
    }
    else
    {
        [self clickedTemplateBtn:self.templateBtn];
    }
}

- (IBAction)clickedTemplateBtn:(UIButton *)sender
{
    [self.freedomContentView setHidden:YES];
    [self.templateContentView setHidden:NO];
    [self.overlayToolsContentView setHidden:YES];
    [sender setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
    [self.freedomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)clickedFreedomBtn:(UIButton *)sender
{
    [self.overlayToolsContentView setHidden:YES];
    [self.templateContentView setHidden:YES];
    [self.freedomContentView setHidden:NO];
    [sender setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
    [self.templateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)clickedCancelBtn:(UIButton *)sender
{
    [self.confirmView setHidden:YES];
    [self hideOverlayToolsView];
    SAFE_BLOCK(self.stopCropAction, self.cropItem, NO);
}

- (IBAction)clickedConfirmBtn:(UIButton *)sender
{
    [self.confirmView setHidden:YES];
    [self hideOverlayToolsView];
    SAFE_BLOCK(self.stopCropAction, self.cropItem, YES);
}

@end
