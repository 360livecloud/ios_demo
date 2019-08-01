//
//  QHVCEditOverlayFunctionsView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/8/10.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayFunctionsView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMediaEditor.h"
#import "QHVCEditMediaEditorConfig.h"
#import "QHVCEditMainFunctionCell.h"
#import "QHVCEditOverlayFunctionManager.h"

#ifdef QHVCADVANCED
#import "QHVCEditOverlayFunctionManagerAdvanced.h"
#endif

static NSString* overlayFunctionCellIdentifier = @"QHVCEditOverlayFunctionCell";

@interface QHVCEditOverlayFunctionsView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak,   nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) QHVCEditOverlayFunctionManager* funcManager;
@property (nonatomic, retain) NSMutableArray* overlayFuncsArray;

#ifdef QHVCADVANCED
@property (nonatomic, retain) QHVCEditOverlayFunctionManagerAdvanced* funcManagerAdvanced;
#endif

@end

@implementation QHVCEditOverlayFunctionsView

- (void)confirmAction
{
    [self.clipItemView hideBorder:YES];
    SAFE_BLOCK(self.confirmBlock, self);
}

- (void)prepareSubviews
{
    [super prepareSubviews];
    [self.clipItemView hideBorder:NO];
    [self.collectionView registerNib:[UINib nibWithNibName:@"QHVCEditMainFunctionCell" bundle:nil] forCellWithReuseIdentifier:overlayFunctionCellIdentifier];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"QHVCEditOverlayFunctionList" ofType:@"plist"];
    NSArray* array = [NSArray arrayWithContentsOfFile:path];
    if ([array count] > 0)
    {
        self.overlayFuncsArray = [[NSMutableArray alloc] initWithArray:array];
    }
    
#ifdef QHVCADVANCED
    NSString* advancedPath = [[NSBundle mainBundle] pathForResource:@"QHVCEditOverlayFunctionList+Advanced" ofType:@"plist"];
    NSArray* advancedArray = [NSArray arrayWithContentsOfFile:advancedPath];
    if ([advancedArray count] > 0)
    {
        [self.overlayFuncsArray addObjectsFromArray:advancedArray];
    }
#endif
    
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.overlayFuncsArray count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    QHVCEditMainFunctionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:overlayFunctionCellIdentifier forIndexPath:indexPath];
    NSArray* item = self.overlayFuncsArray[indexPath.row];
    if (item.count > 1)
    {
        [cell updateCell:item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self overlayFunctionDidSelected:indexPath.row];
}

- (void)overlayFunctionDidSelected:(NSInteger)index
{
    SAFE_BLOCK(self.pausePlayerBlock);
    NSString* funcName = self.overlayFuncsArray[index][2];
    id obj = self.funcManager;
    
#ifdef QHVCADVANCED
    NSInteger funcLevel = [self.overlayFuncsArray[index][3] integerValue];
    if (funcLevel != 0)
    {
        obj = self.funcManagerAdvanced;
    }
#endif
    
    if ([funcName length] > 0)
    {
        SEL funcSelector = NSSelectorFromString(funcName);
        if ([obj respondsToSelector:funcSelector])
        {
            IMP imp = [obj methodForSelector:funcSelector];
            void (*func)(id, SEL) = (void *)imp;
            func(obj, funcSelector);
        }
    }
}

- (QHVCEditOverlayFunctionManager *)funcManager
{
    if (!_funcManager)
    {
        _funcManager = [[QHVCEditOverlayFunctionManager alloc] init];
        [_funcManager setItemView:self.clipItemView];
        [_funcManager setPlayerVC:self.playerBaseVC];
        [_funcManager setListView:self];
        
        WEAK_SELF
        [_funcManager setUpdatePlayerDuraionBlock:^{
            STRONG_SELF
            SAFE_BLOCK(self.updatePlayerDuraionBlock);
        }];
        
        [_funcManager setDeleteOverlayBlock:^{
            STRONG_SELF
            [self confirmAction];
        }];
    }
    
    return _funcManager;
}

#ifdef QHVCADVANCED

- (QHVCEditOverlayFunctionManagerAdvanced *)funcManagerAdvanced
{
    if (!_funcManagerAdvanced)
    {
        _funcManagerAdvanced = [[QHVCEditOverlayFunctionManagerAdvanced alloc] init];
        [_funcManagerAdvanced setItemView:self.clipItemView];
        [_funcManagerAdvanced setPlayerVC:self.playerBaseVC];
        [_funcManagerAdvanced setListView:self];
        
        WEAK_SELF
        [_funcManagerAdvanced setUpdatePlayerDuraionBlock:^{
            STRONG_SELF
            SAFE_BLOCK(self.updatePlayerDuraionBlock);
        }];
        
        [_funcManagerAdvanced setDeleteOverlayBlock:^{
            STRONG_SELF
            [self confirmAction];
        }];
    }
    
    return _funcManagerAdvanced;
}

#endif

@end
