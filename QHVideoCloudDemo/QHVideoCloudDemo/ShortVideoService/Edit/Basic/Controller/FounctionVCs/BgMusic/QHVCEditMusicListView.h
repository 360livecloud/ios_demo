//
//  QHVCEditMusicListView.h
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2018/11/29.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QHVCEditMusicListSelectComplete)(NSString* fileName);

@interface QHVCEditMusicListView : UIView

@property (nonatomic,   copy) QHVCEditMusicListSelectComplete completeAction;

@end

NS_ASSUME_NONNULL_END
