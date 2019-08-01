//
//  QHVCITSLinkMicViewController+Hongpa.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/4/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSLinkMicViewController+Hongpa.h"
#import "UIViewAdditions.h"
#import "QHVCGlobalConfig.h"
#import "QHVCITSHongpaCell.h"

static NSString * const hongpaCellIdentifier = @"QHVCITSHongpaCell";

@implementation QHVCITSLinkMicViewController(Hongpa)

#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self fetchCellSize].height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil(self.videoSessionArray.count/2.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCITSHongpaCell *cell = [tableView dequeueReusableCellWithIdentifier:hongpaCellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:hongpaCellIdentifier
                                                      bundle:nil]
                forCellReuseIdentifier:hongpaCellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:hongpaCellIdentifier];
    }
    NSRange range = NSMakeRange(indexPath.row * 2, MIN(2, ([self.videoSessionArray count]) - indexPath.row * 2));
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [cell updateCell:[self.videoSessionArray objectsAtIndexes:indexSet]];
    return cell;
}

- (CGSize)fetchCellSize
{
    CGFloat w = kScreenWidth/2;
    return CGSizeMake(w, 1.2*w);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
