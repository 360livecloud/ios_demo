//
//  QHVCLiveMainCellTwo.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/6/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLiveMainCellTwo.h"

@interface QHVCLiveMainCellTwo()
{
    IBOutlet UILabel *_titleLabel;
}

@property (nonatomic, strong) NSMutableDictionary *liveItem;

@end

@implementation QHVCLiveMainCellTwo

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSMutableDictionary *)item
{
    self.liveItem = item;
    
    _titleLabel.text = item[@"title"];
}

- (IBAction)switchAction:(UISwitch *)sender
{
    if (sender.on) {
        [self.liveItem setObject:@"1" forKey:@"value"];
    }
    else
    {
        [self.liveItem setObject:@"0" forKey:@"value"];
    }
    if (_switchAction)
    {
        _switchAction(sender.isOn);
    }
    NSLog(@"main cell two %@",self.liveItem);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
