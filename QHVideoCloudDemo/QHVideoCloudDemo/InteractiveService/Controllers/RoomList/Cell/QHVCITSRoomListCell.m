//
//  QHVCITSRoomListCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/16.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSRoomListCell.h"

@interface QHVCITSRoomListCell ()
{
    IBOutlet UILabel *_roomName;
    IBOutlet UILabel *_roomId;
    IBOutlet UILabel *_onlineCnt;
}
@end

@implementation QHVCITSRoomListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//"bindRoleId" : "100168",
//                                                 "createTime" : "2018-03-16 09:59:46",
//                                                 "num" : "1",
//                                                 "roomId" : "261",
//                                                 "roomName" : "aa",
//                                                 "roomType" : "2"
- (void)updateCell:(NSDictionary *)item
{
    _roomName.text = [NSString stringWithFormat:@"房间名：%@",item[@"roomName"]];
    _roomId.text = [NSString stringWithFormat:@"房间ID：%@",item[@"roomId"]];
    _onlineCnt.text = item[@"num"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
