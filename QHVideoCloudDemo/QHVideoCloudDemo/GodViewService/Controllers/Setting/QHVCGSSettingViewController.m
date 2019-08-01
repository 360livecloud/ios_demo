//
//  QHVCGSSettingViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/4/18.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSSettingViewController.h"
#import "QHVCTool.h"
#import "QHVCGlobalConfig.h"
#import "QHVCGVConfig.h"
#import "QHVCLiveSettingCellOne.h"
#import "QHVCGVSettingCellStyleThree.h"
#import "QHVCToast.h"
#import "QHVCGVDefine.h"

static NSString *kQHVCGSSettingViewCellOneIdentifier   = @"QHVCLiveSettingCellOne";
static NSString *kQHVCGSSettingViewCellThreeIdentifier = @"QHVCGVSettingCellStyleThree";

@interface QHVCGSSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *generalTableView;
}

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *dataArray;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation QHVCGSSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [QHVCTool setStatusBarBackgroundColor:[QHVCGlobalConfig getStatusBarColor]];
    [self initData];
}

- (void)initData
{
    [[QHVCGVConfig sharedInstance] readUserSettings];
    self.dataArray = [NSMutableArray arrayWithArray:[QHVCGVConfig sharedInstance].userSettings];
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
    if (dic[@"options"])
    {
        QHVCLiveSettingCellOne *cell = [tableView dequeueReusableCellWithIdentifier:kQHVCGSSettingViewCellOneIdentifier];
        if (!cell)
        {
            [generalTableView registerNib:[UINib nibWithNibName:kQHVCGSSettingViewCellOneIdentifier
                                                         bundle:nil]
                    forCellReuseIdentifier:kQHVCGSSettingViewCellOneIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:kQHVCGSSettingViewCellOneIdentifier];
        }
        cell.selectedBackgroundView = [UIView new];
        [cell updateCell:dic];
        return cell;
    } else
    {
        QHVCGVSettingCellStyleThree *cell = [tableView dequeueReusableCellWithIdentifier:kQHVCGSSettingViewCellThreeIdentifier];
        if (!cell)
        {
            [generalTableView registerNib:[UINib nibWithNibName:kQHVCGSSettingViewCellThreeIdentifier
                                                         bundle:nil]
                   forCellReuseIdentifier:kQHVCGSSettingViewCellThreeIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:kQHVCGSSettingViewCellThreeIdentifier];
        }
        [cell updateCell:dic videoProfileIndex:[_dataArray[indexPath.section][@"index"] integerValue]];
        cell.selectedBackgroundView = [UIView new];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIAction

- (IBAction)clickedBack:(id)sender
{
    [[QHVCGVConfig sharedInstance] readUserSettings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reset:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定重置" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    WEAK_SELF_GODVIEW
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STRONG_SELF_GODVIEW
        [[QHVCGVConfig sharedInstance] resetUserSettings];
        [self initData];
        [generalTableView reloadData];
        [QHVCToast makeToast:@"重置成功！"];
    }];
    [alert addAction:confirm];
}

- (IBAction)save:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定保存" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancel];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[QHVCGVConfig sharedInstance] updateUserSettings:_dataArray];
        [QHVCToast makeToast:@"保存成功！"];
    }];
    [alert addAction:confirm];
}

@end
