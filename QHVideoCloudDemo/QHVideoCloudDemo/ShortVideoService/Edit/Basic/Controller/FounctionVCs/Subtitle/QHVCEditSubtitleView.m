//
//  QHVCEditSubtitleView.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/1/19.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditSubtitleView.h"
#import "QHVCEditFrameCell.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditSubtitleItemView.h"
#import "QHVCEditSubtitleTimelineView.h"
#import "QHVCEditMainContentView.h"

typedef NS_ENUM(NSInteger, QHVCEditSubtitleStatus)
{
    QHVCEditSubtitleStatusStyle = 1,
    QHVCEditSubtitleStatusColor,
    QHVCEditSubtitleStatusFont
};

#define kStylesName @"edit_subtitle_style"
#define kStylesCnt 6
#define kStyleCellWidth 43.0
#define kStyleCellHeight 43.0
#define kColorCellWidth 43.0
#define kColorCellHeight 43.0

static NSString * const frameCellIdentifier = @"QHVCEditFrameCell";
static NSString * const colorCellIdentifier = @"QHVCEditFrameCell";

@interface QHVCEditSubtitleView()
{
    __weak IBOutlet UICollectionView *_collectionView;
    __weak IBOutlet UIView *_fontView;
    __weak IBOutlet UIButton *_styleBtn;
    __weak IBOutlet UIButton *_colorBtn;
    __weak IBOutlet UIButton *_fontBtn;
    __weak IBOutlet UILabel *_currentSliderText;
    __weak IBOutlet UITextField *_inputTextField;
    QHVCEditSubtitleStatus _subtitleStatus;
}

@property (weak, nonatomic) IBOutlet UIView *subtitleView;
@property (weak, nonatomic) IBOutlet UIView *thumbnailView;

@property (nonatomic, strong) NSArray *colorsArray;
@property (nonatomic, retain) QHVCEditSubtitleTimelineView* thumbnailContentView;
@property (nonatomic, retain) QHVCEditSubtitleItemView* currentSubtitleItemView;

@end

@implementation QHVCEditSubtitleView

#pragma mark - Life Circle Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_collectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:colorCellIdentifier bundle:nil] forCellWithReuseIdentifier:colorCellIdentifier];
    _subtitleStatus = QHVCEditSubtitleStatusStyle;
    _colorsArray = @[@[@"edit_color_black",@"000000"],
                     @[@"edit_color_blue",@"125FDF"],
                     @[@"edit_color_gray",@"888888"],
                     @[@"edit_color_green",@"25B727"],
                     @[@"edit_color_pink",@"FE8AB1"],
                     @[@"edit_color_red",@"F54343"],
                     @[@"edit_color_white",@"FFFFFF"],
                     @[@"edit_color_yellow",@"FFDB4F"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSubtitleItemNotify:) name:QHVCEDIT_DEFINE_NOTIFY_SHOW_SUBTITLE_FUNCTION object:nil];
}

- (void)prepareSubviews
{
    [super prepareSubviews];
    
    [self.subtitleView setHidden:YES];
    [self.thumbnailView setHidden:NO];
    self.thumbnailContentView = [[NSBundle mainBundle] loadNibNamed:@"QHVCEditSubtitleTimelineView" owner:self options:nil][0];
    [self.thumbnailContentView setPlayerBaseVC:self.playerBaseVC];
    [self.thumbnailView addSubview:self.thumbnailContentView];
    
    SAFE_BLOCK(self.pausePlayerBlock);
    SAFE_BLOCK(self.hidePlayButtonBolck, YES);
    SAFE_BLOCK(self.seekPlayerBlock, YES, 0);
    
    WEAK_SELF
    [self.thumbnailContentView setAddAction:^{
        STRONG_SELF
        [self addSubtitle];
        [self showSubtitleView];
    }];
}

- (void)showSubtitleView
{
    [self.subtitleView setHidden:NO];
    [self.thumbnailView setHidden:YES];
    [self setConfirmButtonState:YES];
}

- (void)confirmAction
{
    SAFE_BLOCK(self.hidePlayButtonBolck, NO);
    SAFE_BLOCK(self.confirmBlock, self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subtitle Action Methods

- (void)addSubtitle
{
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",kStylesName, @(0)]];
    if (image)
    {
        QHVCEditSubtitleItemView* subtitleItemView = [self.playerContentView addSubtitle:image];
        [subtitleItemView setImageIndex:0];
        [subtitleItemView setColorIndex:0];
        self.currentSubtitleItemView = subtitleItemView;
    }
}

- (IBAction)clickedEditSubtitleCompleteBtn:(id)sender
{
    self.currentSubtitleItemView = nil;
    [_inputTextField setText:@""];
    [self.subtitleView setHidden:YES];
    [self.thumbnailView setHidden:NO];
    [self setConfirmButtonState:NO];
}

- (IBAction)clickedEditSubtitleParam:(UIButton *)sender
{
    if (sender.tag == _subtitleStatus)
    {
        return;
    }
    
    _subtitleStatus = sender.tag;
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle)
    {
        [_styleBtn setImage:[UIImage imageNamed:@"edit_subtitle_style_h"] forState:UIControlStateNormal];
        [_styleBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
        
        [_colorBtn setImage:[UIImage imageNamed:@"edit_subtitle_color"] forState:UIControlStateNormal];
        [_colorBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_fontBtn setImage:[UIImage imageNamed:@"edit_subtitle_font"] forState:UIControlStateNormal];
        [_fontBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_collectionView reloadData];
        _collectionView.hidden = NO;
        _fontView.hidden = YES;
    }
    else if(_subtitleStatus == QHVCEditSubtitleStatusColor)
    {
        [_styleBtn setImage:[UIImage imageNamed:@"edit_subtitle_style"] forState:UIControlStateNormal];
        [_styleBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_colorBtn setImage:[UIImage imageNamed:@"edit_subtitle_color_h"] forState:UIControlStateNormal];
        [_colorBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
        
        [_fontBtn setImage:[UIImage imageNamed:@"edit_subtitle_font"] forState:UIControlStateNormal];
        [_fontBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_collectionView reloadData];
        _collectionView.hidden = NO;
        _fontView.hidden = YES;
    }
    else if (_subtitleStatus == QHVCEditSubtitleStatusFont)
    {
        [_styleBtn setImage:[UIImage imageNamed:@"edit_subtitle_style"] forState:UIControlStateNormal];
        [_styleBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_colorBtn setImage:[UIImage imageNamed:@"edit_subtitle_color"] forState:UIControlStateNormal];
        [_colorBtn setTitleColor:[QHVCEditPrefs colorNormal] forState:UIControlStateNormal];
        
        [_fontBtn setImage:[UIImage imageNamed:@"edit_subtitle_font_h"] forState:UIControlStateNormal];
        [_fontBtn setTitleColor:[QHVCEditPrefs colorHighlight] forState:UIControlStateNormal];
        
        _collectionView.hidden = YES;
        _fontView.hidden = NO;
    }
}

- (IBAction)onFontSliderValueChanged:(UISlider *)sender
{
    _currentSliderText.text = [NSString stringWithFormat:@"%0.f",sender.value];
    [self.currentSubtitleItemView.textView setFont:[UIFont systemFontOfSize:sender.value]];
    [self.currentSubtitleItemView updateEffect];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textFieldDidChanged:(UITextField *)sender
{
    [self.currentSubtitleItemView.textView setText:sender.text];
    [self textViewContentSizeToFit:self.currentSubtitleItemView.textView];
    [self.currentSubtitleItemView updateEffect];
}

- (void)textViewContentSizeToFit:(UITextView *)textView
{
    if([textView.text length] > 0)
    {
        CGSize contentSize = textView.contentSize;
        UIEdgeInsets offset;
        CGFloat offsetY = (textView.frame.size.height - contentSize.height)/2;
        offset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
        [textView setContentInset:offset];
    }
}

#pragma mark - Subtitle Collection Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle)
    {
        return kStylesCnt;
    }
    else if(_subtitleStatus == QHVCEditSubtitleStatusColor)
    {
        return _colorsArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle)
    {
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
        [cell updateCell:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",kStylesName,@(indexPath.row)]]
       highlightViewType:(self.currentSubtitleItemView.imageIndex == indexPath.row) ? QHVCEditFrameHighlightViewTypeSquare : QHVCEditFrameHighlightViewTypeNone];
        [cell setImageFillMode:UIViewContentModeScaleAspectFit];
        return cell;
    }
    else if (_subtitleStatus == QHVCEditSubtitleStatusColor)
    {
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:colorCellIdentifier forIndexPath:indexPath];
        [cell updateCell:[UIImage imageNamed:_colorsArray[indexPath.row][0]]
       highlightViewType:(self.currentSubtitleItemView.colorIndex == indexPath.row) ? QHVCEditFrameHighlightViewTypeSquare : QHVCEditFrameHighlightViewTypeNone];
        [cell setImageFillMode:UIViewContentModeScaleAspectFill];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle)
    {
        return CGSizeMake(kStyleCellWidth, kStyleCellHeight);
    }
    return CGSizeMake(kColorCellWidth,kColorCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle)
    {
        return 20;
    }
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle)
    {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",kStylesName, @(indexPath.row)]];
        if (image)
        {
            [self.currentSubtitleItemView setImageIndex:indexPath.row];
            [self.currentSubtitleItemView setImage:image];
            [self.currentSubtitleItemView updateEffect];
        }
    }
    else if (_subtitleStatus == QHVCEditSubtitleStatusColor)
    {
        NSString* hexColor = _colorsArray[indexPath.row][1];
        UIColor* color = [QHVCEditPrefs colorHex:hexColor];
        [self.currentSubtitleItemView setColorIndex:indexPath.row];
        [self.currentSubtitleItemView.textView setTextColor:color];
        [self.currentSubtitleItemView updateEffect];
    }
    
    [_collectionView reloadData];
}

#pragma mark - Sticker Notification

- (void)onSubtitleItemNotify:(NSNotification *)notification
{
    QHVCEditSubtitleItemView* item = notification.object;
    self.currentSubtitleItemView = item;
    [_inputTextField setText:self.currentSubtitleItemView.textView.text];
    [_collectionView reloadData];
    [self showSubtitleView];
}


@end
