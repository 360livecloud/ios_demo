//
//  QHVCITSModelListViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/4/2.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSModelListViewController.h"
#import "QHVCITSSettingViewController.h"
#import "QHVCConfig.h"
#import "QHVCITSRoomListViewController.h"
#import "QHVCITSUserSystem.h"

static NSString *functionCellIdentifier = @"functionCellIdentifier";

@interface QHVCITSModelListViewController ()
{
    IBOutlet UILabel *_userIdLabel;
    IBOutlet UITableView *_generalTableView;
    
    NSArray<NSDictionary *> *_functionArray;
}
@end

@implementation QHVCITSModelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"QHVCITLFunction" ofType:@"plist"];
    _functionArray = [NSMutableArray arrayWithContentsOfFile:path];
    
    _userIdLabel.text = [QHVCITSUserSystem sharedInstance].userInfo.userId;
}

#pragma mark Action
- (IBAction)clickedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 60)];
    titleLabel.text = @"互动直播模式";
    titleLabel.font = [UIFont systemFontOfSize:16.0];
    [view addSubview:titleLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _functionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:functionCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:functionCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    }
    cell.textLabel.text = _functionArray[indexPath.row][@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    QHVCITSRoomListViewController *vc = [[QHVCITSRoomListViewController alloc] init];
    vc.roomType = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
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
