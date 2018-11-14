//
//  QHVCEditVC.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/4/18.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditVC.h"
#import "UIView+Toast.h"
#import "QHVCEditViewController.h"
#import "QHVCEditReorderViewController.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import <QHVCCommonKit/QHVCToolStringUtils.h>

@interface QHVCEditVC () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@end

@implementation QHVCEditVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nextBtn setHidden:YES];
    [self.urlTextField setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)nextAction:(UIButton *)sender
{
    if ([QHVCToolUtils isNullString:self.urlTextField.text])
    {
        QHVCEditViewController* vc  = [[QHVCEditViewController alloc]initWithNibName:@"QHVCEditViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        QHVCEditFileInfo* fileInfo = [QHVCEditGetFileInfo getFileInfo:self.urlTextField.text];
        if (fileInfo)
        {
            QHVCEditPhotoItem* item = [[QHVCEditPhotoItem alloc] init];
            item.filePath = self.urlTextField.text;
            item.durationMs = fileInfo.durationMs;
            item.startMs = 0;
            item.endMs = item.durationMs;
            NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:0];
            [array addObject:item];
            
            QHVCEditReorderViewController *vc = [[QHVCEditReorderViewController alloc] init];
            vc.resourceArray = array;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [self.view makeToast:@"请求URL文件信息失败"];
        }
    }
}



@end
