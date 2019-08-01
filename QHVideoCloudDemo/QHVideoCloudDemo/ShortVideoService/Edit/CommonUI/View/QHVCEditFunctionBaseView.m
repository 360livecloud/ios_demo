//
//  QHVCEditFuctionBaseView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/6/27.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditFunctionBaseView.h"
#import "QHVCEditMainContentView.h"
#import "QHVCEditPrefs.h"

@interface QHVCEditFunctionBaseView ()
{
    BOOL _alreadyLayoutSubviews;
}

@property (nonatomic, strong) UIButton* confirmBtn;
@property (nonatomic, strong) UIButton* cancelBtn;

@end

@implementation QHVCEditFunctionBaseView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 50, 0, 50, 30)];
    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn setTintColor:[UIColor whiteColor]];
    [_confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirmBtn];
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn setTintColor:[UIColor whiteColor]];
    [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_cancelBtn setHidden:YES];
    [self addSubview:_cancelBtn];
}

- (void)layoutSubviews
{
    if (!_alreadyLayoutSubviews)
    {
        [self prepareSubviews];
        _alreadyLayoutSubviews = YES;
    }
}

- (void)prepareSubviews
{
    //override
}

- (void)cancelAction
{
    //override
    SAFE_BLOCK(self.cancelBlock, self);
}

- (void)confirmAction
{
    //override
     SAFE_BLOCK(self.confirmBlock, self);
}

- (void)setConfirmButtonState:(BOOL)hidden
{
    [_confirmBtn setHidden:hidden];
}

- (void)setCancelButtonState:(BOOL)hidden
{
    [_cancelBtn setHidden:hidden];
}

@end
