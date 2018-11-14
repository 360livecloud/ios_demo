//
//  QHVCITSGuestViewController+Control.m
//  QHVideoCloudToolSet
//
//  Created by deng on 2018/3/22.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCITSLinkMicViewController+Control.h"
#import "QHVCITSActionCell.h"
#import "QHVCITSUserSystem.h"
#import <QHVCCommonKit/QHVCCommonKit.h>
#import <QHVCInteractiveKit/QHVCInteractiveKit.h>

static NSString * const actionCellIdentifier = @"QHVCITSActionCell";

@implementation QHVCITSLinkMicViewController(Control)

- (void)initActionCollectionView
{
    [_actionCollectionView registerNib:[UINib nibWithNibName:actionCellIdentifier bundle:nil] forCellWithReuseIdentifier:actionCellIdentifier];
}

- (void)updateControlView:(QHVCITSTalkType)talkType
{
    if (!_actionsArray) {
        _actionsArray = [NSMutableArray array];
    }
    [_actionsArray removeAllObjects];
    [_actionsArray addObjectsFromArray:[self actionDataSource:talkType]];
    
    [_actionCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _actionsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QHVCITSActionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:actionCellIdentifier forIndexPath:indexPath];
    [cell updateCell:_actionsArray[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _actionsArray[indexPath.row];
    NSInteger actionType = [dict[@"actionType"] integerValue];
    
    if (actionType == QHVCITSActionTypeSpeaker) {
        _openSpeakerphone = !_openSpeakerphone;
        [[QHVCInteractiveKit sharedInstance] setEnableSpeakerphone:_openSpeakerphone];
        [self updateControlView:[QHVCITSUserSystem sharedInstance].roomInfo.talkType];
    }
    else if (actionType == QHVCITSActionTypeMic)
    {
        _muteMicrophone = !_muteMicrophone;
        [[QHVCInteractiveKit sharedInstance] muteLocalAudioStream:_muteMicrophone];
        [self updateControlView:[QHVCITSUserSystem sharedInstance].roomInfo.talkType];
    }
    else if (actionType == QHVCITSActionTypeCameraSwitch)
    {
        if (_muteLocalVideo) {
            return;
        }
        _openFrontCamera = !_openFrontCamera;
        [[QHVCInteractiveKit sharedInstance] switchCamera];
        [self updateControlView:[QHVCITSUserSystem sharedInstance].roomInfo.talkType];
    }
    else if (actionType == QHVCITSActionTypeCamera)
    {
        _muteLocalVideo = !_muteLocalVideo;
        [[QHVCInteractiveKit sharedInstance] muteLocalVideoStream:_muteLocalVideo];
        [self updateControlView:[QHVCITSUserSystem sharedInstance].roomInfo.talkType];
    }
//    else if (actionType == QHVCITSActionTypeBeauty)
//    {
//
//    }
//    else if (actionType == QHVCITSActionTypeFilter)
//    {
//
//    }
//    else if (actionType == QHVCITSActionTypeFaceu)
//    {
//
//    }
    else if (actionType == QHVCITSActionTypeFullScreen)
    {
        _isFullScreen = !_isFullScreen;
        
        if (_isFullScreen) {
            _controlView.hidden = YES;
            _existFullScreenBtn.hidden = NO;
        }
    }
}

- (IBAction)existFullScreenBtnAction:(UIButton *)sender
{
    _isFullScreen = !_isFullScreen;
    _controlView.hidden = NO;
    _existFullScreenBtn.hidden = YES;
}

- (NSArray<NSDictionary *> *)actionDataSource:(QHVCITSTalkType)talkType
{
    NSArray<NSDictionary *> *actions = [self createDataSource];
    
    QHVCITSIdentity identity = [[QHVCITSUserSystem sharedInstance] userInfo].identity;
    
    if (identity == QHVCITS_Identity_Audience) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterLevel =%@",@(QHVCITSFilterLevelAny)];
        NSArray *as = [actions filteredArrayUsingPredicate:predicate];
        return as;
    }
    else
    {
        if (talkType == QHVCITS_Talk_Type_Audio) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filterLevel <=%@",@(QHVCITSFilterLevelTwo)];
            NSArray *as = [actions filteredArrayUsingPredicate:predicate];
            return as;
        }
        return actions;
    }
}

- (NSArray<NSDictionary *> *)createDataSource
{
    return @[@{@"normal":@"room_speaker",
               @"switch":@"room_earphone",
               @"disable":@(0),
               @"status":@(_openSpeakerphone),
               @"actionType":@"0",
               @"filterLevel":@(QHVCITSFilterLevelAny)
               },
             @{@"normal":@"room_mic",
               @"switch":@"room_mic_close",
               @"disable":@(0),
               @"status":@(!_muteMicrophone),
               @"actionType":@"1",
               @"filterLevel":@(QHVCITSFilterLevelTwo)
               },
             @{@"normal":@"room_camera_switch",
               @"switch":@"room_camera_switch_gray",
               @"disable":@(_muteLocalVideo),
               @"status":@(1),
               @"actionType":@"2",
               @"filterLevel":@(QHVCITSFilterLevelThree)
               },
             @{@"normal":@"room_camera",
               @"switch":@"room_camera_close",
               @"disable":@(0),
               @"status":@(!_muteLocalVideo),
               @"actionType":@"3",
               @"filterLevel":@(QHVCITSFilterLevelThree)
               },
             /*@{@"normal":@"room_beauty",
               @"switch":@"",
               @"disable":@(_muteLocalVideo),
               @"status":@(1),
               @"actionType":@"4",
               @"filterLevel":@(QHVCITSFilterLevelThree)
               },
             @{@"normal":@"room_filter",
               @"switch":@"",
               @"disable":@(_muteLocalVideo),
               @"status":@(1),
               @"actionType":@"5",
               @"filterLevel":@(QHVCITSFilterLevelThree)
               },
             @{@"normal":@"room_faceu",
               @"switch":@"",
               @"disable":@(_muteLocalVideo),
               @"status":@(1),
               @"actionType":@"6",
               @"filterLevel":@(QHVCITSFilterLevelThree)
               },*/
             @{@"normal":@"room_zoom_out",
               @"switch":@"",
               @"disable":@(0),
               @"status":@(1),
               @"actionType":@"4",
               @"filterLevel":@(QHVCITSFilterLevelAny)
               }];
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
