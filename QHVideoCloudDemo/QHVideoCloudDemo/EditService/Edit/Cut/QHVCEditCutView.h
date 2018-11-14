//
//  QHVCEditCutView.h
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/2/5.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CutAction)(void);
typedef void(^CancelAction)(void);
typedef void(^DoneAction)(void);

@interface QHVCEditCutView : UIView

@property (nonatomic, weak) IBOutlet UIView *confirmView;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) CutAction cutCompletion;
@property (nonatomic, copy) CancelAction cancelCompletion;
@property (nonatomic, copy) DoneAction doneCompletion;

- (void)freshView;

@end
