//
//  QHVCLiveSettingCellOne.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/6/29.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCLiveSettingCellOne.h"

@interface QHVCLiveSettingCellOne()
{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UISegmentedControl *_segmentControl;
}

@property (nonatomic, strong) NSMutableDictionary *liveItem;

@end

@implementation QHVCLiveSettingCellOne

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell:(NSMutableDictionary *)item
{
    self.liveItem = item;
    
    _titleLabel.text = item[@"title"];
    
    NSArray *options = item[@"options"];
    
    NSInteger i = 0;
    [_segmentControl removeAllSegments];
    for (NSString *title in options) {
        [_segmentControl insertSegmentWithTitle:title atIndex:i animated:NO];
        i++;
    }
    NSString *index = item[@"index"];
    _segmentControl.selectedSegmentIndex = index.integerValue;
}

- (IBAction)segmentAction:(UISegmentedControl *)sender
{
    [self.liveItem setObject:@(sender.selectedSegmentIndex).stringValue forKey:@"index"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
