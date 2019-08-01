//
//  QHVCEditSubtitleItemView.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2018/11/25.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCEditGestureView.h"
#import "QHVCEditMediaEditor.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^QHVCEditSubtitleItemRefreshPlayerForBasicParamBlock)(void);
typedef void(^QHVCEditSubtitleItemRefreshPlayerBlock)(BOOL forceRefresh);

@interface QHVCEditSubtitleItemView : QHVCEditGestureView

- (void)setImage:(UIImage *)image;
- (void)updateEffect;

@property (nonatomic,   copy) QHVCEditSubtitleItemRefreshPlayerForBasicParamBlock refreshPlayerForBasicParamBlock;
@property (nonatomic,   copy) QHVCEditSubtitleItemRefreshPlayerBlock refreshPlayerBlock;
@property (nonatomic, retain) QHVCEditStickerEffect* effect;

@property (nonatomic, retain) UITextView* textView;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) NSInteger colorIndex;

@end

NS_ASSUME_NONNULL_END
