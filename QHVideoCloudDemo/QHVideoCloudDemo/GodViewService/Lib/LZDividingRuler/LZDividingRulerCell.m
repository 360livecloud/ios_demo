//
//  LZDividingRulerCell.m
//  LZDividingRuler
//
//  Created by liuzhixiong on 2018/9/3.
//  Copyright © 2018年 liuzhixiong. All rights reserved.
//

#import "LZDividingRulerCell.h"
#import "Masonry.h"
#import "UIColor+HexColor.h"

@interface LZDividingRulerCell ()

@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UILabel*titleLabel;

@property (nonatomic,strong)UIColor   * scaleTextColor;
@property (nonatomic,strong)UIFont    * scaleTextFont;
@property (nonatomic,assign)CGFloat     textLargeLineSpace;
@property (nonatomic,copy)  NSString  * showText;
@property (nonatomic,strong)UIView    * inPointView;
@property (nonatomic, strong) UIImageView *bgColorView;

@end

@implementation LZDividingRulerCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.lineView = [[UIView alloc]init];
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.contentView);
    }];
    
    self.inPointView = [[UIView alloc]init];
    [self.contentView addSubview:self.inPointView];
    [self.inPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.lineView.mas_top).offset(-10);
        make.width.height.equalTo(@6);
        make.centerX.equalTo(self.lineView.mas_centerX);
    }];
    
    self.bgColorView = [UIImageView new];
    self.backgroundView = self.bgColorView;
}

-(void)setModel:(LZDividingRulerModel *)model{
    [self.lineView setBackgroundColor:model.isLargeLine?model.largeLineColor:model.smallLineColor];
    CGFloat lineWidth  = model.isLargeLine?model.lineWidth:model.lineWidth;
    CGFloat lineHeight = model.isLargeLine?model.largeLineHeight:model.smallLineHeight;
//    CGFloat bottomOffset = model.isLargeLine?5:(model.largeLineHeight-model.smallLineHeight)/2+5;
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).offset(-35);
        make.leading.equalTo(self.contentView);
        make.width.equalTo(@(lineWidth));
        make.height.equalTo(@(lineHeight));
    }];
}


-(void)updateCellWithText:(NSString *)showText font:(UIFont *)font textColor:(UIColor *)textColor textLargeLineSpace:(CGFloat)space isSelected:(BOOL)isSelected{
    
    self.showText = showText;
    self.scaleTextFont = font;
    self.scaleTextColor = textColor;
    self.textLargeLineSpace = space;
    
    NSDictionary *attributes  = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGSize showTextSize = [showText sizeWithAttributes:attributes];
    
    if (showText || ![showText isEqualToString:@""]) {
        [self.titleLabel setHidden:NO];
        [self.titleLabel setText:showText];
    }else{
        [self.titleLabel setHidden:YES];
    }
    
    [self.titleLabel setTextColor:textColor];
    [self.titleLabel setFont:font];
    
    if (isSelected) {
        [self.titleLabel setTextColor:[UIColor colorWithHexString:@"#5D5D5D"alpha:1]];
    }else{
        [self.titleLabel setTextColor:self.scaleTextColor];
    }
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-11);
        make.width.equalTo(@(showTextSize.width+2));
        make.height.equalTo(@(showTextSize.height));
        make.centerX.equalTo(self.lineView.mas_centerX);
    }];
}

-(void)updateCellinPointColor:(UIColor *)color pointWH:(CGFloat)wh largeSpace:(CGFloat)space isShow:(BOOL)isShow{
    [self.inPointView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(wh));
        make.centerX.equalTo(self.lineView.mas_centerX);
        make.bottom.equalTo(self.lineView.mas_top).offset(-space);
    }];
    
    [self.inPointView setHidden:!isShow];
    [self.inPointView setBackgroundColor:color];
    [self.inPointView.layer setCornerRadius:wh/2];
    [self.inPointView.layer setMasksToBounds:YES];
}

- (void)updateColorBgWithRanges:(NSArray *)ranges {
    if (ranges == nil || ranges.count == 0) {
        self.bgColorView.image = nil;
        return;
    }
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (NSDictionary *time in ranges) {
        [self drawRectInContext:ctx position:[[time objectForKey:@"start"] floatValue] length:[[time objectForKey:@"length"] floatValue]];
    }
    UIImage *imageToDraw = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [imageToDraw imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bgColorView.image = imageToDraw;
}


- (void)drawRectInContext:(CGContextRef)ctx position:(CGFloat)position length:(CGFloat)length {
    CGRect rect = CGRectMake(position, 0, length, self.bounds.size.height - 38);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithHexString:@"4AAAFD" alpha:1].CGColor);
    CGContextFillRect(ctx, rect);
}


@end
