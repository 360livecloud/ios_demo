//
//  QHVCShortVideoToolTableCell.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/23.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCShortVideoToolTableCell.h"

@interface QHVCShortVideoToolTableCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation QHVCShortVideoToolTableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setCellTitle:(NSString *)title
{
    [self.titleLable setText:title];
}

- (void)setStateButtonTitle:(NSString *)title
{
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (IBAction)onButtonClicked:(id)sender
{
    if (self.stateChangedAction)
    {
        self.stateChangedAction();
    }
}

@end
