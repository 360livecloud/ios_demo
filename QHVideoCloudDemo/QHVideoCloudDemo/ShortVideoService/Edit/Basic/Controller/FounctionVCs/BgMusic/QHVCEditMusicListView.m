//
//  QHVCEditMusicListView.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2018/11/29.
//  Copyright © 2018 yangkui. All rights reserved.
//

#import "QHVCEditMusicListView.h"
#import "QHVCEditPrefs.h"

static NSString * const musicListCellIdentifier = @"QHVCEditMisicListCell";

@interface QHVCEditMusicListView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray* musicList;
@property (nonatomic, retain) NSString* musicName;

@end

@implementation QHVCEditMusicListView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:musicListCellIdentifier];
    self.musicList = @[@"--",
                       @"Forever.mp3",
                       @"Disco.mp3"];
}

- (IBAction)clickedConfirmButton:(UIButton *)sender
{
    SAFE_BLOCK(self.completeAction, self.musicName);
    [self removeFromSuperview];
}

#pragma mark - TableView Methods

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.musicList count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:musicListCellIdentifier];
    NSString* text = [self.musicList objectAtIndex:indexPath.row];
    [cell.textLabel setText:text];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* name = [self.musicList objectAtIndex:indexPath.row];
    self.musicName = name;
}

@end



