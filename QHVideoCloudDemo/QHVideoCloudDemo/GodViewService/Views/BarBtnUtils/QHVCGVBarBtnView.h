//
//  QHGBarButtonView.h
//  QHGroupUI
//
//  Created by wangdacheng on 2017/10/23.
//  Copyright © 2017年 北京奇虎科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QHVCGVBarButtonViewPosition) {
    QHVCGVBarButtonViewPositionLeft,
    QHVCGVBarButtonViewPositionRight
};

@interface QHVCGVBarBtnView : UIView

@property (nonatomic, assign) QHVCGVBarButtonViewPosition position;

@end
