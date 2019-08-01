//
//  QHVCRecordViewController.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/10/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCRecordViewController.h"
#import "QHVCLiveMainCellOne.h"
#import "QHVCRecordSettingViewController.h"
#import "QHVCRecordPreviewVC.h"

static NSString *LiveMainCellOneCellIdenitifer = @"QHVCLiveMainCellOne";

@interface QHVCRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *generalTableView;
    NSMutableArray *_dataArray;
}
@end

@implementation QHVCRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString* path = [[NSBundle mainBundle] pathForResource:@"recordMain" ofType:@"plist"];
    _dataArray = [NSMutableArray arrayWithContentsOfFile:path];
}

#pragma mark Action
- (IBAction)clickedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)start:(UIButton *)sender
{
    QHVCRecordPreviewVC *vc = [[QHVCRecordPreviewVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)setting:(id)sender
{
    QHVCRecordSettingViewController *vc = [[QHVCRecordSettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = _dataArray[indexPath.row];
    
    QHVCLiveMainCellOne *cell = [tableView dequeueReusableCellWithIdentifier:LiveMainCellOneCellIdenitifer];
    if (!cell) {
        [generalTableView registerNib:[UINib nibWithNibName:LiveMainCellOneCellIdenitifer
                                                     bundle:nil]
               forCellReuseIdentifier:LiveMainCellOneCellIdenitifer];
        cell = [tableView dequeueReusableCellWithIdentifier:LiveMainCellOneCellIdenitifer];
    }
    [cell updateCell:dic encryptProcesString:nil];
    return cell;
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
