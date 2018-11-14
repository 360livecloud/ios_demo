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
#import "QHVCEditSubtitleItem.h"

typedef NS_ENUM(NSInteger, QHVCEditSubtitleStatus) {
    QHVCEditSubtitleStatusStyle = 1,
    QHVCEditSubtitleStatusColor,
    QHVCEditSubtitleStatusFont
};

#define kStylesCnt 6

#define kStyleCellWidth 43.0
#define kStyleCellHeight 43.0

#define kColorCellWidth 53.0
#define kColorCellHeight 53.0

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
    NSInteger _styleIndex;
    NSInteger _colorIndex;
}
@end

@implementation QHVCEditSubtitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_collectionView registerNib:[UINib nibWithNibName:frameCellIdentifier bundle:nil] forCellWithReuseIdentifier:frameCellIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:colorCellIdentifier bundle:nil] forCellWithReuseIdentifier:colorCellIdentifier];
    
    _subtitleStatus = QHVCEditSubtitleStatusStyle;
    _styleIndex = -1;
    _colorIndex = 0;
}

- (void)resetView
{
    _styleIndex = -1;
    _colorIndex = 0;

    [_collectionView reloadData];
}

- (IBAction)subtitleAction:(UIButton *)sender
{
    if (sender.tag == _subtitleStatus) {
        return;
    }
    _subtitleStatus = sender.tag;
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle) {
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

- (IBAction)fontSliderAction:(UISlider *)sender
{
    _currentSliderText.text = [NSString stringWithFormat:@"%0.f",sender.value];
    if (self.subtitleItem.fontValue != _currentSliderText.text.integerValue) {
        self.subtitleItem.fontValue = _currentSliderText.text.integerValue;
        
        if (self.subtitleItem.styleIndex < 0) {
            return;
        }
        if (self.refreshCompletion) {
            self.refreshCompletion(self.subtitleItem);
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (![self.subtitleItem.subtitleText isEqualToString:textField.text]) {
        self.subtitleItem.subtitleText = textField.text;
        if (self.subtitleItem.styleIndex < 0) {
            return;
        }
        if (self.refreshCompletion) {
            self.refreshCompletion(self.subtitleItem);
        }
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle) {
        return kStylesCnt;
    }
    else if(_subtitleStatus == QHVCEditSubtitleStatusColor)
    {
        return _colorsArray.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle)
    {
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:frameCellIdentifier forIndexPath:indexPath];
        [cell updateCell:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@",kStylesName,@(indexPath.row)]] highlightViewType:(_styleIndex == indexPath.row)?QHVCEditFrameHighlightViewTypeSquare:QHVCEditFrameHighlightViewTypeNone];
        return cell;
    }
    else if (_subtitleStatus == QHVCEditSubtitleStatusColor)
    {
        QHVCEditFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:colorCellIdentifier forIndexPath:indexPath];
        [cell updateCell:[UIImage imageNamed:_colorsArray[indexPath.row][0]] highlightViewType:(_colorIndex == indexPath.row)?QHVCEditFrameHighlightViewTypeSquare:QHVCEditFrameHighlightViewTypeNone];
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle) {
        return CGSizeMake(kStyleCellWidth, kStyleCellHeight);
    }
    return CGSizeMake(kColorCellWidth,kColorCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle) {
        return 30;
    }
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_subtitleStatus == QHVCEditSubtitleStatusStyle) {
        if (_styleIndex == indexPath.row) {
            return;
        }
        _styleIndex = indexPath.row;
        self.subtitleItem.styleIndex = _styleIndex;
    }
    else if (_subtitleStatus == QHVCEditSubtitleStatusColor)
    {
        if (_colorIndex == indexPath.row) {
            return;
        }
        _colorIndex = indexPath.row;
        self.subtitleItem.colorIndex = _colorIndex;
    }
    if (self.refreshCompletion) {
        self.refreshCompletion(self.subtitleItem);
    }
    [_collectionView reloadData];
}

@end
