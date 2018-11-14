//
//  QHVCITSRoomUserListView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSRoomUserListView.h"
#import "QHVCITSDefine.h"

static NSString *guestUserCellIdentifier = @"QHVCITSGuestUserCell";

@interface QHVCITSRoomUserListView()
{
    IBOutlet UITableView *_generalTableView;
}
@property (nonatomic, strong) NSArray<NSDictionary *> *dataArray;

@end

@implementation QHVCITSRoomUserListView

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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTime" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    self.dataArray = [lists sortedArrayUsingDescriptors:sortDescriptors];
    
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
    
    QHVCITSGuestUserCell *cell = [tableView dequeueReusableCellWithIdentifier:guestUserCellIdentifier];
    if (!cell) {
        [_generalTableView registerNib:[UINib nibWithNibName:guestUserCellIdentifier
                                                      bundle:nil]
                forCellReuseIdentifier:guestUserCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:guestUserCellIdentifier];
    }
    WEAK_SELF_LINKMIC
    cell.kickoutCompletion = ^(NSString *guestId) {
        STRONG_SELF_LINKMIC
        if (self.kickoutCompletion)
        {
            self.kickoutCompletion(guestId);
        }
    };
    [cell updateCell:dic];
    return cell;
}

@end
