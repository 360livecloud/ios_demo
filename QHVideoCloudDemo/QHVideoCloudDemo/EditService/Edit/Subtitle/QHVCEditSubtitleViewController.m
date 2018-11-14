//
//  QHVCEditSubtitleViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSubtitleViewController.h"
#import "QHVCEditSubtitleView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditFrameView.h"
#import "QHVCEditSubtitleItem.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditStickerIconView.h"

@interface QHVCEditSubtitleViewController ()
{
    QHVCEditSubtitleView *_subtitleView;
    QHVCEditFrameView *_frameView;
    QHVCEditFrameStatus _viewType;
    QHVCEditSubtitleItem *_currentSubtitleItem;
    QHVCEditStickerIconView *_sticker;
    NSArray *_colorsArray;
    BOOL _hasChange;
}
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *subtitleInfos;

@end

@implementation QHVCEditSubtitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"字幕";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    _hasChange = NO;
    _subtitleInfos = [NSMutableArray arrayWithArray:[QHVCEditPrefs sharedPrefs].subtitleTimestamp];
    
    _colorsArray = @[@[@"edit_color_black",@"000000"],@[@"edit_color_blue",@"125FDF"],
                     @[@"edit_color_gray",@"888888"],@[@"edit_color_green",@"25B727"],@[@"edit_color_pink",@"FE8AB1"],
                     @[@"edit_color_red",@"F54343"],@[@"edit_color_white",@"FFFFFF"],@[@"edit_color_yellow",@"FFDB4F"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createFrameView];
    _sliderViewBottom.constant = 70;
}

- (void)createFrameView
{
    _frameView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditFrameView class] description] owner:self options:nil][0];
    _frameView.frame = CGRectMake(0, kScreenHeight - 160, kScreenWidth, 160);
    _frameView.duration = self.durationMs;
    _frameView.timeStamp = [QHVCEditPrefs sharedPrefs].subtitleTimestamp;
    _viewType = QHVCEditFrameStatusAdd;
    [_frameView setUIStatus:_viewType];
    
    __weak typeof(self) weakSelf = self;
    _frameView.addCompletion = ^(NSTimeInterval insertStartMs) {
        [weakSelf handleAddAction:insertStartMs];
    };
    _frameView.doneCompletion = ^(NSTimeInterval insertEndMs) {
        [weakSelf handleDoneAction:insertEndMs];
    };
    _frameView.editCompletion = ^{
        [weakSelf handleEditAction];
    };
    _frameView.discardCompletion = ^{
        [weakSelf handleDiscardAction];
    };
    [self.view addSubview:_frameView];
}

- (void)handleAddAction:(NSTimeInterval)insertStartMs
{
    [self updateViewType:QHVCEditFrameStatusEdit];
    
    _currentSubtitleItem = [[QHVCEditSubtitleItem alloc] init];
    _currentSubtitleItem.insertStartTimeMs = insertStartMs;
    
    _subtitleView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditSubtitleView class] description] owner:self options:nil][0];
    _subtitleView.frame = CGRectMake(0, kScreenHeight - 170, kScreenWidth, 170);
    _subtitleView.subtitleItem = _currentSubtitleItem;
    _subtitleView.colorsArray = _colorsArray;
    __weak typeof(self) weakSelf = self;
    _subtitleView.refreshCompletion = ^(QHVCEditSubtitleItem *item) {
        [weakSelf handleRefreshSticker:item];
    };
    [self.view addSubview:_subtitleView];
}

- (void)handleRefreshSticker:(QHVCEditSubtitleItem *)item
{
    if (_sticker) {
        [self updateSticker:item];
    }
    else
    {
        [self addSticker:item];
    }
}

- (void)updateSticker:(QHVCEditSubtitleItem *)item
{
    _sticker.sticker.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",kStylesName,@(item.styleIndex)]];
    [self updateSubtitleText:item];
}

- (void)updateSubtitleText:(QHVCEditSubtitleItem *)item
{
    _sticker.subtitle.text = item.subtitleText;
    _sticker.subtitle.font = [UIFont systemFontOfSize:item.fontValue];
    _sticker.subtitle.textColor = [QHVCEditPrefs colorHex:_colorsArray[item.colorIndex][1]];
    
    [self deleteSubtitleCommand:_sticker];
    [self addSubtitleCommand:_sticker];
    [self refreshPlayer];
}

- (void)addSticker:(QHVCEditSubtitleItem *)item
{
    CGFloat x = [QHVCEditPrefs randomNum:0 to:_preview.width - 100];
    CGFloat y = [QHVCEditPrefs randomNum:0 to:_preview.height - 100];
    
    _sticker = [[QHVCEditStickerIconView alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
    _sticker.sticker.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",kStylesName,@(item.styleIndex)]];
    _sticker.subtitle.text = item.subtitleText;
    _sticker.subtitle.font = [UIFont systemFontOfSize:item.fontValue];
    _sticker.subtitle.textColor = [QHVCEditPrefs colorHex:_colorsArray[item.colorIndex][1]];
    
    WEAK_SELF
    _sticker.deleteCompletion = ^(QHVCEditStickerIconView *sticker) {
        STRONG_SELF
        [self handleDeleteAction];
        [self refreshPlayer];
    };
    
    _sticker.pinchAction = ^(BOOL isEnd, QHVCEditStickerIconView *sticker)
    {
        STRONG_SELF
        [self updateSubtitleCommand:sticker];
        [self refreshPlayer:isEnd];
    };
    
    _sticker.moveAction = ^(BOOL isEnd, QHVCEditStickerIconView *sticker)
    {
        STRONG_SELF
        [self updateSubtitleCommand:sticker];
        [self refreshPlayer:isEnd];
    };
    
    _sticker.rotateAction = ^(BOOL isEnd, QHVCEditStickerIconView *sticker)
    {
        STRONG_SELF
        [self updateSubtitleCommand:sticker];
        [self refreshPlayer:isEnd];
    };
    
    _sticker.fadeInOutAction = ^(QHVCEditStickerIconView *sticker)
    {
        STRONG_SELF
        [self addFadeInOutAnimation:sticker];
        [self refreshPlayer];
    };
    
    _sticker.moveInOutAction = ^(QHVCEditStickerIconView *sticker)
    {
        STRONG_SELF
        [self addMoveInOutAnimation:sticker];
        [self refreshPlayer];
    };
    
    _sticker.jumpInOutAction = ^(QHVCEditStickerIconView *sticker)
    {
        STRONG_SELF
        [self addJumpInOutAnimation:sticker];
        [self refreshPlayer];
    };
    
    _sticker.rotateInOutAction = ^(QHVCEditStickerIconView *sticker)
    {
        STRONG_SELF
        [self addRotateInOutAnimation:sticker];
        [self refreshPlayer];
    };
    
    [_preview addSubview:_sticker];
    [_sticker.sticker setHidden:YES];
    [_sticker.subtitle setHidden:YES];
    
    [self addSubtitleCommand:_sticker];
    [self refreshPlayer];
}

- (void)handleDeleteAction
{
    [_subtitleView resetView];
    [self deleteSubtitleCommand:_sticker];
}

- (void)handleDoneAction:(NSTimeInterval)insertEndMs
{
    [self nextAction:nil];
}

- (void)handleEditAction
{
    [self backAction:nil];
}

- (void)handleDiscardAction
{
    [_subtitleView removeFromSuperview];
    _subtitleView = nil;
    
    [self updateViewType:QHVCEditFrameStatusAdd];
}

- (void)updateViewType:(QHVCEditFrameStatus)status
{
    _viewType = status;
    
    if (status == QHVCEditFrameStatusAdd) {
        self.titleLabel.text = @"字幕";
        [_frameView setUIStatus:_viewType];
        _frameView.hidden = NO;
        _sliderViewBottom.constant = 70;
        
        [_frameView removeUncompleteTimestamp];
    }
    else if (status == QHVCEditFrameStatusEdit)
    {
        self.titleLabel.text = @"选择";
        _frameView.hidden = YES;
        _sliderViewBottom.constant = 70;
    }
    else if (status == QHVCEditFrameStatusDone)
    {
        self.titleLabel.text = @"添加";
        [_frameView setUIStatus:_viewType];
        _frameView.hidden = NO;
        _sliderViewBottom.constant = 70;
    }
}

- (void)nextAction:(UIButton *)btn
{
    if(_viewType == QHVCEditFrameStatusEdit)
    {
        if (_currentSubtitleItem.styleIndex >= 0) {
            _subtitleView.hidden = YES;

            [self updateViewType:QHVCEditFrameStatusDone];
        }
        else
        {
            [_subtitleView removeFromSuperview];
            _subtitleView = nil;

            [self updateViewType:QHVCEditFrameStatusAdd];
        }
    }
    else if (_viewType == QHVCEditFrameStatusDone)
    {
        [_subtitleView removeFromSuperview];
        _subtitleView = nil;

        [self updateViewType:QHVCEditFrameStatusAdd];

        UIImage *composeImage = [QHVCEditPrefs convertViewToImage:_sticker.sticker];
        _currentSubtitleItem.composeImage = composeImage;
        _currentSubtitleItem.insertEndTimeMs = [_frameView fetchCurrentTimeStampMs];
        
        [_sticker removeFromSuperview];
        _sticker = nil;
        
        [self resetPlayer:0.0];
        _hasChange = YES;
    }
    else
    {
        if (_hasChange) {
            if (self.confirmCompletion) {
                self.confirmCompletion(QHVCEditPlayerStatusReset);
            }
        }
        [self releasePlayerVC];
    }
}

- (void)backAction:(UIButton *)btn
{
    if(_viewType == QHVCEditFrameStatusEdit)
    {
        [_subtitleView removeFromSuperview];
        _subtitleView = nil;
        
        if (_sticker) {
            [_sticker removeFromSuperview];
            _sticker = nil;
        }
        [self updateViewType:QHVCEditFrameStatusAdd];
    }
    else if (_viewType == QHVCEditFrameStatusDone)
    {
        _subtitleView.hidden = NO;

        [self updateViewType:QHVCEditFrameStatusEdit];
    }
    else
    {
        if (_hasChange) {
        }
        [QHVCEditPrefs sharedPrefs].subtitleTimestamp = _subtitleInfos;
        [self releasePlayerVC];
    }
}

- (void)onKeyboardNotification:(NSNotification *)notif
{
    NSDictionary *userInfo = notif.userInfo;
    //
    // Get keyboard animation.
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    if ([notif.name isEqualToString:UIKeyboardWillShowNotification])
    {
        NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardEndFrame = [self.view convertRect:endFrameValue.CGRectValue fromView:nil];
        
        CGFloat offset = kScreenHeight - keyboardEndFrame.origin.y + 100;
        _subtitleView.y = offset;
    }
    
    else if ([notif.name isEqualToString:UIKeyboardWillHideNotification])
    {
        _subtitleView.y = kScreenHeight - 170;
    }
    
    // Create animation.
    void (^animations)() = ^() {
        [self.view layoutIfNeeded];
    };
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:^(BOOL f){
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - command methods

- (void)addSubtitleCommand:(QHVCEditStickerIconView *)sticker
{
    [_sticker.sticker setHidden:NO];
    [_sticker.subtitle setHidden:NO];
    UIImage *image = [QHVCEditPrefs convertViewToImage:sticker.sticker];
    [_sticker.sticker setHidden:YES];
    [_sticker.subtitle setHidden:YES];
    
    if (image && sticker)
    {
        CGRect rect = [self rectToOutputRect:sticker];
        QHVCEditCommandImageFilter* cmd = [[QHVCEditCommandManager manager] addImageFilter:image renderRect:rect radian:sticker.rotateAngle];
        [sticker setUserData:(__bridge void *)(cmd)];
    }
}

- (void)updateSubtitleCommand:(QHVCEditStickerIconView *)sticker
{
    QHVCEditCommandImageFilter* filter = (__bridge QHVCEditCommandImageFilter *)[sticker userData];
    if (sticker && filter)
    {
        CGRect rect = [self rectToOutputRect:sticker];
        [[QHVCEditCommandManager manager] updateImageFilter:filter renderRect:rect radian:sticker.rotateAngle];
    }
}

- (void)deleteSubtitleCommand:(QHVCEditStickerIconView *)sticker
{
    QHVCEditCommandImageFilter* filter = (__bridge QHVCEditCommandImageFilter *)[sticker userData];
    if (filter)
    {
        [[QHVCEditCommandManager manager] deleteImageFilter:filter];
    }
}

- (void)addFadeInOutAnimation:(QHVCEditStickerIconView *)sticker
{
    QHVCEditCommandImageFilter* filter = (__bridge QHVCEditCommandImageFilter *)[sticker userData];
    if (filter)
    {
        [[QHVCEditCommandManager manager] addImageFadeInOut:filter];
    }
}

- (void)addMoveInOutAnimation:(QHVCEditStickerIconView *)sticker
{
    QHVCEditCommandImageFilter* filter = (__bridge QHVCEditCommandImageFilter *)[sticker userData];
    if (filter)
    {
        [[QHVCEditCommandManager manager] addImageMoveInOut:filter];
    }
}

- (void)addJumpInOutAnimation:(QHVCEditStickerIconView *)sticker
{
    QHVCEditCommandImageFilter* filter = (__bridge QHVCEditCommandImageFilter *)[sticker userData];
    if (filter)
    {
        [[QHVCEditCommandManager manager] addImageJumpInOut:filter];
    }
}

- (void)addRotateInOutAnimation:(QHVCEditStickerIconView *)sticker
{
    QHVCEditCommandImageFilter* filter = (__bridge QHVCEditCommandImageFilter *)[sticker userData];
    if (filter)
    {
        [[QHVCEditCommandManager manager] addImageRotateInOut:filter];
    }
}

//view尺寸转为画布尺寸
- (CGRect)rectToOutputRect:(QHVCEditStickerIconView *)view
{
    CGRect rect = view.frame;
    CGFloat radian = view.rotateAngle;
    view.transform = CGAffineTransformRotate(view.transform, -radian);
    rect = CGRectMake(rect.origin.x + view.sticker.frame.origin.x,
                      rect.origin.y + view.sticker.frame.origin.y,
                      view.sticker.frame.size.width,
                      view.sticker.frame.size.height);
    view.transform = CGAffineTransformRotate(view.transform, radian);
    
    CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
    CGFloat scaleW = outputSize.width/CGRectGetWidth(_preview.frame);
    CGFloat scaleH = outputSize.height/CGRectGetHeight(_preview.frame);
    
    CGFloat x = rect.origin.x * scaleW;
    CGFloat y = rect.origin.y * scaleH;
    CGFloat w = rect.size.width * scaleW;
    CGFloat h = rect.size.height * scaleH;
    
    CGRect newRect = CGRectMake(x, y, w, h);
    return newRect;
}

@end
