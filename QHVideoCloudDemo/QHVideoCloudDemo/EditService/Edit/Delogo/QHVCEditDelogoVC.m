//
//  QHVCEditDelogoVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/14.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditDelogoVC.h"
#import "QHVCEditOverlayItemPreview.h"
#import "QHVCEditCommandManager.h"

#define kDelogoItemWidth 200
#define kDelogoItemHeight 80

@interface QHVCEditDelogoVC ()
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) QHVCEditOverlayItemPreview* delogoItemView;

@end

@implementation QHVCEditDelogoVC

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)nextAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //nav
    self.titleLabel.text = @"去水印";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    //content
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_preview.frame), CGRectGetHeight(_preview.frame))];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [_contentView setUserInteractionEnabled:YES];
    [_preview addSubview:_contentView];
    
    //delogo view
    _delogoItemView = [[QHVCEditOverlayItemPreview alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentView.frame)/2.0 - kDelogoItemWidth/2.0,
                                                                                   CGRectGetHeight(_contentView.frame)/2.0 - kDelogoItemHeight/2.0,
                                                                                   kDelogoItemWidth, kDelogoItemHeight) overlayCommandId:0];
    [_delogoItemView setBackgroundColor:[UIColor clearColor]];
    [_delogoItemView setSelect:YES];
    [_delogoItemView setUserInteractionEnabled:YES];
    [_contentView addSubview:_delogoItemView];
    
    WEAK_SELF
    [_delogoItemView setMoveGestureAction:^(BOOL isEnd)
     {
         STRONG_SELF
         [self updateDelogoCommand:isEnd];
     }];
    
    [_delogoItemView setPinchGestureAction:^(BOOL isEnd)
     {
         STRONG_SELF
         [self updateDelogoCommand:isEnd];
     }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_contentView setFrame:CGRectMake(0, 0, CGRectGetWidth(_preview.frame), CGRectGetHeight(_preview.frame))];
    [_delogoItemView setFrame:CGRectMake(CGRectGetWidth(_contentView.frame)/2.0 - kDelogoItemWidth/2.0,
                                         CGRectGetHeight(_contentView.frame)/2.0 - kDelogoItemHeight/2.0,
                                         kDelogoItemWidth, kDelogoItemHeight)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //更新预设状态
    [self updateDelogoCommand:YES];
    [self refreshPlayer:YES];
}

- (void)updateDelogoCommand:(BOOL)isEnd
{
    CGRect rect = [self rectToOutputRect:self.delogoItemView];
    [[QHVCEditCommandManager manager] updateDelogo:rect];
    [self refreshPlayer:isEnd];
}

//view尺寸转为画布尺寸
- (CGRect)rectToOutputRect:(QHVCEditOverlayItemPreview *)delogoItemView
{
    UIView* view = delogoItemView;
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
