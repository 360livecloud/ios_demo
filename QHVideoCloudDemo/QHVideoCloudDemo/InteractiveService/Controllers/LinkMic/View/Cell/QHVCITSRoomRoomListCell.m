//
//  QHVCITSRoomRoomListCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/7/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSRoomRoomListCell.h"

@interface QHVCITSRoomRoomListCell()
{
    IBOutlet UILabel *_titleLabel;
}
@property (nonatomic, strong) NSDictionary *roomItem;

@end

@implementation QHVCITSRoomRoomListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSDictionary *)dict
{
    self.roomItem = dict;
    
    NSString *roomId = dict[@"roomId"];
    NSString *roomName = dict[@"roomName"];
    _titleLabel.text = [NSString stringWithFormat:@"房间id:%@-房间名称:%@",roomId,roomName];
}

- (IBAction)joinBtnAction:(id)sender
{
    if (self.joinCompletion) {
        self.joinCompletion(self.roomItem);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
