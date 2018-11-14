//
//  QHVCITSSettingViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/3/15.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSSettingViewController.h"
#import "QHVCLiveSettingCellOne.h"
#import "QHVCLiveSettingCellTwo.h"
#import "QHVCITSConfig.h"
#import "QHVCToast.h"
#import "QHVCSettingCellStyleThree.h"
#import "UIViewAdditions.h"

static NSString *SettingCellOneCellIdenitifer = @"QHVCLiveSettingCellOne";
static NSString *SettingCellStyleThreeIdenitifer = @"QHVCSettingCellStyleThree";

@interface QHVCITSSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *generalTableView;
    IBOutlet UIView *_pickerContainerView;
    IBOutlet UIPickerView *_pickerView;
    
    NSInteger _pickerRow;
}

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *dataArray;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation QHVCITSSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
}

- (void)initData
{
    _dataArray = [NSMutableArray arrayWithArray:[QHVCITSConfig sharedInstance].userSettings];
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, view.frame.size.height)];
    titleLabel.text = _dataArray[section][@"title"];
    titleLabel.font = [UIFont systemFontOfSize:17.0];
    titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    [view addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 115, 0, 100, view.frame.size.height)];
    subTitleLabel.text = _dataArray[section][@"subTitle"];
    subTitleLabel.font = [UIFont systemFontOfSize:12.0];
    subTitleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    subTitleLabel.textAlignment = NSTextAlignmentRight;
    [view addSubview:subTitleLabel];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *config = _dataArray[section][@"config"];
    return config.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *config = _dataArray[indexPath.section][@"config"];
    NSMutableDictionary *dic = config[indexPath.row];
    
    if (dic[@"options"]) {
        QHVCLiveSettingCellOne *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellOneCellIdenitifer];
        if (!cell) {
            [generalTableView registerNib:[UINib nibWithNibName:SettingCellOneCellIdenitifer
                                                         bundle:nil]
                   forCellReuseIdentifier:SettingCellOneCellIdenitifer];
            cell = [tableView dequeueReusableCellWithIdentifier:SettingCellOneCellIdenitifer];
        }
        [cell updateCell:dic];
        return cell;
    }
    else
    {
        QHVCSettingCellStyleThree *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellStyleThreeIdenitifer];
        if (!cell) {
            [generalTableView registerNib:[UINib nibWithNibName:SettingCellStyleThreeIdenitifer
                                                         bundle:nil]
                   forCellReuseIdentifier:SettingCellStyleThreeIdenitifer];
            cell = [tableView dequeueReusableCellWithIdentifier:SettingCellStyleThreeIdenitifer];
        }
        [cell updateCell:dic videoProfileIndex:[_dataArray[indexPath.section][@"index"] integerValue]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.section == 1||indexPath.section == 2)
    {
        self.currentIndexPath = indexPath;
        if(indexPath.row == 0)
        {
            [_pickerView reloadAllComponents];
            _pickerContainerView.hidden = NO;
        }
    }
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [QHVCITSConfig sharedInstance].videoProfiles.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0f;
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.width;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (!view){
        view = [[UIView alloc]init];
    }
    
    UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    text.textAlignment = NSTextAlignmentCenter;
    
    NSDictionary *dict = [[QHVCITSConfig sharedInstance].videoProfiles objectAtIndex:row];

    NSArray *config = _dataArray[_currentIndexPath.section][@"config"];
    NSMutableDictionary *item = config[_currentIndexPath.row];
    NSString *key = item[@"key"];
    text.text = dict[key];
    [view addSubview:text];
    return view;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _pickerRow = row;
}

#pragma mark Action

- (IBAction)clickedBack:(id)sender
{
    [[QHVCITSConfig sharedInstance] readUserSetting];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reset:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定重置" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf resetData];
        [weakSelf writeDataToFile];
        [generalTableView reloadData];
        [QHVCToast makeToast:@"重置成功！"];
    }];
    [alert addAction:confirm];
}

- (IBAction)save:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定保存" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf writeDataToFile];
        [QHVCToast makeToast:@"保存成功！"];
    }];
    [alert addAction:confirm];
}

- (IBAction)closePickerView:(id)sender
{
    _pickerContainerView.hidden = YES;
}

- (IBAction)confirmPickerView:(id)sender
{
    [_dataArray[_currentIndexPath.section] setValue:@(_pickerRow) forKey:@"index"];
    [self closePickerView:nil];
    [generalTableView reloadData];
}

- (void)writeDataToFile
{
    NSURL *path = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString* userSettingCachePath = [path.relativePath stringByAppendingString:QHVCITS_INTERACTIVE_USER_SETTING_SAVE_PATH];
    [_dataArray writeToFile:userSettingCachePath atomically:YES];
}

- (void)resetData
{
    NSString* path = [[NSBundle mainBundle] pathForResource:QHVCITS_INTERACTIVE_USER_SETTING_FILE ofType:@"plist"];
    _dataArray = [NSMutableArray arrayWithArray:[NSMutableArray arrayWithContentsOfFile:path]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
