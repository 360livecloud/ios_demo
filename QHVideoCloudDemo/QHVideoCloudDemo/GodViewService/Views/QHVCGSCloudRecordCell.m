//
//  QHVCGSCloudRecordCell.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/9.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSCloudRecordCell.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import "QHVCGlobalConfig.h"

// 时间
#define kQHVCGSCloudRecordCell_LabRecordDate_W              (87.5f)
#define kQHVCGSCloudRecordCell_LabRecordDate_H              (21.0f * kQHVCScreenScaleTo6)
#define kQHVCGSCloudRecordCell_LabRecordDate_MarginRight    (4.0f * kQHVCScreenScaleTo6)
#define kQHVCGSCloudRecordCell_LabRecordDate_MarginBottom   (4.0f * kQHVCScreenScaleTo6)

// 菜单按钮
#define kQHVCGSCloudRecordCell_BtnMenu_MarginTop            (4.0f * kQHVCScreenScaleTo6)
#define kQHVCGSCloudRecordCell_BtnMenu_W                    (28.0f)
#define kQHVCGSCloudRecordCell_BtnMenu_H                    (28.0f)

// 删除/取消按钮
#define kQHVCGSCloudRecordCell_BtnDel_W                     (39.0f * kQHVCScreenScaleTo6)
#define kQHVCGSCloudRecordCell_BtnDel_H                     (39.0f * kQHVCScreenScaleTo6)
#define kQHVCGSCloudRecordCell_BtnDel_MarginLeft            (41.0f * kQHVCScreenScaleTo6)

@interface QHVCGSCloudRecordCell ()
@property (nonatomic,strong) UIImageView *ivThumbnail;
@property (nonatomic,strong) UILabel *labRecordDate;
@property (nonatomic,strong) UIView *menuView;
@property (nonatomic,strong) NSIndexPath *indexPath;
@end

@implementation QHVCGSCloudRecordCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

- (void)initViews
{
    // 缩略图
    _ivThumbnail = [UIImageView new];
    _ivThumbnail.image = kQHVCGetImageWithName(@"godview_record_thumbnail_tmp");
    _ivThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _ivThumbnail.clipsToBounds = YES;
    _ivThumbnail.layer.cornerRadius = 3;
    [self.contentView addSubview:_ivThumbnail];
    [_ivThumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    // 时间
    _labRecordDate = [UILabel new];
    _labRecordDate.font = kQHVCFontPingFangHKRegular(14);
    _labRecordDate.textColor = [UIColor whiteColor];
    _labRecordDate.textAlignment = NSTextAlignmentCenter;
    _labRecordDate.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    _labRecordDate.text = @"2018-08-12";
    _labRecordDate.layer.cornerRadius = 2;
    _labRecordDate.clipsToBounds = YES;
    [_ivThumbnail addSubview:_labRecordDate];
    [_labRecordDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_ivThumbnail).offset(-kQHVCGSCloudRecordCell_LabRecordDate_MarginRight);
        make.bottom.equalTo(_ivThumbnail).offset(-kQHVCGSCloudRecordCell_LabRecordDate_MarginBottom);
        make.height.equalTo(@(kQHVCGSCloudRecordCell_LabRecordDate_H));
        make.width.equalTo(@(kQHVCGSCloudRecordCell_LabRecordDate_W));
    }];
    
    // 菜单按钮
    UIButton *btnMeun = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMeun setBackgroundImage:kQHVCGetImageWithName(@"godsees_videolist_more") forState:UIControlStateNormal];
    [btnMeun addTarget:self action:@selector(btnMenuClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnMeun];
    [btnMeun mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_labRecordDate);
        make.top.equalTo(self.contentView).offset(kQHVCGSCloudRecordCell_BtnMenu_MarginTop);
        make.width.height.equalTo(@(kQHVCGSCloudRecordCell_BtnMenu_W));
    }];
}

- (UIView *)menuView
{
    if (_menuView)
    {
        return _menuView;
    }
    _menuView = [UIView new];
    _menuView.layer.cornerRadius = 3;
    _menuView.clipsToBounds = YES;
    [self.contentView addSubview:_menuView];
    [_menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing)];
    [_menuView addGestureRecognizer:tapGR];
    
    // maskView
    UIView *maskView = [UIView new];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_menuView addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_menuView);
    }];
    
    // 删除按钮
    UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDel setBackgroundImage:kQHVCGetImageWithName(@"godsees_record_del") forState:UIControlStateNormal];
    [btnDel addTarget:self action:@selector(btnDeleteClick) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:btnDel];
    [btnDel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_menuView);
        make.leading.equalTo(_menuView).offset(kQHVCGSCloudRecordCell_BtnDel_MarginLeft);
        make.width.equalTo(@(kQHVCGSCloudRecordCell_BtnDel_W));
        make.height.equalTo(@(kQHVCGSCloudRecordCell_BtnDel_H));
    }];
    
    // 取消按钮
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setBackgroundImage:kQHVCGetImageWithName(@"godsees_record_cancel") forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCancelClick) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:btnCancel];
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_menuView).offset(-kQHVCGSCloudRecordCell_BtnDel_MarginLeft);
        make.centerY.width.height.equalTo(btnDel);
    }];
    
    return _menuView;
}

- (void)showMeun
{
    if (self.menuView.alpha < 1) {
        [self.contentView bringSubviewToFront:self.menuView];
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.alpha = 1;
        }];
    }
}

- (void)hideMenu
{
    if (self.menuView.alpha > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.alpha = 0;
        }];
    }
}

- (void)setupWithImageName:(NSString *)imageName indexPath:(NSIndexPath *)indexPath
{
    self.indexPath = indexPath;
    self.menuView.alpha = 0;
    _ivThumbnail.image = [UIImage imageNamed:imageName];
}

#pragma mark - UI事件
- (void)btnCancelClick
{
    [self hideMenu];
}

- (void)btnDeleteClick
{
    if ([self.delegate respondsToSelector:@selector(cloudRecordCell:didClickDeleteAtIndexPath:)])
    {
        [self.delegate cloudRecordCell:self didClickDeleteAtIndexPath:_indexPath];
    }
}

-  (void)btnMenuClick
{
    if ([self.delegate respondsToSelector:@selector(cloudRecordCell:didClickMenuIndexPath:)])
    {
        [self.delegate cloudRecordCell:self didClickMenuIndexPath:_indexPath];
    }
    [self showMeun];
}

- (void)doNothing {
    // 在出现蒙版菜单时，用于屏蔽cell选中事件（点击蒙版无响应，而不是跳转到播放界面）
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
