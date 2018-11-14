//
//  QHVCPlayerServiceViewController.m
//  QHVideoCloudToolSet
//
//  Created by yangkui on 2017/6/16.
//  Copyright © 2017年 yangkui. All rights reserved.
//

#import "QHVCPlayerServiceViewController.h"
#import "QHVCGeneralPlayingViewController.h"
#import "QHVCLivePlayingViewController.h"

#define QHVC_COLOR_TEST_WHITE        [UIColor colorWithWhite:1 alpha:0.3]
#define QHVC_COLOR_CLICK_WHITE       [UIColor colorWithWhite:1 alpha:0.6]

@interface QHVCPlayerServiceViewController ()
{
    IBOutlet UIButton *backButton;
    IBOutlet UIImageView *logoImgView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIButton *liveButton;
    IBOutlet UIButton *playerButton;
}

@end

@implementation QHVCPlayerServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"playerbg"]];
    [self setButtonDetail];
}

- (void)setButtonDetail
{
    liveButton.layer.cornerRadius = 20;
    liveButton.layer.borderWidth = 1;
    liveButton.layer.borderColor = QHVC_COLOR_TEST_WHITE.CGColor;
    liveButton.clipsToBounds = YES;
    [liveButton setBackgroundImage:[self imageWithColor:QHVC_COLOR_CLICK_WHITE] forState:UIControlStateHighlighted];
    
    playerButton.layer.cornerRadius = 20;
    playerButton.layer.borderWidth = 1;
    playerButton.layer.borderColor = QHVC_COLOR_TEST_WHITE.CGColor;
    playerButton.clipsToBounds = YES;
    [playerButton setBackgroundImage:[self imageWithColor:QHVC_COLOR_CLICK_WHITE] forState:UIControlStateHighlighted];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)clickedBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickedLive:(id)sender
{
    QHVCLivePlayingViewController *lvc = [QHVCLivePlayingViewController new];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (IBAction)clickedPlayer:(id)sender
{
    QHVCGeneralPlayingViewController *gvc = [QHVCGeneralPlayingViewController new];
    [self.navigationController pushViewController:gvc animated:YES];
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

@end
