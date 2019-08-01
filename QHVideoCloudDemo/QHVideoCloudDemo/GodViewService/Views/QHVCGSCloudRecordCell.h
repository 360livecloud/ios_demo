//
//  QHVCGSCloudRecordCell.h
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/9.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class QHVCGSCloudRecordCell;

@protocol QHVCGSCloudRecordCellDelegate <NSObject>
@optional
/// 点击菜单上的删除按钮
- (void)cloudRecordCell:(QHVCGSCloudRecordCell *)cloudRecordCell didClickDeleteAtIndexPath:(NSIndexPath *)indexPath;
/// 点击菜单选项 显示菜单
- (void)cloudRecordCell:(QHVCGSCloudRecordCell *)cloudRecordCell didClickMenuIndexPath:(NSIndexPath *)indexPath;
@end


@interface QHVCGSCloudRecordCell : UICollectionViewCell
@property (nonatomic,weak) id<QHVCGSCloudRecordCellDelegate> delegate;

- (void)setupWithImageName:(NSString *)imageName indexPath:(NSIndexPath *)indexPath;
- (void)hideMenu;

@end

NS_ASSUME_NONNULL_END
