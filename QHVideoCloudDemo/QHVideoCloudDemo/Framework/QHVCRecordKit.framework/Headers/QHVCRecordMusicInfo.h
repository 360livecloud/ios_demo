//
//  QHVCRecordMusicInfo.h
//  QHVCRecordKit
//
//  Created by deng on 2019/5/27.
//  Copyright © 2019 qihoo.QHVC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QHVCRecordMusicInfo : NSObject

@property (nonatomic, strong) NSString *filePath;//音频文件绝对路径
@property (nonatomic, assign) int volume;//音频的音量（可设置范围0-100）
@property (nonatomic, assign) int insertTime;//相对录制的视频文件，插入音频文件的起始点 单位：ms（默认：0）
@property (nonatomic, assign) int startTime;//音频开始播放位置 单位：ms（可掐头去尾）
@property (nonatomic, assign) int endTime;//音频结束播放位置 单位：ms

@property (nonatomic, assign) BOOL isLoop;//音频是否循环播放（默认：yes）

@property (nonatomic, strong) NSString *preFilePath;//音频预处理路径
@end

NS_ASSUME_NONNULL_END
