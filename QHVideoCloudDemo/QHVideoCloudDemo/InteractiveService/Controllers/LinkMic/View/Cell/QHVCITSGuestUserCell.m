//
//  QHVCITSGuestUserCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/20.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSGuestUserCell.h"
#import "UIViewAdditions.h"
#import "QHVCITSConfig.h"
#import "QHVCITSDefine.h"

@interface QHVCITSGuestUserCell()
{
    IBOutlet UIImageView *_avatar;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UIButton *_kickoutBtn;
}
@property (nonatomic, strong) NSDictionary *userItem;

@end

@implementation QHVCITSGuestUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _avatar.layer.cornerRadius = _avatar.width/2;
}

- (void)updateCell:(NSDictionary *)dict
{
    self.userItem = dict;
    _titleLabel.text = dict[QHVCITS_KEY_USER_ID];
    
    if ([dict[QHVCITS_KEY_TALK_TYPE] integerValue] == QHVCITS_Talk_Type_Audio)
    {
        _avatar.image = [UIImage imageNamed:@"room_mic"];
        [_kickoutBtn setImage:[UIImage imageNamed:@"room_close"] forState:UIControlStateNormal];
    }
}

- (IBAction)guestBtnAction:(UIButton *)sender
{
    if (self.kickoutCompletion) {
        self.kickoutCompletion(self.userItem[QHVCITS_KEY_USER_ID]);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
