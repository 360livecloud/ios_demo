//
//  QHVCEditMosaicView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2018/12/28.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCEditMosaicView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMosaicItemView.h"
#import "QHVCEditMainContentView.h"

@interface QHVCEditMosaicView ()
@property (nonatomic, retain) QHVCEditMosaicItemView* mosaicItemView;

@end

@implementation QHVCEditMosaicView

- (void)prepareSubviews
{
    _mosaicItemView = [self.playerContentView addMosaic];
}

- (void)confirmAction
{
    SAFE_BLOCK(self.confirmBlock, self);
    [_mosaicItemView hideBorder:YES];
}

- (IBAction)onSliderValueChanged:(UISlider *)sender
{
    [_mosaicItemView updateIntensity:sender.value];
}


@end
