//
//  LZDividingRulerView.m
//  LZDividingRuler
//
//  Created by liuzhixiong on 2018/9/3.
//  Copyright © 2018年 liuzhixiong. All rights reserved.
//

#import "LZDividingRulerView.h"
#import "LZDividingRulerCell.h"
#import "UIColor+HexColor.h"
#import "Masonry.h"
#import "QHVCGVRulerTimeConfigFactory.h"
#import "QHVCGlobalConfig.h"

#define kLZDividingRulerView_IndicatorView_W            9.0f

@interface LZDividingRulerView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) UICollectionView *collectionView;
/**    中间浮标     */
@property(nonatomic,strong) UIImageView      *indicatorView;         //中间浮标
@property (nonatomic,strong) UIColor         *indicatorViewColor;
@property (nonatomic,assign) CGFloat         indicatorHeight;
@property (nonatomic,assign) CGFloat         indicatorWidth;
@property(nonatomic,strong) UIView           *bottomLineView;
@property(nonatomic,strong) CAGradientLayer  *leftGradientLayer;     //左阴影
@property(nonatomic,strong) CAGradientLayer  *rightGradientLayer;    //右阴影
@property(nonatomic,strong) NSMutableArray   *dataArray;             //刻度数据源
@property(nonatomic,strong) UILabel          *currentValueLabel;     //中间数值显示
@property(nonatomic,assign) CGFloat          selectedIndex;          //默认值位置
@property(nonatomic,assign) CGFloat          inPointIndex;           //归零球位置
@property(nonatomic,assign) CGFloat          totalScale;             //所有的刻度
@property(nonatomic,assign) BOOL             isDraging;              // 是否正在拖动
@property(nonatomic,assign) LZDividingRulerViewScorllDirection scrollDirection;  // 滚动方向
@property(nonatomic,assign) CGFloat          lastScrollOffset;       // 上一次滚动的偏移量，用于判断方向
@property(nonatomic,assign) BOOL            isNotFirstScrollEnd;       // 非第一次滚动结束
@property(nonatomic,assign) BOOL            isChangingContentOffset;
@end

#define kMaxValue        1000000123.123
#define kMaxScalesCount  10000001230
@implementation LZDividingRulerView


-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setConfigurations];
    }
    return self;
}

-(void)setConfigurations{
    
    _isScrollEnable = YES;
    _isShowBothEndsOfGradient = YES;
    _isShowCurrentValue = NO;
    _isShowScaleText = YES;
    _isShowInPoint = NO;
    _isShouldAdsorption = YES;
    _isShouldHighlightText = YES;
    _isShowIndicator = YES;
    _isShowBottomLine = NO;
    
    /**    刻度     */
    _lineSpace = 10;
    _lineWidth = 1;
    _largeLineHeight = 11;
    _largeLineColor = [UIColor colorWithHexString:@"#5D5D5D"alpha:1];
    _smallLineColor = [UIColor colorWithHexString:@"#BEBEBE" alpha:0.4];
    _smallLineHeight = 7;
    _scalesCountBetweenLargeLine = 5;
    _scalesCountBetweenScaleText = 5;
    
    /**   刻度显示文本  */
    _scaleTextColor= [UIColor colorWithHexString:@"#5D5D5D"alpha:1];
    _scaleTextFont = kQHVCFontPingFangSCMedium(10);
    _scaleTextLargeLineSpace = 15;
    
    /**    值     */
    _maxValue = kMaxValue;
    _minValue = 0;
    _unitValue = 1;
    _defaultValue = 50;
    
    /**    中间浮标     */
    _indicatorHeight = 30;
    _indicatorWidth = kLZDividingRulerView_IndicatorView_W;;
//    _indicatorViewColor = [UIColor colorWithHexString:@"#0087FF" alpha:1];
        _indicatorViewColor = [UIColor colorWithHexString:@"#4DA3FF" alpha:1];
    
    /**    底部横线     */
    _bottomLineColor = [UIColor colorWithHexString:@"BEBEBE" alpha:1];
    _bottomLineHeight = 0.5;
    
    /**    两侧渐变色     */
    _gradientLayerWidth = 22.5;
    /**    自定义刻度相关     */
    _customScalesCount = kMaxScalesCount;

    _defaultScale = 0;
    
    /**    归零点原球     */
    _inPointWH = 3;
    _inPointColor = [UIColor colorWithHexString:@"#FFFFFF" alpha:0.4];
    _inPointLargeLineSpace = 6.5;
    _inPointCurrentValue = 1;
    _inPointCurrentScale = 0;
}

- (void)setDefaultValue:(CGFloat)defaultValue {
    if (isnan(defaultValue)) {
        _defaultValue = 0;
        return;
    }
    _defaultValue = defaultValue;
}

- (void)setCurrentValue:(CGFloat)currentValue {
    if (self.isDraging) {
        return;
    }
    _currentValue = currentValue;
    _defaultValue = currentValue;
    self.selectedIndex = (currentValue-self.minValue)/self.unitValue  - 1.0 / self.timePrecision;
    CGFloat currentOffset = self.selectedIndex * (self.lineWidth + self.lineSpace)-self.collectionView.contentInset.left ;
    self.isChangingContentOffset = YES;
    [self.collectionView setContentOffset:CGPointMake(currentOffset, 0)];
    self.isChangingContentOffset = NO;
}

-(void)updateRuler{
    self.isNotFirstScrollEnd = NO;
    [self setupCollectionView];
    [self setupIndicatorView];
    [self setupCurrentValueLabel];
    [self setupBottomLineView];
    [self setupBothEndsOfGradientLayer];
    [self setupDataSource];
    [self setNeedsLayout];
}

-(void)setupCollectionView{
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, CGRectGetWidth(self.frame)/2-self.lineWidth/2, 0, CGRectGetWidth(self.frame)/2-self.lineWidth/2)];
    [self.collectionView setBounces:NO];
}

-(void)setupIndicatorView{
//    [self.indicatorView setBackgroundColor:self.indicatorViewColor];
    UIImage *image = kQHVCGetImageWithName(@"godview_rulerview_indicator");
    // 左端盖宽度
    NSInteger leftCapWidth = image.size.width * 0.5f;
    // 顶端盖高度
    NSInteger topCapHeight = image.size.height * 0.5f;
    self.indicatorView.image = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    [self.indicatorView setHidden:!self.isShowIndicator];
}

-(void)setupCurrentValueLabel{
    [self.currentValueLabel setTextAlignment:NSTextAlignmentCenter];
}

-(void)setupBottomLineView{
    [self.bottomLineView setBackgroundColor:self.bottomLineColor];
    [self.bottomLineView setHidden:!self.isShowBottomLine];
}

-(void)setupBothEndsOfGradientLayer{
    [self.leftGradientLayer setHidden:!self.isShowBothEndsOfGradient];
    [self.rightGradientLayer setHidden:!self.isShowBothEndsOfGradient];
}

-(void)setupDataSource{
    if ((self.maxValue <= self.minValue || self.unitValue == 0)) {
        NSAssert(NO, @"参数错误或者maxValue不能大于等于minuValue,each不能为0");
    }
    
    if (self.isShowInPoint && ((self.inPointCurrentValue >self.maxValue)||(self.inPointCurrentValue<self.minValue))) {
        NSAssert(NO, @"参数错误 inPointCurrentValue 不能大于最大值 不能小于最小值");
    }
    
    if (!self.scalesCountBetweenScaleText && self.isShowScaleText) {
        NSAssert(NO, @"参数错误 scalesCountBetweenScaleText不能为0");
    }
    
    if (self.maxValue == kMaxValue) {
        NSAssert(NO, @"参数错误 刻度尺数值递增 请设置maxValue，minValue，unitValue 来确定刻度数");
    }
    
    //生成刻度循环模型
    [self.dataArray removeAllObjects];
    for (int i = 0; i<self.scalesCountBetweenLargeLine; i++) {
        LZDividingRulerModel *model = [[LZDividingRulerModel alloc]init];
        model.lineWidth = self.lineWidth;
        model.largeLineHeight = self.largeLineHeight;
        model.smallLineHeight = self.smallLineHeight;
        model.largeLineColor = self.largeLineColor;
        model.smallLineColor = self.smallLineColor;
        model.isLargeLine = i==0;
        [self.dataArray addObject:model];
    }
    
    //设置默认值位置
    self.selectedIndex = (self.defaultValue-self.minValue)/self.unitValue;
    
    CGFloat defaultOffset = self.selectedIndex * (self.lineWidth + self.lineSpace)-self.collectionView.contentInset.left ;

    //计算所有刻度数
    self.totalScale = (self.maxValue-self.minValue)/self.unitValue;
    
    //设置计算圆球位置
    if (self.isShowInPoint){
        self.inPointIndex = (self.inPointCurrentValue - self.minValue)/self.unitValue;
    }
    
    [self.currentValueLabel setHidden:!self.isShowCurrentValue];
    
    //刷新collectionView
    [self.collectionView setContentOffset:CGPointMake(defaultOffset, 0) animated:NO];
    [self.collectionView setScrollEnabled:self.isScrollEnable];
    [self.currentValueLabel setTextColor:self.isScrollEnable?[UIColor colorWithHexString:@"#5D5D5D"alpha:1]:[UIColor colorWithHexString:@"#FFFFFF" alpha:0.4]];
    [self.collectionView reloadData];
    
    //此处是因为，设置contentOffset的是double类型，设置完后必然会走scrollDidScroll，然后又要走其中根据偏移量来计算index的方法。但是读取scrollView的contentOffset居然不保留小数位或者只保留一位小数位，精度大变，导致数据误差极大。故在此调用原偏移量进行重置。
  
    NSInteger seconds = (NSInteger)ceil(self.defaultValue * self.timePrecision);
    self.currentValueLabel.text = [self timeStringWithSeconds:seconds];
    if ([self.delegate respondsToSelector:@selector(rulerView:didScrollAtSeconds:)]) {
        [self.delegate rulerView:self didScrollAtSeconds:seconds];
    }
    
    if (self.isNotFirstScrollEnd && [self.delegate respondsToSelector:@selector(rulerView:didEndScrollingAtSeconds:direction:)]) {
        [self.delegate rulerView:self didEndScrollingAtSeconds:seconds direction:LZDividingRulerViewScorllDirectionRight];
    }
    self.isNotFirstScrollEnd = YES;

}

-(void)layoutSubviews{
    
    //中间标View位置
    CGFloat bottomOffset = (self.largeLineHeight - self.indicatorHeight)/2+5;
    [self.indicatorView setFrame:CGRectMake((CGRectGetWidth(self.frame)-self.indicatorWidth)/2, 0, self.indicatorWidth, self.bounds.size.height)];
    //中间显示数值Label位置
    [self.currentValueLabel setFrame:CGRectMake((CGRectGetWidth(self.frame)-80)/2, CGRectGetHeight(self.frame)-self.indicatorHeight-bottomOffset-6-15, 80, 15)];
    
    //底部横线
    [self.bottomLineView setFrame:CGRectMake(0, CGRectGetHeight(self.collectionView.bounds)-self.bottomLineHeight-35, self.totalScale * (self.lineSpace + self.lineWidth), self.bottomLineHeight)];
    
    //左右侧渐变阴影位置
    [self.leftGradientLayer setFrame:CGRectMake(0, 0, self.gradientLayerWidth, CGRectGetHeight(self.frame))];
    [self.rightGradientLayer setFrame:CGRectMake(CGRectGetWidth(self.frame)-self.gradientLayerWidth, 0, self.gradientLayerWidth, CGRectGetHeight(self.frame))];
}

#pragma marklargeLineColor; - CollectionViewDataSource && CollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count = fabs((self.maxValue-self.minValue)/self.unitValue);
    return count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LZDividingRulerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LZDividingRulerCell" forIndexPath:indexPath];
    LZDividingRulerModel *model = self.dataArray[indexPath.item % self.scalesCountBetweenLargeLine];
    cell.model = model;
    NSString *text;
    
    if (indexPath.item % self.scalesCountBetweenScaleText == 0) {
        text = [self timeStringWithSeconds:(NSInteger)ceil(indexPath.item *self.timePrecision)];
    }else{
        text = nil;
    }
    if (!self.isShowScaleText) {
        text = nil;
    }
    
    //更新cell中显示文本
    BOOL isCurrentTextHighlight = indexPath.item == self.selectedIndex?YES:NO;
    isCurrentTextHighlight = self.isShouldHighlightText?isCurrentTextHighlight:NO;
    [cell updateCellWithText:text font:self.scaleTextFont textColor:self.scaleTextColor textLargeLineSpace:self.scaleTextLargeLineSpace isSelected:isCurrentTextHighlight];
    
    //更新cell中显示归零球
    BOOL isShowInPoint = self.inPointIndex == indexPath.item;
    isShowInPoint = self.selectedIndex == self.inPointIndex?NO:isShowInPoint;
    isShowInPoint = self.isShowInPoint?isShowInPoint:NO;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [cell updateColorBgWithRanges:[self colorRangesWithIndexPath:indexPath]];
    [CATransaction commit];
    [cell updateCellinPointColor:self.inPointColor pointWH:self.inPointWH largeSpace:self.inPointLargeLineSpace isShow:isShowInPoint];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == (NSUInteger)self.maxValue) {
//        return CGSizeMake(self.lineWidth+0.5,CGRectGetHeight(self.bounds));
//    }
    return CGSizeMake(self.lineSpace + self.lineWidth,CGRectGetHeight(self.bounds));
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

#pragma mark - ScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.isDraging = NO;
    [self updateRulerLocation];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        self.isDraging = NO;
        [self updateRulerLocation];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDraging = YES;
    if ([self.delegate respondsToSelector:@selector(rulerViewWillBeginDragging)]) {
        [self.delegate rulerViewWillBeginDragging];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    [self updateRulerLocation];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat maxContentOffsetX = (self.lineWidth + self.lineSpace) * (self.maxValue - self.minValue) + self.lineWidth - self.collectionView.contentInset.left;
    if (scrollView.contentOffset.x > maxContentOffsetX) {
        [self.collectionView setContentOffset:CGPointMake(maxContentOffsetX, scrollView.contentOffset.y)];
        return;
    }
    
    self.scrollDirection = self.lastScrollOffset > scrollView.contentOffset.x ? LZDividingRulerViewScorllDirectionLeft : LZDividingRulerViewScorllDirectionRight;
    self.lastScrollOffset = scrollView.contentOffset.x;
    
    CGFloat maxOffset,minOffset;
    
    maxOffset = (self.maxValue-self.minValue)/self.unitValue*(self.lineSpace+self.lineWidth)-self.collectionView.contentInset.left;
    minOffset = -self.collectionView.contentInset.left;
    
    if (scrollView.contentOffset.x >= maxOffset || scrollView.contentOffset.x <= minOffset) {
        return;
    }
    
    CGFloat offset = self.collectionView.contentInset.left + self.collectionView.contentOffset.x;
    
    CGFloat count;
    if (self.isShouldAdsorption) {
        count = (NSInteger)(offset/(self.lineWidth+self.lineSpace)+0.5);
    }else{
        count = offset/(self.lineWidth+self.lineSpace);
    }
    
    NSInteger seconds = (NSInteger)ceil((self.minValue + count*self.unitValue) * self.timePrecision);
    self.currentValueLabel.text = [self timeStringWithSeconds:seconds];
    if (!self.isChangingContentOffset && [self.delegate respondsToSelector:@selector(rulerView:didScrollAtSeconds:)]) {
        [self.delegate rulerView:self didScrollAtSeconds:seconds];
    }
}

#pragma mark - private
- (NSArray *)colorRangesWithIndexPath:(NSIndexPath *)indexPath {
    // 计算index代表的时间区间
    CGFloat indexTimeStart = indexPath.row * self.timePrecision;
    CGFloat indexTimeEnd = (indexPath.row + 1) * self.timePrecision - 1;
    
    
    NSMutableArray *array = [NSMutableArray new];
    // 检测是否有视频落在这个时间上
    for (NSDictionary *time in self.times) {
        CGFloat start = [[time objectForKey:@"start"] floatValue];
        CGFloat duration = [[time objectForKey:@"duration"] floatValue];
        
        CGFloat leftDiff = start - indexTimeStart;
        CGFloat length = 0;
        if (start >= indexTimeStart && start < indexTimeEnd) {
            // 左边落在单元格时间区间
            
            if (start + duration <= indexTimeEnd) {
                // 右边也落在单元格内
                length = duration;
            }
            else {
                length = indexTimeEnd - start + 1;
            }
        }
        else if (start < indexTimeStart && start + duration > indexTimeStart) {
            leftDiff = 0;
            if (start + duration <= indexTimeEnd) {
                length = start + duration - indexTimeStart;
            }
            else {
                length = indexTimeEnd - indexTimeStart+1;
            }
        }
        if (length > 0) {
            CGFloat colorPosition = leftDiff / self.timePrecision * (self.lineSpace + self.lineWidth);
            CGFloat colorLength = length / self.timePrecision * (self.lineSpace + self.lineWidth);
            [array addObject:@{@"start":@(colorPosition),
                               @"length":@(colorLength)
                               }];
        }
    }
    return array;
}

-(void)updateRulerLocation{
    
    CGFloat offset = self.collectionView.contentInset.left + self.collectionView.contentOffset.x;
    
    CGFloat count;
    if (self.isShouldAdsorption) {
        count = (NSInteger)(offset/(self.lineWidth+self.lineSpace)+0.5);
    }else{
        count = offset/(self.lineWidth+self.lineSpace);
    }
    
    self.selectedIndex = count;
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(count * (self.lineWidth+self.lineSpace)-self.collectionView.contentInset.left, 0) animated:YES];
    
    NSInteger seconds = (NSInteger)ceil(self.minValue + count*self.unitValue * self.timePrecision);
    self.currentValueLabel.text = [self timeStringWithSeconds:seconds];
    if ([self.delegate respondsToSelector:@selector(rulerView:didEndScrollingAtSeconds:direction:)]) {
        [self.delegate rulerView:self didEndScrollingAtSeconds:seconds direction:self.scrollDirection];
    }
    
    if (self.isShouldAdsorption) {
        //震动反馈
        AudioServicesPlaySystemSound(1519);
    }
}

/**
 同步显示位置
 
 @param pointOffset CGPoint
 */
- (void)updateScrollerViewContentOffset:(CGPoint)pointOffset{
    [self.collectionView setContentOffset:pointOffset];
}


#pragma mark - Private
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_collectionView];
        [_collectionView setBackgroundColor:[UIColor colorWithHexString:@"F0F0F0" alpha:1]];
        [_collectionView registerClass:[LZDividingRulerCell class] forCellWithReuseIdentifier:@"LZDividingRulerCell"];
        //collectionView位置
        [_collectionView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    }
    return _collectionView;
}

-(UIImageView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIImageView alloc]init];
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

-(UILabel *)currentValueLabel{
    if (!_currentValueLabel) {
        _currentValueLabel = [[UILabel alloc]init];
        [_currentValueLabel setTextAlignment:NSTextAlignmentCenter];
        [_currentValueLabel setFont:[UIFont systemFontOfSize:13]];
        [_currentValueLabel setTextColor:[UIColor colorWithHexString:@"#5D5D5D"alpha:1]];
        [self addSubview:_currentValueLabel];
    }
    return _currentValueLabel;
}

-(UIView *)bottomLineView{
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc]init];
        [self.collectionView addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

-(CAGradientLayer *)leftGradientLayer{
    if (!_leftGradientLayer) {
        
        _leftGradientLayer = [CAGradientLayer layer];
        _leftGradientLayer.startPoint = CGPointMake(0, 0);
        _leftGradientLayer.endPoint = CGPointMake(1, 0);
        _leftGradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"#1D1D1F" alpha:0.9].CGColor,(__bridge id)[UIColor colorWithHexString:@"#1D1D1F" alpha:0].CGColor];
        [self.layer addSublayer:_leftGradientLayer];
    }
    return _leftGradientLayer;
}

-(CAGradientLayer *)rightGradientLayer{
    if (!_rightGradientLayer) {
        
        _rightGradientLayer = [CAGradientLayer layer];
        _rightGradientLayer.startPoint = CGPointMake(1, 0);
        _rightGradientLayer.endPoint = CGPointMake(0, 0);
        _rightGradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"#1D1D1F" alpha:0.9].CGColor,(__bridge id)[UIColor colorWithHexString:@"#1D1D1F" alpha:0].CGColor];
        [self.layer addSublayer:_rightGradientLayer];
    }
    return _rightGradientLayer;
}

/**
 * 将当天从00:00:00后的秒数 换算成时间格式显示出来
 */
- (NSString *)timeStringWithSeconds:(NSInteger)seconds {
    NSInteger hour = seconds / 60 / 60;
    NSInteger min = (seconds - hour * 60 * 60) / 60;
//    NSInteger second = seconds - hour * 60 * 60 - min * 60;
    NSString *timeString = [NSString stringWithFormat:@"%02zd:%02zd",hour,min];
    return timeString;
}

/**
 * 将utc时间戳进行截取，得到当天从00:00:00后的秒数
 */
- (NSTimeInterval)surplusIntervalFromUTCInterval:(NSTimeInterval)utcInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:utcInterval / 1000];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *dayString = [df stringFromDate:date];
    NSDate *date2 = [df dateFromString:dayString];
    NSTimeInterval interval = [date timeIntervalSinceDate:date2];
    return interval;
}


@end
