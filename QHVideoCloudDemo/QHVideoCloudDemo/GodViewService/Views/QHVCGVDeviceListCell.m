//
//  QHVCGVDeviceListCell.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2018/10/25.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVDeviceListCell.h"
#import "QHVCGVDeviceModel.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "QHVCToast.h"
#import "QHVCGlobalConfig.h"

// 摄像头icon
#define kQHVCGVDLCell_CameraIcon_W                  (49.0)
#define kQHVCGVDLCell_CameraIcon_H                  (49.0)
#define kQHVCGVDLCell_CameraIcon_MarginLeft         (10.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_CameraIcon_MarginTop          (7.0f * kQHVCScreenScaleTo6)
// 设备名
#define kQHVCGVDLCell_LabDeviceName_H               (20.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_LabDeviceName_MarginLeft      (4.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_LabDeviceName_MarginRight     (14.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_LabDeviceName_MarginTop       (7.0f * kQHVCScreenScaleTo6)
// 设备id
#define kQHVCGVDLCell_LabDeviceId_W                 (180.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_LabDeviceId_H                 (16.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_LabDeviceId_MaginTop          (2.0 * kQHVCScreenScaleTo6)
// 设备类型
#define kQHVCGVDLCell_LabDeviceType_W               (60.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_LabDeviceType_H               (16.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_LabDeviceType_MarginRight     (10.0 * kQHVCScreenScaleTo6)
// 缩略图
#define kQHVCGVDLCell_IVThumbnail_H                 (201.0f * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_IVThumbnail_MarginLeft        (14.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_IVThumbnail_MarginRight       (14.0 * kQHVCScreenScaleTo6)
#define kQHVCGVDLCell_IVThumbnail_MarginTop         (7.0f * kQHVCScreenScaleTo6)
// 播放按钮图片
#define kQHVCGVDLCell_IVPlay_W                      (40.0f)
#define kQHVCGVDLCell_IVPlay_H                      (40.0f)
// inputAccessoryView
#define kQHVCGVDLCell_InputAccessoryView_W          kQHVCScreenWidth
#define kQHVCGVDLCell_InputAccessoryView_H          (45.0f)
#define kQHVCGVDLCell_InputAccessoryView_Padding    (10.0f)
// inputAccessoryView 取消按钮
#define kQHVCGVDLCell_InputViewCancelButton_W       (50.0f)
#define kQHVCGVDLCell_InputViewCancelButton_H       (30.0f)
// inputAccessoryView 确定按钮
#define kQHVCGVDLCell_InputViewConfirmButton_W      (50.0f)
#define kQHVCGVDLCell_InputViewConfirmButton_H      (30.0f)
// inputAccessoryView 上的编辑框
#define kQHVCGVDLCell_InputViewTextField_W          (kQHVCScreenWidth - 4*kQHVCGVDLCell_InputAccessoryView_Padding - kQHVCGVDLCell_InputViewCancelButton_W - kQHVCGVDLCell_InputViewConfirmButton_W)
#define kQHVCGVDLCell_InputViewTextField_H          (30.0f)


// 文案
#define kQHVCGVDLCell_DefauleText                   @"未知"
#define kQHVCGVDLCell_IPC_Text                      @"IPC"
#define kQHVCGVDLCell_NVR_Text                      @"NVR"
#define kQHVCGVDLCell_NullName_Text                 @"名称不能为空"

@interface QHVCGVDeviceListCell () <UITextFieldDelegate>
/// 显示设备名
@property (nonatomic,strong) UITextField *tfName;
/// 显示设备Id
@property (nonatomic,strong) UILabel *labDeviceId;
/// 显示设备类型
@property (nonatomic,strong) UILabel *labDeviceType;
/// 缩略图
@property (nonatomic,strong) UIImageView *ivThumbnail;
/// 键盘inputAccessoryView上的编辑框
@property (nonatomic,strong) UITextField *inputViewTfName;
/// 原始名，用于修改名字并取消后 恢复展示
@property (nonatomic,copy)  NSString *originalName;
/// 蒙版
@property (nonatomic,strong) UIView *maskView;
@end

@implementation QHVCGVDeviceListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

#pragma mark - UI
- (void)initViews {
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [QHVCToolUtils colorWithHexString:@"#F2F2F4"];
    self.selectedBackgroundView = bgView;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    // 摄像头icon
    UIImageView *ivIcon = [UIImageView new];
    ivIcon.image = kQHVCGetImageWithName(@"godview_btn_monitor");
    ivIcon.contentMode = UIViewContentModeScaleAspectFill;
    ivIcon.clipsToBounds = YES;
    [self.contentView addSubview:ivIcon];
    [ivIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kQHVCGVDLCell_CameraIcon_MarginTop);
        make.leading.equalTo(self.contentView).offset(kQHVCGVDLCell_CameraIcon_MarginLeft);
        make.width.equalTo(@(kQHVCGVDLCell_CameraIcon_W));
        make.height.equalTo(@(kQHVCGVDLCell_CameraIcon_H));
    }];
    
    // 设备名
    self.tfName = [UITextField new];
    _tfName.font = kQHVCFontPingFangSCMedium(14);
    _tfName.delegate = self;
    _tfName.textColor = [QHVCToolUtils colorWithHexString:@"333333"];
    [self.contentView addSubview:_tfName];
    [_tfName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(ivIcon.mas_trailing).offset(kQHVCGVDLCell_LabDeviceName_MarginLeft);
        make.trailing.equalTo(self.contentView).offset(-kQHVCGVDLCell_LabDeviceName_MarginRight);
        make.top.equalTo(ivIcon).offset(kQHVCGVDLCell_LabDeviceName_MarginTop);
        make.height.equalTo(@(kQHVCGVDLCell_LabDeviceName_H));
    }];
    
    // 设备id
    self.labDeviceId = [UILabel new];
    _labDeviceId.font = kQHVCFontPingFangHKRegular(12);
    _labDeviceId.textColor = [QHVCToolUtils colorWithHexString:@"4D4D4D"];
    [self.contentView addSubview:_labDeviceId];
    [_labDeviceId mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_tfName);
        make.width.equalTo(@(kQHVCGVDLCell_LabDeviceId_W));
        make.top.equalTo(_tfName.mas_bottom).offset(kQHVCGVDLCell_LabDeviceId_MaginTop);
        make.height.equalTo(@(kQHVCGVDLCell_LabDeviceId_H));
    }];
    
    // 缩略图
    self.ivThumbnail = [UIImageView new];
    _ivThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _ivThumbnail.clipsToBounds = YES;
    _ivThumbnail.layer.cornerRadius = 4;
    [self.contentView addSubview:_ivThumbnail];
    [_ivThumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ivIcon.mas_bottom).offset(kQHVCGVDLCell_IVThumbnail_MarginTop);
        make.leading.equalTo(self.contentView).offset(kQHVCGVDLCell_IVThumbnail_MarginLeft);
        make.trailing.equalTo(self.contentView).offset(-kQHVCGVDLCell_IVThumbnail_MarginRight);
        make.height.equalTo(@(kQHVCGVDLCell_IVThumbnail_H));
    }];
    
    // 设备类型
    self.labDeviceType = [UILabel new];
    _labDeviceType.font = kQHVCFontPingFangHKRegular(12);
    _labDeviceType.textColor = [QHVCToolUtils colorWithHexString:@"4D4D4D"];
    _labDeviceType.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_labDeviceType];
    [_labDeviceType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(kQHVCGVDLCell_LabDeviceType_W));
        make.height.equalTo(@(kQHVCGVDLCell_LabDeviceType_H));
        make.centerY.equalTo(_labDeviceId);
        make.trailing.equalTo(_ivThumbnail).offset(-kQHVCGVDLCell_LabDeviceType_MarginRight);
    }];
    
    // 播放按钮图片
    UIImageView *ivPlay = [UIImageView new];
    ivPlay.image = kQHVCGetImageWithName(@"godview_btn_play_nor");
    [self.contentView addSubview:ivPlay];
    [ivPlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_ivThumbnail);
        make.width.equalTo(@(kQHVCGVDLCell_IVPlay_W));
        make.height.equalTo(@(kQHVCGVDLCell_IVPlay_H));
    }];
    
    // inputAccessoryView
    UIView *inputAccessoryView = [UIView new];
    inputAccessoryView.backgroundColor = [QHVCToolUtils colorWithHexString:@"E7E6ED"];
    inputAccessoryView.frame = CGRectMake(0, 0, kQHVCGVDLCell_InputAccessoryView_W, kQHVCGVDLCell_InputAccessoryView_H);
    _tfName.inputAccessoryView = inputAccessoryView;
    
    self.inputViewTfName = [UITextField new];
    _inputViewTfName.font = kQHVCFontPingFangSCMedium(14);
    _inputViewTfName.textColor = [QHVCToolUtils colorWithHexString:@"333333"];
    _inputViewTfName.frame = CGRectMake(kQHVCGVDLCell_InputAccessoryView_Padding, (kQHVCGVDLCell_InputAccessoryView_H - kQHVCGVDLCell_InputViewTextField_H)/2, kQHVCGVDLCell_InputViewTextField_W, kQHVCGVDLCell_InputViewTextField_H);
    _inputViewTfName.backgroundColor = [UIColor whiteColor];
    _inputViewTfName.layer.cornerRadius = 5;
    _inputViewTfName.delegate = self;
    [inputAccessoryView addSubview:_inputViewTfName];
    UIView *leftView = [UIView new];
    leftView.frame = CGRectMake(0, 0, 10, 1);
    _inputViewTfName.leftView = leftView;
    _inputViewTfName.leftViewMode = UITextFieldViewModeAlways;
    
    // 取消按钮
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTintColor:[QHVCToolUtils colorWithHexString:@"4D4D4D"]];
    btnCancel.layer.cornerRadius = 4;
    btnCancel.titleLabel.font = kQHVCFontPingFangSCMedium(14);
    [btnCancel setBackgroundColor:[QHVCToolUtils colorWithHexString:@"84B9F9"]];
    btnCancel.frame = CGRectMake(kQHVCScreenWidth - kQHVCGVDLCell_InputViewConfirmButton_W - kQHVCGVDLCell_InputViewCancelButton_W - kQHVCGVDLCell_InputAccessoryView_Padding*2, (kQHVCGVDLCell_InputAccessoryView_H-kQHVCGVDLCell_InputViewCancelButton_H)/2, kQHVCGVDLCell_InputViewCancelButton_W, kQHVCGVDLCell_InputViewCancelButton_H);
    [btnCancel addTarget:self action:@selector(cancelEditName) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:btnCancel];
    
    // 确定按钮
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
    [btnConfirm setTintColor:[UIColor whiteColor]];
    btnConfirm.layer.cornerRadius = 4;
    btnConfirm.titleLabel.font = kQHVCFontPingFangSCMedium(14);
    [btnConfirm setBackgroundColor:[QHVCToolUtils colorWithHexString:@"84B9F9"]];
    [btnConfirm addTarget:self action:@selector(confirmChangeName) forControlEvents:UIControlEventTouchUpInside];
    [inputAccessoryView addSubview:btnConfirm];
    btnConfirm.frame = CGRectMake(kQHVCScreenWidth - kQHVCGVDLCell_InputAccessoryView_Padding - kQHVCGVDLCell_InputViewConfirmButton_W, (kQHVCGVDLCell_InputAccessoryView_H - kQHVCGVDLCell_InputViewConfirmButton_H)/2, kQHVCGVDLCell_InputViewConfirmButton_W, kQHVCGVDLCell_InputViewConfirmButton_H);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 设置左滑删除样式 iOS11前用此方法，iOS11后在controller里设置
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
                subView.backgroundColor = [QHVCToolUtils colorWithHexString:@"#F2F2F4"];
                for (UIView *btnView in subView.subviews) {
                    if ([btnView isKindOfClass:NSClassFromString(@"_UITableViewCellActionButton")]) {
                        UIButton *btn = (UIButton *)btnView;
                        btn.bounds = CGRectMake(0, 0, 50, 50);
                        btn.backgroundColor = [UIColor whiteColor];
                        btn.layer.cornerRadius = 25;
                        [btn setBackgroundImage:[UIImage imageNamed:@"godview_device_delete"] forState:UIControlStateNormal];
                        [btn setBackgroundColor:[QHVCToolUtils colorWithHexString:@"#F2F2F4"]];
                        // 移除标题
                        for (UIView *view in btn.subviews) {
                            if ([view isKindOfClass:NSClassFromString(@"UIButtonLabel")]) {
                                [view removeFromSuperview];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}


- (void)updateCell:(QHVCGVDeviceModel *)deviceModel {
    if (deviceModel == nil) {
        return;
    }
    self.originalName = deviceModel.name ?: kQHVCGVDLCell_DefauleText;
    _tfName.text = deviceModel.name ?: kQHVCGVDLCell_DefauleText;
    _labDeviceType.text = deviceModel.isPublic == 0 ? kQHVCGVDLCell_IPC_Text : kQHVCGVDLCell_NVR_Text;
    _labDeviceId.text = [NSString stringWithFormat:@"ID : %@",deviceModel.bindedSN ?: kQHVCGVDLCell_DefauleText];
    [_ivThumbnail setImageWithURL:[NSURL URLWithString:deviceModel.converImg] placeholderImage:kQHVCGetImageWithName(@"godsees_camera_default")];
    
}

- (void)showMaskView {
    if (_maskView != nil) {
        [_maskView removeFromSuperview];
    }
    self.maskView = [UIView new];
    _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    _maskView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        _maskView.alpha = 1;
    }];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelEditName)];
    [_maskView addGestureRecognizer:tapGR];
    _maskView.userInteractionEnabled = YES;
}

- (void)hideMaskView {
    if (_maskView) {
        [UIView animateWithDuration:0.3 animations:^{
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [_maskView removeFromSuperview];
        }];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    for (NSUInteger idx = 0; idx < string.length; idx++) {
        unichar ch = [string characterAtIndex:idx];
        if (![QHVCGVDeviceListCell isChinese:ch]
            && ![QHVCGVDeviceListCell isLetter:ch]
            && ![QHVCGVDeviceListCell isDigit:ch]) {
            return NO;
        }
    }
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == _tfName) {
        _inputViewTfName.text = text;
    }
    return YES;
}

#pragma mark - 键盘事件
- (void)keyboardWillShow {
    if (_tfName.isFirstResponder) {
        [self showMaskView];
        _inputViewTfName.text = _tfName.text;
        [_inputViewTfName becomeFirstResponder];
        _tfName.enabled = NO;
    }
}

- (void)keyboardWillHide {
    [self hideMaskView];
    _tfName.enabled = YES;
}

#pragma mark - UI事件
- (void)cancelEditName {
    if (_inputViewTfName.isFirstResponder) {
        [_inputViewTfName resignFirstResponder];
    }
    if (_tfName.isFirstResponder) {
        [_tfName resignFirstResponder];
    }
}

- (void)confirmChangeName {
    if ([QHVCToolUtils isNullString:_inputViewTfName.text]) {
        [QHVCToast makeToast:kQHVCGVDLCell_NullName_Text];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(deviceListCell:needChangeDeviceName:toDeviceName:)]) {
        [self.delegate deviceListCell:self needChangeDeviceName:_originalName toDeviceName:_inputViewTfName.text];
    }
    
    if (_inputViewTfName.isFirstResponder) {
        [_inputViewTfName resignFirstResponder];
    }
    if (_tfName.isFirstResponder) {
        [_tfName resignFirstResponder];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (BOOL)isChinese:(unichar)aChar
{
    if (0x4e00 <= aChar && aChar <= 0x9fa5)
        return YES;
    else if (0x2e80 <= aChar && aChar <= 0x2eff)
        return YES;
    else if (0x31c0 <= aChar && aChar < 0x31ef)
        return YES;
    else if (0x2f00 <= aChar && aChar <= 0x2fdf)
        return YES;
    
    return NO;
}

+ (BOOL)isDigit:(unichar)aChar {
    return aChar >= '0' && aChar <= '9';
}

+ (BOOL)isLetter:(unichar)aChar {
    if ((aChar >= 'a' && aChar <= 'z')
        || (aChar >= 'A' && aChar <= 'Z')) {
        return YES;
    }
    return NO;
}

@end
