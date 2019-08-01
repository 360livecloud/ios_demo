//
//  QHVCShortVideoVC.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/22.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCShortVideoVC.h"
#import "QHVCTabTableViewCell.h"
#import "QHVCEditVC.h"
#import "QHVCEditToolVC.h"
#import "QHVCRecordViewController.h"

static NSString *const itemCellIdentifier = @"QHVCShortVideoItemCell";

@interface QHVCShortVideoVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (nonatomic, retain) NSArray* dataSource;

@end

@implementation QHVCShortVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"短视频"];
    [self.nextBtn setHidden:YES];
    
    [self.tableViewTopConstraint setConstant:[self topBarHeight]];
    [_tableView registerClass: [QHVCTabTableViewCell class] forCellReuseIdentifier:itemCellIdentifier];
    _dataSource = @[
                    @{
                        @"leftImage":@"tab_videoEdit",
                        @"title":@"剪辑",
                        @"rightImage":@"jiantou"
                        },
                    @{
                        @"leftImage":@"tab_videoEdit",
                        @"title":@"工具",
                        @"rightImage":@"jiantou"
                        },
                    @{
                        @"leftImage":@"tab_videoEdit",
                        @"title":@"拍摄",
                        @"rightImage":@"jiantou"
                        }
                    ];
}

- (IBAction)onBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCTabTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCellIdentifier];
    [cell updateCellDetail:_dataSource[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController* vc = nil;
    if (indexPath.row == 0)
    {
        vc = [QHVCEditVC new];
    }
    else if (indexPath.row == 1)
    {
        vc = [QHVCEditToolVC new];
    }
    else if (indexPath.row == 2)
    {
        vc = [QHVCRecordViewController new];
    }

    [self.navigationController pushViewController:vc animated:YES];
}

@end
