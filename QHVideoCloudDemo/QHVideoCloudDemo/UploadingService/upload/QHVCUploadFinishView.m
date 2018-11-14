//
//  QHVCUploadFinishView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/9/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCUploadFinishView.h"

@interface QHVCUploadFinishView()
{
    IBOutlet UIImageView *_finishImageView;
    IBOutlet UILabel *_finishLabel;
}
@end

@implementation QHVCUploadFinishView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateFinish:(BOOL)status
{
    if (status == NO) {
        _finishImageView.image = [UIImage imageNamed:@"upload_fail"];
        _finishLabel.text = @"上传失败";
    }
}

- (IBAction)close:(UIButton *)sender
{
    [self removeFromSuperview];
}

@end
