//
//  QHVCEditTrackClipCell.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditTrackClipCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditTrackClipItem.h"

#define kTransferStyle @"edit_transfer_"

@interface QHVCEditTrackClipCell()
{
    __weak IBOutlet UIImageView *_thumbImageView;
    __weak IBOutlet UILabel *_beginLabel;
    __weak IBOutlet UILabel *_endLabel;
    __weak IBOutlet UIButton *_transferBtn;
}
@property (nonatomic, strong) QHVCEditTrackClipItem *segmentItem;

@end

@implementation QHVCEditTrackClipCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateCell:(QHVCEditTrackClipItem *)item canAddTransfer:(BOOL)canAddTransfer
{
    self.segmentItem = item;
    
    _thumbImageView.image = item.thumbnail;
    _beginLabel.text = [QHVCEditPrefs timeFormatMs:item.startMs];
    _endLabel.text = [QHVCEditPrefs timeFormatMs:item.endMs];
    [_transferBtn setHidden:!canAddTransfer];
    
    if (item.hasTransition)
    {
        NSString* imageName = [NSString stringWithFormat:@"edit_transfer_transition"];
        [_transferBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    else
    {
        [_transferBtn setImage:[UIImage imageNamed:@"edit_transfer_transition_none"] forState:UIControlStateNormal];
    }
}

- (IBAction)transferBtnAction:(UIButton *)sender
{
    if (self.selectedCompletion) {
        self.selectedCompletion(self.segmentItem);
    }
}

@end
