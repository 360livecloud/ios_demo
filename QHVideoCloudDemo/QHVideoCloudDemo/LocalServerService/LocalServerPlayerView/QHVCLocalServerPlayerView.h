//
//  QHVCLocalServerPlayerView.h
//  QHVideoCloudToolSet
//
//  Created by niezhiqiang on 2017/9/18.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QHVCLocalServerPlayerView;
@class QHVCPlayer;

@protocol QHVCLocalServerPlayerViewDelegate <NSObject>

- (void)back;
- (void)fullScreen;
- (void)playPause:(QHVCLocalServerPlayerView *)view;
- (void)next;
- (void)previous;
- (void)download:(NSInteger)index;

@end

@interface QHVCLocalServerPlayerView : UIView

@property (nonatomic, weak) id<QHVCLocalServerPlayerViewDelegate>delegate;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIView *lspGLView;
@property (nonatomic, weak) QHVCPlayer *player;
@property (nonatomic, assign) BOOL isFullScreen;

- (instancetype)initWithSize:(CGSize)size;

- (void)currentStyle;
- (void)unCurrentStyle;
- (void)play;
- (void)stop;
- (void)finish;
- (void)beginBuffing;
- (void)bufferingUpdate :(int)progress;
- (void)bufferingComplete;
- (void)buffingSeekComplete;
- (void)updateplayProgress:(CGFloat)progress;
- (void)showNoNetwork;

- (void)setItemDetail:(NSDictionary *)item;
- (void)setPlayStatus:(NSString *)playing;


@end
