//
//  QHVCITSRoomRoomListView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/7/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSRoomRoomListView.h"
#import "QHVCITSRoomRoomListCell.h"
#import "QHVCITSDefine.h"
#import "QHVCITSUserSystem.h"

static NSString *roomListCellIdentifier = @"QHVCITSRoomRoomListCell";

@interface QHVCITSRoomRoomListView()
{
    IBOutlet UITableView *_generalTableView;
}

@property (nonatomic, strong) NSArray<NSDictionary *> *dataArray;

@end

@implementation QHVCITSRoomRoomListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)setUsersData:(NSArray<NSDictionary *> *)lists
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomId !=%@",[QHVCITSUserSystem sharedInstance].roomInfo.roomId];
    NSArray *noMatch = [lists filteredArrayUsingPredicate:predicate];
    self.dataArray = noMatch;
    [_generalTableView reloadData];
}

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
    NSDictionary *dic = _dataArray[indexPath.row];
    
    QHVCITSRoomRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:roomListCellIdentifier];
    if (!cell) {
        [_generalTableView registerNib:[UINib nibWithNibName:roomListCellIdentifier
                                                      bundle:nil]
                forCellReuseIdentifier:roomListCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:roomListCellIdentifier];
    }
    WEAK_SELF_LINKMIC
    cell.joinCompletion = ^(NSDictionary *info) {
        STRONG_SELF_LINKMIC
        if (self.joinCompletion)
        {
            self.joinCompletion(info);
        }
    };
    [cell updateCell:dic];
    return cell;
}

@end
