//
//  QHVCEditAuxFilterViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditAuxFilterViewController.h"
#import "QHVCEditAuxFilterView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"

@interface QHVCEditAuxFilterViewController ()
{
    NSArray<NSDictionary *> *_filters;
    QHVCEditAuxFilterView *_filterView;
    NSInteger _backupIndex;
}
@end

@implementation QHVCEditAuxFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"滤镜";
    [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    _backupIndex = [QHVCEditPrefs sharedPrefs].filterIndex;
    [self initFilters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self createFilterView];
}

- (void)initFilters
{
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"Fade.png" ofType:@""];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"F1.png" ofType:@""];
    _filters = @[@{@"type":@0,@"title":@"原图",@"color":@"00000000"},
                  @{@"type":@0,@"title":@"自然",@"color":@"4CFFC0A5"},
                  @{@"type":@0,@"title":@"清新",@"color":@"4CB3CBE8"},
                  @{@"type":@0,@"title":@"鲜艳",@"color":@"4CEF4C4C"},
                  @{@"type":@0,@"title":@"淡雅",@"color":@"4C7D93D8"},
                  @{@"type":@0,@"title":@"糖果",@"color":@"4CFFB9D2"},
                  @{@"type":@0,@"title":@"玫瑰",@"color":@"4CE05086"},
                  @{@"type":@0,@"title":@"洛丽塔",@"color":@"4CE29994"},
                  @{@"type":@0,@"title":@"日落",@"color":@"4CEF8401"},
                  @{@"type":@0,@"title":@"草原",@"color":@"4C8BBF9F"},
                  @{@"type":@0,@"title":@"珊瑚色",@"color":@"4C2BBACF"},
                  @{@"type":@0,@"title":@"粉嫩",@"color":@"4CFFB9D2"},
                  @{@"type":@0,@"title":@"都市",@"color":@"4C58DEE0"},
                  @{@"type":@0,@"title":@"新鲜",@"color":@"4C52CCBF"},
                  @{@"type":@0,@"title":@"海滨",@"color":@"4C2A84C8"},
                  @{@"type":@0,@"title":@"酒红",@"color":@"4C881212"},
                  @{@"type":@1,@"title":@"自定义",@"color":path}];
}

- (void)createFilterView
{
    _filterView = [[NSBundle mainBundle] loadNibNamed:[[QHVCEditAuxFilterView class] description] owner:self options:nil][0];
    _filterView.frame = CGRectMake(0, kScreenHeight - 80, kScreenWidth, 80);
    _filterView.filters = _filters;
    __weak typeof(self) weakSelf = self;
    _filterView.selectedCompletion = ^(NSDictionary *value)
    {
        [weakSelf addFilter:value];

        //播放器获取指定特效效果图临时测试入口
//        NSString* str1 = [[NSBundle mainBundle] pathForResource:@"Vista" ofType:@"png"];
//        NSString* str2 = [[NSBundle mainBundle] pathForResource:@"Retro" ofType:@"png"];
//        NSString* str3 = [[NSBundle mainBundle] pathForResource:@"Negative" ofType:@"png"];
//        NSString* str4 = [[NSBundle mainBundle] pathForResource:@"HighNoon" ofType:@"png"];
//
//        NSArray* arrs = @[str1,str2,str3,str4];
//
//        [_player generateCLUTFilterThumbnails:arrs toSize:CGSizeMake(100, 100) callback:^(NSArray<UIImage *>* thumbnails, NSArray<NSString *>* clutImagePaths)
//         {
//             NSLog(@"");
//         }];
    };
    [self.view addSubview:_filterView];
}

- (void)addFilter:(NSDictionary *)item
{
    [[QHVCEditCommandManager manager] addFilter:item];
}

- (void)nextAction:(UIButton *)btn
{
    if (_backupIndex != [QHVCEditPrefs sharedPrefs].filterIndex) {
        if (self.confirmCompletion) {
            self.confirmCompletion(QHVCEditPlayerStatusRefresh);
        }
    }
    [self releasePlayerVC];
}

- (void)backAction:(UIButton *)btn
{
    if (_backupIndex != [QHVCEditPrefs sharedPrefs].filterIndex) {
        [QHVCEditPrefs sharedPrefs].filterIndex = _backupIndex;
        [[QHVCEditCommandManager manager] addFilter:_filters[_backupIndex]];
    }
    [self releasePlayerVC];
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
