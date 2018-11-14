//
//  QHVCEditOverlayContentView.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/24.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayContentView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditMatrixItem.h"
#import "QHVCEditCommandManager.h"
#import "QHVCEditOverlayItemPreview.h"

#define kDefaultWidth 124
#define kDefaultHeight 165

@interface QHVCEditOverlayContentView()
@property (nonatomic, retain) NSMutableArray<QHVCEditMatrixItem *>* matrixItemArray;
@end

@implementation QHVCEditOverlayContentView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.matrixItemArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self drawOverlays];
}

- (void)drawOverlays
{
    QHVCEditOutputParams* outputParams = [[QHVCEditOutputParams alloc] init];
    outputParams.backgroundInfo = @"00000000";
    __block NSInteger zOrderIndex = 1; 
    
    [[QHVCEditPrefs sharedPrefs].matrixItems enumerateObjectsUsingBlock:^(QHVCEditMatrixItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if (obj.zOrder > zOrderIndex)
        {
            zOrderIndex = obj.zOrder;
        }
    }];
    
    //主文件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"overlayCommandId=%@",@(kMainTrackId)];
    NSArray<QHVCEditMatrixItem *> *items = [[QHVCEditPrefs sharedPrefs].matrixItems filteredArrayUsingPredicate:predicate];
    if ([items count] == 0)
    {
        CGRect rect = [self createRandomRect:CGSizeMake(kDefaultWidth, kDefaultHeight)];
        CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
        CGFloat scaleW = outputSize.width/CGRectGetWidth(self.frame);
        CGFloat scaleH = outputSize.height/CGRectGetHeight(self.frame);
        CGRect renderRect = CGRectMake(CGRectGetMinX(rect) * scaleW,
                                       CGRectGetMinY(rect) * scaleH,
                                       CGRectGetWidth(rect) * scaleW,
                                       CGRectGetHeight(rect) * scaleH);
        
        QHVCEditMatrixItem* matrixItem = [[QHVCEditMatrixItem alloc] init];
        matrixItem.overlayCommandId = kMainTrackId;
        matrixItem.renderRect = renderRect;
        matrixItem.preview = [[QHVCEditOverlayItemPreview alloc] initWithFrame:rect overlayCommandId:kMainTrackId];
        matrixItem.outputParams = outputParams;
        matrixItem.zOrder = zOrderIndex;
        zOrderIndex++;
        
        [[QHVCEditCommandManager manager] addMatrix:matrixItem];
        [[QHVCEditPrefs sharedPrefs].matrixItems addObject:matrixItem];
        [self.matrixItemArray addObject:matrixItem];
        
        WEAK_SELF
        __weak typeof(matrixItem) weakItem = matrixItem;
        [matrixItem.preview setTapAction:^{
            STRONG_SELF
            [self overlayTapped:weakItem];
        }];
        
        [matrixItem.preview setRotateGestureAction:^(BOOL isEnd)
        {
            STRONG_SELF
            weakItem.renderRect = [self rectToOutputRect:weakItem];
            weakItem.previewRadian = weakItem.preview.radian;
            [[QHVCEditCommandManager manager] updateMatrix:weakItem];
            SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
        }];
        
        [matrixItem.preview setMoveGestureAction:^(BOOL isEnd)
        {
            STRONG_SELF
            weakItem.renderRect = [self rectToOutputRect:weakItem];
            [[QHVCEditCommandManager manager] updateMatrix:weakItem];
            SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
        }];
        
        [matrixItem.preview setPinchGestureAction:^(BOOL isEnd)
        {
            STRONG_SELF
            weakItem.renderRect = [self rectToOutputRect:weakItem];
            [[QHVCEditCommandManager manager] updateMatrix:weakItem];
            SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
        }];
    }
    else
    {
        QHVCEditMatrixItem* matrixItem = items[0];
        if (!matrixItem.preview)
        {
            CGRect rect = CGRectZero;
            if (CGRectGetWidth(matrixItem.renderRect) == 0)
            {
                rect = [self createRandomRect:CGSizeMake(kDefaultWidth, kDefaultHeight)];
                CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
                CGFloat scaleW = outputSize.width/CGRectGetWidth(self.frame);
                CGFloat scaleH = outputSize.height/CGRectGetHeight(self.frame);
                CGRect renderRect = CGRectMake(CGRectGetMinX(rect) * scaleW,
                                               CGRectGetMinY(rect) * scaleH,
                                               CGRectGetWidth(rect) * scaleW,
                                               CGRectGetHeight(rect) * scaleH);
                
                matrixItem.renderRect = renderRect;
                matrixItem.outputParams = outputParams;
                matrixItem.zOrder = zOrderIndex;
                zOrderIndex++;
            }
            else
            {
                rect = [self rectToViewRect:matrixItem.renderRect];
            }
            matrixItem.preview = [[QHVCEditOverlayItemPreview alloc] initWithFrame:rect overlayCommandId:kMainTrackId];
            [matrixItem.preview setRadian:matrixItem.previewRadian];
            [[QHVCEditCommandManager manager] updateMatrix:matrixItem];
        }
        
        [self.matrixItemArray addObject:matrixItem];
        
        WEAK_SELF
        __weak typeof(matrixItem) weakItem = matrixItem;
        [matrixItem.preview setTapAction:^{
            STRONG_SELF
            [self overlayTapped:weakItem];
        }];
        
        [matrixItem.preview setRotateGestureAction:^(BOOL isEnd)
         {
             STRONG_SELF
             weakItem.renderRect = [self rectToOutputRect:weakItem];
             weakItem.previewRadian = weakItem.preview.radian;
             [[QHVCEditCommandManager manager] updateMatrix:weakItem];
             SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
         }];
        
        [matrixItem.preview setMoveGestureAction:^(BOOL isEnd)
         {
             STRONG_SELF
             weakItem.renderRect = [self rectToOutputRect:weakItem];
             [[QHVCEditCommandManager manager] updateMatrix:weakItem];
             SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
         }];
        
        [matrixItem.preview setPinchGestureAction:^(BOOL isEnd)
         {
             STRONG_SELF
             weakItem.renderRect = [self rectToOutputRect:weakItem];
             [[QHVCEditCommandManager manager] updateMatrix:weakItem];
             SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
         }];
    }
    
    //叠加文件
    NSMutableArray<QHVCEditMatrixItem *>* array = [QHVCEditPrefs sharedPrefs].matrixItems;
    [array enumerateObjectsUsingBlock:^(QHVCEditMatrixItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if (obj.overlayCommandId != kMainTrackId)
        {
            if (!obj.preview)
            {
                CGRect rect = CGRectZero;
                if (CGRectGetWidth(obj.renderRect) == 0)
                {
                    CGFloat scaleW = kDefaultWidth/CGRectGetWidth(obj.originRect);
                    CGFloat scaleH = kDefaultHeight/CGRectGetHeight(obj.originRect);
                    CGFloat scale = MIN(scaleW, scaleH);
                    int width = CGRectGetWidth(obj.originRect)*scale;
                    int height = CGRectGetHeight(obj.originRect)*scale;
                    rect = [self createRandomRect:CGSizeMake(width, height)];
                    
                    CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
                    scaleW = outputSize.width/CGRectGetWidth(self.frame);
                    scaleH = outputSize.height/CGRectGetHeight(self.frame);
                    CGRect renderRect = CGRectMake(CGRectGetMinX(rect) * scaleW,
                                                   CGRectGetMinY(rect) * scaleH,
                                                   CGRectGetWidth(rect) * scaleW,
                                                   CGRectGetHeight(rect) * scaleH);

                    obj.renderRect = renderRect;
                    obj.outputParams = outputParams;
                    obj.zOrder = zOrderIndex;
                    zOrderIndex++;
                }
                else
                {
                    rect = [self rectToViewRect:obj.renderRect];
                }
                obj.preview = [[QHVCEditOverlayItemPreview alloc] initWithFrame:rect overlayCommandId:obj.overlayCommandId];
                obj.preview.startTimestampMs = obj.startTimestampMs;
                obj.preview.endTimestampMs = obj.endTiemstampMs;
                [obj.preview setRadian:obj.previewRadian];
                [[QHVCEditCommandManager manager] updateMatrix:obj];
            }

            [self.matrixItemArray addObject:obj];
            
            WEAK_SELF
            __weak typeof(obj) weakItem = obj;
            [obj.preview setTapAction:^{
                STRONG_SELF
                [self overlayTapped:weakItem];
            }];
            
            [obj.preview setPlayerNeedRefreshAction:^(BOOL forceRefresh)
            {
                STRONG_SELF
                SAFE_BLOCK(self.playerNeedRefreshAction, forceRefresh);
            }];
            
            [obj.preview setRotateGestureAction:^(BOOL isEnd)
             {
                 STRONG_SELF
                 weakItem.renderRect = [self rectToOutputRect:weakItem];
                 weakItem.previewRadian = weakItem.preview.radian;
                 [[QHVCEditCommandManager manager] updateMatrix:weakItem];
                 SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
             }];
            
            [obj.preview setMoveGestureAction:^(BOOL isEnd)
             {
                 STRONG_SELF
                 weakItem.renderRect = [self rectToOutputRect:weakItem];
                 [[QHVCEditCommandManager manager] updateMatrix:weakItem];
                 SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
             }];
            
            [obj.preview setPinchGestureAction:^(BOOL isEnd)
             {
                 STRONG_SELF
                 weakItem.renderRect = [self rectToOutputRect:weakItem];
                 [[QHVCEditCommandManager manager] updateMatrix:weakItem];
                 SAFE_BLOCK(self.playerNeedRefreshAction, isEnd ? YES:NO);
             }];
        }
    }];
    
    //排序
    [self.matrixItemArray sortUsingComparator:^NSComparisonResult(QHVCEditMatrixItem * obj1, QHVCEditMatrixItem * obj2)
     {
         if (obj1.zOrder >= obj2.zOrder)
         {
             return NSOrderedDescending;
         }
         else
         {
             return NSOrderedAscending;
         }
     }];
    
    //绘制
    [self.matrixItemArray enumerateObjectsUsingBlock:^(QHVCEditMatrixItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [self addSubview:obj.preview];
    }];
}

- (void)updateOverlayZOrderToTop:(QHVCEditMatrixItem *)item
{
    QHVCEditMatrixItem* obj = [self.matrixItemArray objectAtIndex:item.zOrder-1];
    [self.matrixItemArray removeObjectAtIndex:item.zOrder-1];
    [self.matrixItemArray addObject:obj];
    
    [self.matrixItemArray enumerateObjectsUsingBlock:^(QHVCEditMatrixItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        obj.zOrder = idx + 1;
    }];
    
    [self bringSubviewToFront:item.preview];
}

- (void)updateOverlayZOrderToBottom:(QHVCEditMatrixItem *)item
{
    QHVCEditMatrixItem* obj = [self.matrixItemArray objectAtIndex:item.zOrder-1];
    [self.matrixItemArray removeObjectAtIndex:item.zOrder-1];
    [self.matrixItemArray insertObject:obj atIndex:0];
    
    [self.matrixItemArray enumerateObjectsUsingBlock:^(QHVCEditMatrixItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         obj.zOrder = idx + 1;
     }];
    
    [item.preview removeFromSuperview];
    [self insertSubview:item.preview atIndex:1];
}

- (void)overlayStartCrop:(QHVCEditMatrixItem *)item
{
    [item.preview startCrop];
}

- (void)overlayStopCrop:(QHVCEditMatrixItem *)item confirm:(BOOL)confirm
{
    [item.preview stopCrop:confirm];
    if (confirm)
    {
        item.sourceRect = [self cropRectToOutputRect:item];
        item.renderRect = item.preview.frame;
    }
}

//裁剪区域尺寸转为视频源裁剪尺寸
- (CGRect)cropRectToOutputRect:(QHVCEditMatrixItem *)item
{
    UIView* view = item.preview;
//    CGRect previewRect = view.frame;
    CGRect cropRect = item.preview.cropRect;
    CGRect sourceRect = item.sourceRect;
    
    CGFloat scaleW = CGRectGetWidth(sourceRect)/CGRectGetWidth(item.renderRect);
    CGFloat scaleH = CGRectGetHeight(sourceRect)/CGRectGetHeight(item.renderRect);
    
    CGFloat x = CGRectGetMinX(cropRect) * scaleW + CGRectGetMinX(sourceRect);
    CGFloat y = CGRectGetMinY(cropRect) * scaleH + CGRectGetMinY(sourceRect);
    CGFloat w = CGRectGetWidth(cropRect) * scaleW;
    CGFloat h = CGRectGetHeight(cropRect) * scaleH;
    
    CGRect newRect = CGRectMake(x, y, w, h);
    return newRect;
}

- (void)disSelectAllOverlay
{
    [self.matrixItemArray enumerateObjectsUsingBlock:^(QHVCEditMatrixItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [obj.preview setSelect:NO];
    }];
}

- (void)overlayTapped:(QHVCEditMatrixItem *)item
{
    SAFE_BLOCK(self.overlayTapAction, item);
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        if ([obj isKindOfClass:[QHVCEditOverlayItemPreview class]])
        {
            if (obj == item.preview)
            {
                [(QHVCEditOverlayItemPreview*)obj setSelect:YES];
            }
            else
            {
                [(QHVCEditOverlayItemPreview*)obj setSelect:NO];
            }
        }
    }];
}

- (void)overlayColorPicked:(UIColor *)color
{
    
}

- (CGRect)createRandomRect:(CGSize)size
{
    CGRect rect = CGRectZero;
    CGFloat x = [self getRandomNumber:0 to:(CGRectGetWidth(self.frame) - size.width)];
    CGFloat y = [self getRandomNumber:0 to:(CGRectGetHeight(self.frame) - size.height)];
    
    rect.origin.x = x;
    rect.origin.y = y;
    rect.size.width = size.width;
    rect.size.height = size.height;
    return rect;
}

- (int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

//画布尺寸转为 view 尺寸
- (CGRect)rectToViewRect:(CGRect)rect
{
    CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
    CGFloat scaleW = CGRectGetWidth(self.frame)/outputSize.width;
    CGFloat scaleH = CGRectGetHeight(self.frame)/outputSize.height;
    
    CGFloat x = rect.origin.x * scaleW;
    CGFloat y = rect.origin.y * scaleH;
    CGFloat w = rect.size.width * scaleW;
    CGFloat h = rect.size.height * scaleH;
    
    CGRect newRect = CGRectMake(x, y, w, h);
    return newRect;
}

//view尺寸转为画布尺寸
- (CGRect)rectToOutputRect:(QHVCEditMatrixItem *)item
{
    UIView* view = item.preview;
    CGRect rect = view.frame;
    view.transform = CGAffineTransformRotate(view.transform, -item.preview.radian);
    rect = CGRectMake(rect.origin.x, rect.origin.y, view.frame.size.width, view.frame.size.height);
    view.transform = CGAffineTransformRotate(view.transform, item.preview.radian);
    
    CGSize outputSize = [QHVCEditPrefs sharedPrefs].outputSize;
    CGFloat scaleW = outputSize.width/CGRectGetWidth(self.frame);
    CGFloat scaleH = outputSize.height/CGRectGetHeight(self.frame);
    
    CGFloat x = rect.origin.x * scaleW;
    CGFloat y = rect.origin.y * scaleH;
    CGFloat w = rect.size.width * scaleW;
    CGFloat h = rect.size.height * scaleH;
    
    CGRect newRect = CGRectMake(x, y, w, h);
    return newRect;
}

@end
