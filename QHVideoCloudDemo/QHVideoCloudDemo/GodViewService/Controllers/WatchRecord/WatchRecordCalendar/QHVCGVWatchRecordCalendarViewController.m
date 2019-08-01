//
//  QHVCGVWatchRecordCalendarViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2018/10/9.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCGVWatchRecordCalendarViewController.h"
#import "QHVCGVLunarFormatterObject.h"
#import "QHVCTool.h"
#import "QHVCGlobalConfig.h"
#import "QHVCLogger.h"

#define kQHVCGVWatchRecordCalendarVC_DatePicker_W               (150 * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordCalendarVC_DatePicker_H               (200 * kQHVCScreenScaleTo6)
#define kQHVCGVWatchRecordCalendarVC_DatePicker_MarginBottom    (kQHVCPhoneFringeHeight +  30 * kQHVCScreenScaleTo6)


@interface QHVCGVWatchRecordCalendarViewController ()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>

@property(nonatomic, strong) QHVCGVWatchRecordViewController* watchRecordViewController;
@property(nonatomic, strong) NSMutableArray<NSDictionary *>* timelineArray;
@property(nonatomic, strong) NSString* currentSelectDay;
@property(nonatomic, assign) NSUInteger currentSeekTime;

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *FSCalendarHoursView;

@property (assign, nonatomic) NSInteger      theme;
@property (assign, nonatomic) BOOL           lunar;

@property (strong, nonatomic) NSArray<NSString *> *datesShouldNotBeSelected;
@property (strong, nonatomic) NSMutableArray<NSString *> *datesWithEvent;

@property (strong, nonatomic) NSCalendar *gregorianCalendar;

@property (strong, nonatomic) NSDateFormatter *dateFormatter1;
@property (strong, nonatomic) NSDateFormatter *dateFormatter2;
@property (strong, nonatomic) QHVCGVLunarFormatterObject *lunarFormatter;

@property (nonatomic,strong) UIDatePicker *datePicker;

@end

@implementation QHVCGVWatchRecordCalendarViewController

- (instancetype)initWithTimeline:(QHVCGVWatchRecordViewController *)watchRecordController
{
    self = [super init];
    self.watchRecordViewController = watchRecordController;
    self.timelineArray = watchRecordController.timelineArray;
    self.currentSelectDay = watchRecordController.currentSelectDay;
    self.currentSeekTime = watchRecordController.currentSeekTime;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackBarButton];
    self.navigationItem.title = @"选择日期时间";
    [self setupCalendar];
    [self setupDatePicker];
}

- (void)setupNaviBar {
    self.navigationItem.rightBarButtonItems = @[];
    
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
    btnConfirm.titleLabel.font = kQHVCFontPingFangSCMedium(16);
    [btnConfirm addTarget:self action:@selector(clickedChooseDateButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnConfirm.frame = CGRectMake(5, 0, 50, 20);
    
    [self setRightBarButtonView:btnConfirm];
}


#pragma mark - 初始化相关 -
- (void) setupCalendar
{
    self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSLocale *chinese = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
    
    self.dateFormatter1 = [[NSDateFormatter alloc] init];
    self.dateFormatter1.locale = chinese;
    self.dateFormatter1.dateFormat = @"yyyy/MM/dd";
    
    self.dateFormatter2 = [[NSDateFormatter alloc] init];
    self.dateFormatter2.locale = chinese;
    self.dateFormatter2.dateFormat = @"yyyy-MM-dd";
    
    self.calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesUpperCase;
    [self setupDatesWithEvent];
    self.lunarFormatter = [[QHVCGVLunarFormatterObject alloc] init];
    
    BOOL isExistData = NO;
    for (NSDictionary *dict in self.timelineArray) {
        if ([dict.allKeys.firstObject isEqualToString:_currentSelectDay]) {
            NSArray *data = dict[_currentSelectDay];
            if (data.count > 0) {
                isExistData = YES;
            }
        }
    }
    if (isExistData) {
        [self.calendar selectDate:[QHVCTool getDateByString:_currentSelectDay format:@"yyyy-MM-dd"] scrollToDate:YES];
    }
    
    self.calendar.accessibilityIdentifier = @"calendar";
}

- (void)setupDatePicker {
    self.datePicker = [UIDatePicker new];
    _datePicker.datePickerMode = UIDatePickerModeTime;
    [_datePicker addTarget:self action:@selector(datePickerValueChange:) forControlEvents:UIControlEventValueChanged];
    [_datePicker setDate:[NSDate dateWithTimeIntervalSince1970:self.currentSeekTime / 1000]];
    [self.view addSubview:_datePicker];
    [_datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(kQHVCGVWatchRecordCalendarVC_DatePicker_W));
        make.height.equalTo(@(kQHVCGVWatchRecordCalendarVC_DatePicker_H));
        make.bottom.equalTo(self.view).offset(-kQHVCGVWatchRecordCalendarVC_DatePicker_MarginBottom);
    }];
}

- (void) setupDatesWithEvent
{
    self.datesWithEvent = nil;
    if (_timelineArray == nil || _timelineArray.count == 0)
    {
        return;
    }
    _datesWithEvent = [NSMutableArray array];
    [_timelineArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * key = obj.allKeys[0];
        [_datesWithEvent addObject:key];
    }];
}


#pragma mark - 按键事件相关 -

- (void)datePickerValueChange:(UIDatePicker *)datePicker {
    // 得到datePicker选择的小时和分钟
    NSTimeInterval intervalPicked = [QHVCTool surplusIntervalThatDayFromUTCInterval:[datePicker.date timeIntervalSince1970] * 1000];
    
    // 当前选择日期的时间戳
    NSDate *currentSelectDayDate = [QHVCTool getDateByString:self.currentSelectDay format:@"yyyy-MM-dd"];
    NSTimeInterval interval = [currentSelectDayDate timeIntervalSince1970];
    
    // 将datePicker的小时和分 追加到选择的日期里
    self.currentSeekTime = (NSUInteger)(intervalPicked + interval) * 1000;
}

- (void)clickedChooseDateButton:(id)sender
{
    [self.watchRecordViewController selectRecordTime:self.currentSelectDay seekTime:self.currentSeekTime];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - FSCalendarDataSource

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    return [self.gregorianCalendar isDateInToday:date] ? @"今天" : nil;
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    if (!_lunar) {
        return nil;
    }
    return [self.lunarFormatter stringFromDate:date];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    if ([self.datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return 1;
    }
    return 0;
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    NSString* dateCalendar = [_datesWithEvent firstObject];
    if (dateCalendar == nil)
    {
        dateCalendar = @"2018-08-01";
    }
    return [self.dateFormatter1 dateFromString:dateCalendar];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    NSString* dateCalendar = [_datesWithEvent lastObject];
    if (dateCalendar == nil)
    {
        dateCalendar = @"2019-07-31";
    }
    return [self.dateFormatter1 dateFromString:dateCalendar];
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    BOOL shouldSelect = ![_datesShouldNotBeSelected containsObject:[self.dateFormatter1 stringFromDate:date]];
    if (!shouldSelect) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"FSCalendar" message:[NSString stringWithFormat:@"FSCalendar delegate forbid %@  to be selected",[self.dateFormatter1 stringFromDate:date]] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [QHVCLogger printLogger:QHVC_LOG_LEVEL_ERROR content:[NSString stringWithFormat:@"Should select date %@",[self.dateFormatter1 stringFromDate:date]]];
    }
    self.currentSelectDay = [QHVCTool getTimeStringByDate:date format:@"yyyy-MM-dd"];
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"did select date %@",[self.dateFormatter1 stringFromDate:date]]];
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    [QHVCLogger printLogger:QHVC_LOG_LEVEL_DEBUG content:[NSString stringWithFormat:@"did change to page %@",[self.dateFormatter1 stringFromDate:calendar.currentPage]]];
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleOffsetForDate:(NSDate *)date
{
    if ([self calendar:calendar subtitleForDate:date]) {
        return CGPointZero;
    }
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return CGPointMake(0, -2);
    }
    return CGPointZero;
}

- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventOffsetForDate:(NSDate *)date
{
    if ([self calendar:calendar subtitleForDate:date]) {
        return CGPointZero;
    }
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return CGPointMake(0, -10);
    }
    return CGPointZero;
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(nonnull NSDate *)date
{
    if ([self calendar:calendar subtitleForDate:date]) {
        return @[appearance.eventDefaultColor];
    }
    if ([_datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return @[[UIColor whiteColor]];
    }
    return nil;
}

#pragma mark - Private properties

- (void)setTheme:(NSInteger)theme
{
    if (_theme != theme) {
        _theme = theme;
        switch (theme) {
            case 0: {
                _calendar.appearance.weekdayTextColor = FSCalendarStandardTitleTextColor;
                _calendar.appearance.headerTitleColor = FSCalendarStandardTitleTextColor;
                _calendar.appearance.eventDefaultColor = FSCalendarStandardEventDotColor;
                _calendar.appearance.selectionColor = FSCalendarStandardSelectionColor;
                _calendar.appearance.headerDateFormat = @"MMMM yyyy";
                _calendar.appearance.todayColor = FSCalendarStandardTodayColor;
                _calendar.appearance.borderRadius = 1.0;
                _calendar.appearance.headerMinimumDissolvedAlpha = 0.2;
                break;
            }
            case 1: {
                _calendar.appearance.weekdayTextColor = [UIColor redColor];
                _calendar.appearance.headerTitleColor = [UIColor darkGrayColor];
                _calendar.appearance.eventDefaultColor = [UIColor greenColor];
                _calendar.appearance.selectionColor = [UIColor blueColor];
                _calendar.appearance.headerDateFormat = @"yyyy-MM";
                _calendar.appearance.todayColor = [UIColor redColor];
                _calendar.appearance.borderRadius = 1.0;
                _calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
                
                break;
            }
            case 2: {
                _calendar.appearance.weekdayTextColor = [UIColor redColor];
                _calendar.appearance.headerTitleColor = [UIColor redColor];
                _calendar.appearance.eventDefaultColor = [UIColor greenColor];
                _calendar.appearance.selectionColor = [UIColor blueColor];
                _calendar.appearance.headerDateFormat = @"yyyy/MM";
                _calendar.appearance.todayColor = [UIColor orangeColor];
                _calendar.appearance.borderRadius = 0;
                _calendar.appearance.headerMinimumDissolvedAlpha = 1.0;
                break;
            }
            default:
                break;
        }
        
    }
}

- (void)setLunar:(BOOL)lunar
{
    if (_lunar != lunar) {
        _lunar = lunar;
        [_calendar reloadData];
    }
}


@end
