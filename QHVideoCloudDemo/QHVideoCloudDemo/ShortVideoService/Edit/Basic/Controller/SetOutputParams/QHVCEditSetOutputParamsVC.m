//
//  QHVCEditSetOutputParamsVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/11/14.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSetOutputParamsVC.h"
#import "QHVCEditReorderVC.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditPrefs.h"
#import "UIView+Toast.h"
#import "QHVCShortVideoUtils.h"
#import "QHVCPhotoManager.h"

#ifdef QHVCADVANCED
#import "QHVCEditMediaEditorConfig+Advanced.h"
#endif

@interface QHVCEditSetOutputParamsVC () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIButton *outputSizeBtn;
@property (weak, nonatomic) IBOutlet UIButton *fpsBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UIView *outputSizePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *outputSizePicker;
@property (weak, nonatomic) IBOutlet UIView *outputFpsPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *outputFpsPicker;
@property (weak, nonatomic) IBOutlet UITextField *customWidthTextfield;
@property (weak, nonatomic) IBOutlet UITextField *customHeightTextfield;
@property (weak, nonatomic) IBOutlet UISwitch *photoIdentifierSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, retain) NSArray* photoItems;
@property (nonatomic, retain) NSArray* outputSizeArray;
@property (nonatomic, retain) NSArray* fpsArray;
@property (nonatomic, assign) NSInteger curOutputWidth;
@property (nonatomic, assign) NSInteger curOutputHeight;
@property (nonatomic, assign) NSInteger curOutputFps;
@property (nonatomic, assign) NSInteger curBitrate;
@property (nonatomic, assign) BOOL usePhotoIdentifier;

@end

@implementation QHVCEditSetOutputParamsVC

#pragma mark - Life Circle Methods

- (instancetype)initWithItems:(NSArray<QHVCPhotoItem *> *)items
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    self.photoItems = items;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"设置输出参数"];
    [self.topConstraint setConstant:[self topBarHeight]];
    
    self.outputSizeArray = @[@[@(640), @(360)],
                             @[@(854), @(480)],
                             @[@(1280), @(720)],
                             @[@(1920), @(1080)]];
    self.fpsArray = @[@(15), @(25), @(30)];
    self.curOutputFps = 30;
    self.curOutputWidth = 1280;
    self.curOutputHeight = 720;
    self.curBitrate = 4.5 * 1000 * 1000;
    [self.indicator setHidden:YES];
    
    if (@available(iOS 9.0, *))
    {
        self.usePhotoIdentifier = YES;
        [self.photoIdentifierSwitch setOn:YES];
    }
    else
    {
        self.usePhotoIdentifier = NO;
        [self.photoIdentifierSwitch setOn:NO];
    }
}

#pragma mark - Event Methods

- (void)nextAction:(UIButton *)btn
{
    if (self.curOutputWidth <=0 || self.curOutputHeight <= 0)
    {
        [self.view makeToast:@"输出分辨率必须大于0"];
        return;
    }
    
    [QHVCShortVideoUtils setAppInfo];
#ifdef QHVCADVANCED
    WEAK_SELF
    [[QHVCEditMediaEditorConfigAdvanced sharedInstance] requestAdvancedAuth:^{
        STRONG_SELF
#endif
        [[QHVCEditMediaEditorConfig sharedInstance] setOutputSize:CGSizeMake(self.curOutputWidth, self.curOutputHeight)];
        [[QHVCEditMediaEditorConfig sharedInstance] setOutputFps:self.curOutputFps];
        [[QHVCEditMediaEditorConfig sharedInstance] setOutputVideoBitrate:self.curBitrate];
        [[QHVCEditMediaEditorConfig sharedInstance] setUsePhotoIdentifier:self.usePhotoIdentifier];
        
        QHVCEditReorderVC *vc = [[QHVCEditReorderVC alloc] initWithItems:self.photoItems];
        if (![[QHVCEditMediaEditorConfig sharedInstance] usePhotoIdentifier])
        {
            //文件存入沙盒
            [self.indicator setHidden:NO];
            [self.indicator startAnimating];
            WEAK_SELF
            [[QHVCPhotoManager manager] writeAssetsToSandbox:self.photoItems complete:^{
                STRONG_SELF
                [self.indicator setHidden:YES];
                [self.indicator stopAnimating];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
        else
        {
            [self.indicator setHidden:NO];
            [self.indicator startAnimating];
            
            //添加相册标识符
            [[QHVCPhotoManager manager] addAssetIdentifier:self.photoItems];
            
            dispatch_group_t group = dispatch_group_create();
            [self.photoItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
            {
                dispatch_group_enter(group);
                [[QHVCPhotoManager manager] fetchCloudAsset:obj completion:^{
                    dispatch_group_leave(group);
                }];
            }];
            
            WEAK_SELF
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                STRONG_SELF
                [self.indicator setHidden:YES];
                [self.indicator stopAnimating];
                [self.navigationController pushViewController:vc animated:YES];
            });
            
        }
        
#ifdef QHVCADVANCED
    }];
#endif

}

- (IBAction)clickedOutputSizeBtn:(UIButton *)sender
{
    [self.outputSizePickerView setHidden:NO];
    [self.outputFpsPickerView setHidden:YES];
    
    if ([self.customWidthTextfield isFirstResponder])
    {
        [self.customWidthTextfield resignFirstResponder];
    }
    
    if ([self.customHeightTextfield isFirstResponder])
    {
        [self.customHeightTextfield resignFirstResponder];
    }
}

- (IBAction)clickedOutputSizeConfirmBtn:(id)sender
{
    if ([self.outputSizePickerView isHidden])
    {
        return;
    }
    
    NSInteger row = [self.outputSizePicker selectedRowInComponent:0];
    NSArray* size = [self.outputSizeArray objectAtIndex:row];
    NSInteger width = [size[0] integerValue];
    NSInteger height = [size[1] integerValue];

    [self updateOutputSizeBtnTitle:width height:height];
    [self.customWidthTextfield setText:@""];
    [self.customHeightTextfield setText:@""];
    [self.outputSizePickerView setHidden:YES];
}

- (IBAction)clickedFPSBtn:(UIButton *)sender
{
    [self.outputFpsPickerView setHidden:NO];
    [self.outputSizePickerView setHidden:YES];
    
    if ([self.customWidthTextfield isFirstResponder])
    {
        [self.customWidthTextfield resignFirstResponder];
    }
    
    if ([self.customHeightTextfield isFirstResponder])
    {
        [self.customHeightTextfield resignFirstResponder];
    }
}

- (IBAction)clickedOutputFpsConfirmBtn:(id)sender
{
    if ([self.outputFpsPickerView isHidden])
    {
        return;
    }
    
    NSInteger row = [self.outputFpsPicker selectedRowInComponent:0];
    NSNumber* fps = [self.fpsArray objectAtIndex:row];
    [self.fpsBtn setTitle:[NSString stringWithFormat:@"%@", fps] forState:UIControlStateNormal];
    [self.outputFpsPickerView setHidden:YES];
    self.curOutputFps = [fps integerValue];
}

- (IBAction)onVideoBitrateSliderValueChanged:(UISlider *)sender
{
    self.curBitrate = sender.value * 1000 * 1000;
    [self.bitrateLabel setText:[NSString stringWithFormat:@"%.1fMbps", sender.value]];
}

- (IBAction)onPhotoAlbumSwitchValueChanged:(UISwitch *)sender
{
    if (@available(iOS 9.0, *))
    {
        self.usePhotoIdentifier = sender.isOn ? YES:NO;
    }
    else
    {
        [self.view makeToast:@"相册免copy仅适用于 iOS9.0 之后版本"];
        [sender setOn:NO];
    }
}

#pragma mark - Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.outputSizePicker)
    {
        return self.outputSizeArray.count;
    }
    else if (pickerView == self.outputFpsPicker)
    {
        return self.fpsArray.count;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.outputSizePicker)
    {
        if ([self.outputSizeArray count] > row)
        {
            NSInteger width = [self.outputSizeArray[row][0] integerValue];
            NSInteger height = [self.outputSizeArray[row][1] integerValue];
            NSString* title = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
            return title;
        }
    }
    else if (pickerView == self.outputFpsPicker)
    {
        if ([self.fpsArray count] > row)
        {
            NSInteger fps = [self.fpsArray[row] integerValue];
            NSString* title = [NSString stringWithFormat:@"%ld", fps];
            return title;
        }
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.outputSizePicker)
    {
        NSArray* size = [self.outputSizeArray objectAtIndex:row];
        NSInteger width = [size[0] integerValue];
        NSInteger height = [size[1] integerValue];
        [self updateOutputSizeBtnTitle:width height:height];
    }
    else if (pickerView == self.outputFpsPicker)
    {
        NSNumber* fps = [self.fpsArray objectAtIndex:row];
        [self.fpsBtn setTitle:[NSString stringWithFormat:@"%@", fps] forState:UIControlStateNormal];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.outputSizePickerView setHidden:YES];
    [self.outputFpsPickerView setHidden:YES];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString* widthText = self.customWidthTextfield.text;
    NSString* heightText = self.customHeightTextfield.text;
    NSInteger width = [widthText integerValue];
    NSInteger height = [heightText integerValue];
    
    if (width > 0 && height > 0)
    {
        [self updateOutputSizeBtnTitle:width height:height];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)updateOutputSizeBtnTitle:(NSInteger)width height:(NSInteger)height
{
    NSString* title = [NSString stringWithFormat:@"%ldx%ld", (long)width, (long)height];
    self.curOutputWidth = width;
    self.curOutputHeight = height;
    [self.outputSizeBtn setTitle:title forState:UIControlStateNormal];
}

@end
