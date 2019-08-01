//
//  QHVCEditFuctionBaseView.h
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/27.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

typedef void(^QHVCEditFunctionCancelBlock)(UIView* functionView);
typedef void(^QHVCEditFunctionConfirmBlock)(UIView* functionView);
typedef void(^QHVCEditFunctionRefreshPlayerBlock)(BOOL forceRefresh);
typedef void(^QHVCEditFunctionRefreshPlayerForBasicEffectParams)(void);
typedef void(^QHVCEditFunctionResetPlayerBlock)(void);
typedef void(^QHVCEditFunctionUpdatePlayerDuration)(void);
typedef void(^QHVCEditFunctionHidePlayButtonBlock)(BOOL hidden);
typedef void(^QHVCEditFunctionPlayPlayerBlock)(void);
typedef void(^QHVCEditFunctionPausePlayerBlock)(void);
typedef void(^QHVCEditFunctionSeekPlayerBlock)(BOOL forceRefresh, NSInteger seekToTime);

@class QHVCEditMainContentView;
@class QHVCEditPlayerBaseVC;
@interface QHVCEditFunctionBaseView : UIView

@property (nonatomic, retain) QHVCEditMainContentView* playerContentView;
@property (nonatomic,   copy) QHVCEditFunctionCancelBlock cancelBlock;
@property (nonatomic,   copy) QHVCEditFunctionConfirmBlock confirmBlock;
@property (nonatomic,   copy) QHVCEditFunctionRefreshPlayerBlock refreshPlayerBlock;
@property (nonatomic,   copy) QHVCEditFunctionRefreshPlayerForBasicEffectParams refreshForEffectBasicParamsBlock;
@property (nonatomic,   copy) QHVCEditFunctionResetPlayerBlock resetPlayerBlock;
@property (nonatomic,   copy) QHVCEditFunctionUpdatePlayerDuration updatePlayerDuraionBlock;
@property (nonatomic,   copy) QHVCEditFunctionHidePlayButtonBlock hidePlayButtonBolck;
@property (nonatomic,   copy) QHVCEditFunctionPlayPlayerBlock playPlayerBlock;
@property (nonatomic,   copy) QHVCEditFunctionPausePlayerBlock pausePlayerBlock;
@property (nonatomic,   copy) QHVCEditFunctionSeekPlayerBlock seekPlayerBlock;
@property (nonatomic, retain) QHVCEditPlayerBaseVC* playerBaseVC;

//override
- (void)confirmAction;
- (void)cancelAction;
- (void)prepareSubviews;
- (void)setConfirmButtonState:(BOOL)hidden;
- (void)setCancelButtonState:(BOOL)hidden;

@end
