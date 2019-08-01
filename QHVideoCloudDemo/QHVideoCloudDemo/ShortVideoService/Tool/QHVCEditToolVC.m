//
//  QHVCEditToolVC.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/22.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditToolVC.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import "QHVCTabTableViewCell.h"
#import "QHVCEditToolVC.h"
#import "QHVCShortVideoToolSelectPhotoAlbumVC.h"
#import "QHVCShortVideoMacroDefs.h"
#import "QHVCEditToolReverseVC.h"
#import "QHVCEditToolWebmVC.h"
#import "QHVCEditToolGifVC.h"
#import "QHVCShortVideoUtils.h"

static NSString *const itemCellIdentifier = @"QHVCShortVideoToolItemCell";

@interface QHVCEditToolVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray* dataSource;
@end

@implementation QHVCEditToolVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"工具"];
    [self.nextBtn setHidden:YES];
    [self.tableViewTopConstraint setConstant:[self topBarHeight]];
    [QHVCShortVideoUtils setAppInfo];
#ifdef DEBUG
    [QHVCEditConfig setSDKLogLevel:QHVCEditLogLevelDebug];
#endif
    
    [_tableView registerClass: [QHVCTabTableViewCell class] forCellReuseIdentifier:itemCellIdentifier];
    _dataSource = @[
                    @{
                        @"leftImage":@"tab_videoEdit",
                        @"title":@"webm合成",
                        @"rightImage":@"jiantou",
                        },
                    @{
                        @"leftImage":@"tab_videoEdit",
                        @"title":@"视频倒放",
                        @"rightImage":@"jiantou",
                        },
                    @{
                        @"leftImage":@"tab_videoEdit",
                        @"title":@"转gif动图",
                        @"rightImage":@"jiantou",
                        }
                    ];
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
    if (indexPath.row == 0)
    {
        //webm
        QHVCEditToolWebmVC* vc = [QHVCEditToolWebmVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1)
    {
        //倒放
        QHVCShortVideoToolSelectPhotoAlbumVC* albumVC = [QHVCShortVideoToolSelectPhotoAlbumVC new];
        [albumVC setMaxCount:1];
        [self.navigationController pushViewController:albumVC animated:YES];
        
        WEAK_SELF
        [albumVC setCompletion:^(NSArray<QHVCPhotoItem *> *items)
        {
            STRONG_SELF
            QHVCEditToolReverseVC* reverseVC = [[QHVCEditToolReverseVC alloc] initWithPhotoItem:items[0]];
            [self.navigationController pushViewController:reverseVC animated:YES];
        }];
    }
    else if (indexPath.row == 2)
    {
        //gif
        QHVCShortVideoToolSelectPhotoAlbumVC* albumVC = [QHVCShortVideoToolSelectPhotoAlbumVC new];
        [albumVC setMaxCount:1];
        [self.navigationController pushViewController:albumVC animated:YES];
        
        WEAK_SELF
        [albumVC setCompletion:^(NSArray<QHVCPhotoItem *> *items)
         {
             STRONG_SELF
             QHVCEditToolGifVC* gifVC = [[QHVCEditToolGifVC alloc] initWithPhotoItem:items[0]];
             [self.navigationController pushViewController:gifVC animated:YES];
         }];
    }
}

@end
