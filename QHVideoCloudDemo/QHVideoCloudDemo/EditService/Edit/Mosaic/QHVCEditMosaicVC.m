//
//  QHVCEditMosaicVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/7/23.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditMosaicVC.h"
#import "QHVCEditMosaicView.h"
#import "QHVCEditOverlayItemPreview.h"
#import "QHVCEditCommandManager.h"

#define kMosaicItemWidth 200
#define kMosaicItemHeight 80

@interface QHVCEditMosaicVC ()
@property (nonatomic, strong) QHVCEditMosaicView* mosaicView;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) QHVCEditOverlayItemPreview* mosaicItemView;
@property (nonatomic, assign) CGFloat mosaicDegree;

@end

@implementation QHVCEditMosaicVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //nav
    self.titleLabel.text = @"马赛克";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    //content
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_preview.frame), CGRectGetHeight(_preview.frame))];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [_contentView setUserInteractionEnabled:YES];
    [_preview addSubview:_contentView];
    
    //mosaic view
    _mosaicItemView = [[QHVCEditOverlayItemPreview alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentView.frame)/2.0 - kMosaicItemWidth/2.0,
                                                                                   CGRectGetHeight(_contentView.frame)/2.0 - kMosaicItemHeight/2.0,
                                                                                   kMosaicItemWidth, kMosaicItemHeight) overlayCommandId:0];
    [_mosaicItemView setBackgroundColor:[UIColor clearColor]];
    [_mosaicItemView setSelect:YES];
    [_mosaicItemView setUserInteractionEnabled:YES];
    [_contentView addSubview:_mosaicItemView];
    
    WEAK_SELF
    [_mosaicItemView setMoveGestureAction:^(BOOL isEnd)
    {
        STRONG_SELF
        [self updateMosaicCommand:isEnd];
    }];
    
    [_mosaicItemView setPinchGestureAction:^(BOOL isEnd)
    {
        STRONG_SELF
        [self updateMosaicCommand:isEnd];
    }];
}

- (void)nextAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_contentView setFrame:CGRectMake(0, 0, CGRectGetWidth(_preview.frame), CGRectGetHeight(_preview.frame))];
    [_mosaicItemView setFrame:CGRectMake(CGRectGetWidth(_contentView.frame)/2.0 - kMosaicItemWidth/2.0,
                                         CGRectGetHeight(_contentView.frame)/2.0 - kMosaicItemHeight/2.0,
                                         kMosaicItemWidth, kMosaicItemHeight)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mosaicView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditMosaicView class] description] owner:self options:nil][0];
    _mosaicView.frame = CGRectMake(0, kScreenHeight - 80, kScreenWidth, 80);
    [self.view addSubview:_mosaicView];
    
    WEAK_SELF
    [_mosaicView setMosaicValueChangedBlock:^(CGFloat value, BOOL isEnd)
    {
        STRONG_SELF
        self.mosaicDegree = value;
        [self updateMosaicCommand:isEnd];
    }];
    
    //更新预设状态
    self.mosaicDegree = 0.5;
    [self updateMosaicCommand:YES];
    [self refreshPlayer:YES];
}

- (void)updateMosaicCommand:(BOOL)isEnd
{
    CGRect rect = [self rectToOutputRect:self.mosaicItemView];
    [[QHVCEditCommandManager manager] updateMosaic:rect degree:self.mosaicDegree];
    [self refreshPlayer:isEnd];
}

//view尺寸转为画布尺寸
- (CGRect)rectToOutputRect:(QHVCEditOverlayItemPreview *)mosaicItemView
{
    UIView* view = mosaicItemView;
    CGRect rect = view.frame;
    
    CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
    CGFloat scaleW = outputSize.width/CGRectGetWidth(self.contentView.frame);
    CGFloat scaleH = outputSize.height/CGRectGetHeight(self.contentView.frame);
    
    CGFloat x = rect.origin.x * scaleW;
    CGFloat y = rect.origin.y * scaleH;
    CGFloat w = rect.size.width * scaleW;
    CGFloat h = rect.size.height * scaleH;
    
    CGRect newRect = CGRectMake(x, y, w, h);
    return newRect;
}

@end
