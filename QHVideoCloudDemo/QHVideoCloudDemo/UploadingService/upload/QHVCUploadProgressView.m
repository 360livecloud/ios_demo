//
//  QHVCUploadProgressView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2017/9/28.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCUploadProgressView.h"

@interface QHVCUploadProgressView ()
{
    IBOutlet UIButton *_cancelBtn;
    IBOutlet UIProgressView *_progress;
    IBOutlet UILabel *_progressLabel;
    
}
@end
@implementation QHVCUploadProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)cancel:(UIButton *)sender
{
    if (_onCancelBlock) {
        _onCancelBlock();
    }
}

- (void)updateProgress:(float)progress
{
    _progress.progress = progress;
    _progressLabel.text = [NSString stringWithFormat:@"%0.f%%",progress*100];
}

@end
