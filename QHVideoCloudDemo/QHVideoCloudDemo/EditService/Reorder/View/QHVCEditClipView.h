//
//  QHVCEditClipView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/2.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCEditPhotoItem;

typedef void(^ChangeAction)(BOOL);

@interface QHVCEditClipView : UIView

@property (nonatomic,copy) ChangeAction changeCompletion;

- (void)updateUI:(QHVCEditPhotoItem *)item;

@end
