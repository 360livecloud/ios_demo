//
//  QHVCGSImageDownloadTableViewCell.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2019/5/6.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSImageDownloadTableViewCell.h"
#import <QHVCCommonKit/QHVCCommonKit.h>

@interface QHVCGSImageDownloadTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *downloadProgressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadUrlLabel;

@property (strong, nonatomic) QHVCGSImageDownloadModel *model;

@end


@implementation QHVCGSImageDownloadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_downloadProgressLabel setText:@"0%"];
    [_downloadProgressView setProgress:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)clickedDeleteTaskAction:(id)sender {
    if (_model) {
        [[_model downloadTask] cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            
        }];
    }
    if (self.deleteBlock) {
        self.deleteBlock(_model);
    }
}

- (void)updateCell:(QHVCGSImageDownloadModel *)model {
    _model = model;
    [_downloadUrlLabel setText:model.url];
    float currentSize = model.currentSize;
    float totalSize = model.totalSize;
    float process = _downloadProgressView.progress;
    if (totalSize > 0) {
        process = currentSize/totalSize;
    }
    [_downloadProgressLabel setText:[NSString stringWithFormat:@"%.2f%%",(process*100)]];
    [_downloadProgressView setProgress:process];
}
@end
