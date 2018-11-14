//
//  QHVCEditTailorViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTailorViewController.h"
#import "QHVCEditTailorMainView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditTailorRateVC.h"
#import "QHVCEditTailorFormatView.h"
#import "QHVCEditMatrixItem.h"

@interface QHVCEditTailorViewController ()<UIPopoverPresentationControllerDelegate>
{
    QHVCEditTailorMainView *_tailorMainView;
    QHVCEditTailorFormatView *_formatView;
    NSArray<NSString *> *_fillsArray;
    NSArray<NSArray *> *_colorsArray;
    
    NSInteger _fillIndex;
    NSInteger _colorIndex;
//    CGFloat _matrixRotateAngle;
//    BOOL _matrixFlipX;
//    BOOL _matrixFlipY;
    CGSize _outputSize;
    QHVCEditMatrixItem* _preMatrixItem;
    QHVCEditMatrixItem* _matrixItem;
}
@end

@implementation QHVCEditTailorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"剪裁";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    _fillIndex = [QHVCEditPrefs sharedPrefs].fillIndex;
    _colorIndex = [QHVCEditPrefs sharedPrefs].colorIndex;
    _outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"overlayCommandId=%@",@(kMainTrackId)];
    NSArray<QHVCEditMatrixItem *> *items = [[QHVCEditPrefs sharedPrefs].matrixItems filteredArrayUsingPredicate:predicate];
    if ([items count] > 0)
    {
        _matrixItem = items[0];
    }
    else
    {
        _matrixItem = [[QHVCEditMatrixItem alloc] init];
        _matrixItem.overlayCommandId = 0;
        [[QHVCEditCommandManager manager] addMatrix:_matrixItem];
        [[QHVCEditPrefs sharedPrefs].matrixItems addObject:_matrixItem];
    }
    _preMatrixItem = [_matrixItem copy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createTailorView];
}

- (void)createTailorView
{
    _tailorMainView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditTailorMainView class] description] owner:self options:nil][0];
    _tailorMainView.frame = CGRectMake(0, kScreenHeight - 100, kScreenWidth, 100);
    __weak typeof(self) weakSelf = self;
    _tailorMainView.selectedCompletion = ^(QHVCEditTailorType type) {
        [weakSelf tailorAction:type];
    };
    [self.view addSubview:_tailorMainView];
}

- (void)createFormatView
{
    if (_formatView) {
        [_formatView removeFromSuperview];
        _formatView = nil;
        self.titleLabel.text = @"剪裁";
        return;
    }
    _formatView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditTailorFormatView class] description] owner:self options:nil][0];
    _formatView.frame = CGRectMake(0, kScreenHeight - 140, kScreenWidth, 140);
    __weak typeof(self) weakSelf = self;
    _formatView.fillSelectedCompletion = ^(NSInteger index) {
        [weakSelf handleFillMode:index];
    };
    _formatView.colorSelectedCompletion = ^(NSInteger index) {
        [weakSelf handleColorMode:index];
    };
    [self initFormatDatas];
    [_formatView updateView:_fillsArray colors:_colorsArray];
    [self.view addSubview:_formatView];
    self.titleLabel.text = @"格式类型";
}

- (void)initFormatDatas
{
    if (_fillsArray&&_colorsArray) {
        return;
    }
    _fillsArray = @[@"黑边填充",@"裁剪填充",@"变形填充"];
    _colorsArray = @[@[@"edit_color_blur",@"blur"],@[@"edit_color_black",@"000000"],@[@"edit_color_blue",@"125FDF"],
                     @[@"edit_color_gray",@"888888"],@[@"edit_color_green",@"25B727"],@[@"edit_color_pink",@"FE8AB1"],
                     @[@"edit_color_red",@"F54343"],@[@"edit_color_white",@"FFFFFF"],@[@"edit_color_yellow",@"FFDB4F"]];
}

- (void)tailorAction:(QHVCEditTailorType)actionType
{
    if (actionType == QHVCEditTailorTypeRotate) {
        _matrixItem.frameRadian += M_PI_2;
        if (_matrixItem.frameRadian == 2*M_PI)
        {
            _matrixItem.frameRadian = 0;
        }
        [[QHVCEditCommandManager manager] updateMatrix:_matrixItem];
        [self refreshPlayer];
    }
    else if (actionType == QHVCEditTailorTypeFlipUpDown)
    {
        _matrixItem.flipY = !_matrixItem.flipY;
        [[QHVCEditCommandManager manager] updateMatrix:_matrixItem];
        [self refreshPlayer];
    }
    else if (actionType == QHVCEditTailorTypeFormat)
    {
        [self createFormatView];
        _sliderViewBottom.constant = 70;
    }
    else if (actionType == QHVCEditTailorTypeFilpLeftRight)
    {
        _matrixItem.flipX = !_matrixItem.flipX;
        [[QHVCEditCommandManager manager] updateMatrix:_matrixItem];
        [self refreshPlayer];
    }
    else if (actionType == QHVCEditTailorTypeRate)
    {
        QHVCEditTailorRateVC *rateVC = [[QHVCEditTailorRateVC alloc] init];
        rateVC.modalPresentationStyle = UIModalPresentationPopover;
        rateVC.popoverPresentationController.sourceView = _tailorMainView;
        rateVC.popoverPresentationController.sourceRect = _tailorMainView.bounds;
        rateVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        rateVC.popoverPresentationController.delegate = self;
        rateVC.preferredContentSize = CGSizeMake(150, 70);
        rateVC.popoverPresentationController.backgroundColor = [UIColor blackColor];
        __weak typeof(self) weakSelf = self;
        rateVC.selectedCompletion = ^(QHVCEditRateType type) {
            [weakSelf handleRate:type];
        };
        [self presentViewController:rateVC animated:YES completion:nil];
    }
    else if (actionType == QHVCEditTailorTypeRestore)
    {
        [self handleRestore];
    }
}

- (void)handleRate:(QHVCEditRateType)type
{
    CGFloat w = kScreenWidth;
    CGFloat h = kScreenHeight;
    
    if (type == QHVCEditRateTypeOneOne) {
        w = MIN(kScreenWidth, kScreenHeight);
        h = w;
    }
    else if (type == QHVCEditRateTypeFourThree)
    {
        w = kScreenWidth;
        h = 3*kScreenWidth/4;
    }
    [QHVCEditPrefs sharedPrefs].outputSize = CGSizeMake(w, h);
    [[QHVCEditCommandManager manager] updateOutputSize:[QHVCEditPrefs sharedPrefs].outputSize];
    [self refreshPlayer];
}

- (void)handleFillMode:(NSInteger)index
{
    [QHVCEditPrefs sharedPrefs].fillIndex = index;
    [[QHVCEditCommandManager manager] updateOutputRenderMode:index];
    [self refreshPlayer];
}

- (void)handleColorMode:(NSInteger)index
{
    [QHVCEditPrefs sharedPrefs].colorIndex = index;
    [[QHVCEditCommandManager manager] updateOutputBackgroudMode:_colorsArray[index][1]];
    [self refreshPlayer];
}

- (void)handleRestore
{    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"overlayCommandId=%@",@(kMainTrackId)];
    NSArray<QHVCEditMatrixItem *> *items = [[QHVCEditPrefs sharedPrefs].matrixItems filteredArrayUsingPredicate:predicate];
    if ([items count] > 0)
    {
        _matrixItem = [_preMatrixItem copy];
    }
    [[QHVCEditCommandManager manager] updateMatrix:_matrixItem];
    if (_outputSize.width != [QHVCEditPrefs sharedPrefs].outputSize.width||
        _outputSize.height != [QHVCEditPrefs sharedPrefs].outputSize.height)
    {
        [QHVCEditPrefs sharedPrefs].outputSize = _outputSize;
        [[QHVCEditCommandManager manager] updateOutputSize:[QHVCEditPrefs sharedPrefs].outputSize];
        [self refreshPlayer];
    }
}

- (void)nextAction:(UIButton *)btn
{
    if(_formatView)
    {
        [_formatView removeFromSuperview];
        _formatView = nil;
        self.titleLabel.text = @"剪裁";
        _sliderViewBottom.constant = 10;
        _fillIndex = [QHVCEditPrefs sharedPrefs].fillIndex;
        _colorIndex = [QHVCEditPrefs sharedPrefs].colorIndex;
    }
    else
    {
        if (self.confirmCompletion) {
            self.confirmCompletion(QHVCEditPlayerStatusRefresh);
        }
        [self releasePlayerVC];
    }
}

- (void)backAction:(UIButton *)btn
{
    if(_formatView)
    {
        [_formatView removeFromSuperview];
        _formatView = nil;
        self.titleLabel.text = @"剪裁";
        _sliderViewBottom.constant = 10;
        [QHVCEditPrefs sharedPrefs].fillIndex = _fillIndex;
        [QHVCEditPrefs sharedPrefs].colorIndex = _colorIndex;
    }
    else
    {
        [self handleRestore];
        [self releasePlayerVC];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
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
