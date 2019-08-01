//
//  QHVCGSCloudRecordFlowLayout.m
//  QHVideoCloudToolSet
//
//  Created by jiangbingbing on 2019/1/9.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCGSCloudRecordFlowLayout.h"
#import "QHVCGlobalConfig.h"

#define kQHVCGSCloudRecordFlowLayout_MarginHorz (14 * kQHVCScreenScaleTo6)
#define kQHVCGSCloudRecordFlowLayout_Padding    (7 * kQHVCScreenScaleTo6)
#define kQHVCGSCloudRecordFlowLayout_Cell_W     ([UIScreen mainScreen].bounds.size.width - kQHVCGSCloudRecordFlowLayout_MarginHorz*2 - kQHVCGSCloudRecordFlowLayout_Padding)/2
#define kQHVCGSCloudRecordFlowLayout_Cell_H     111

@implementation QHVCGSCloudRecordFlowLayout

- (void)prepareLayout
{
    [super  prepareLayout];
    self.itemSize = CGSizeMake(kQHVCGSCloudRecordFlowLayout_Cell_W, kQHVCGSCloudRecordFlowLayout_Cell_H);
    self.minimumLineSpacing = kQHVCGSCloudRecordFlowLayout_Padding;
    self.minimumInteritemSpacing = kQHVCGSCloudRecordFlowLayout_Padding;
    self.sectionInset = UIEdgeInsetsMake(0, kQHVCGSCloudRecordFlowLayout_MarginHorz, 0, kQHVCGSCloudRecordFlowLayout_MarginHorz);
}

@end
