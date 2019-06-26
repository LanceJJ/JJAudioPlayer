//
//  JJAudioPlayer.h
//  JJAudioPlayer
//
//  Created by Lance on 2019/5/24.
//  Copyright © 2019 Lance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN



typedef NS_ENUM(NSUInteger, JJAudioPlayerPlayStatus) {
    JJAudioPlayerPlayStatusPrepared, // 准备播放
    JJAudioPlayerPlayStatusPreparedSuccess, // 预加载成功
    JJAudioPlayerPlayStatusPlaying, // 播放中
    JJAudioPlayerPlayStatusPause, // 暂停
    JJAudioPlayerPlayStatusEnd, // 播放结束
    JJAudioPlayerPlayStatusFailed // 播放失败
};

@protocol JJAudioPlayerDelegate <NSObject>

@optional
- (void)jj_audioPlayer_playPreparedSuccessWithAsset:(AVAsset *)asset totalTime:(float)totalTime;
- (void)jj_audioPlayer_playBegin;
- (void)jj_audioPlayer_playPause;
- (void)jj_audioPlayer_playFailed;
- (void)jj_audioPlayer_playEnd;
- (void)jj_audioPlayer_playTimeChangedCurrent:(float)current total:(float)total;
- (void)jj_audioPlayer_playTotalBuffer:(NSTimeInterval)totalBuffer;

@end

@interface JJAudioPlayer : NSObject

@property (nonatomic, assign, readonly) JJAudioPlayerPlayStatus playStatus;
@property (nonatomic, weak) id<JJAudioPlayerDelegate> delegate;
@property (nonatomic, assign) BOOL isSingleCycle;//是否单曲循环
@property (nonatomic, assign) BOOL isAutoPlay;//是否自动播放

+ (JJAudioPlayer *)sharedInstance;

/**
 Description 初始化播放器
 */
- (void)preparePlayAudioWithUrl:(NSURL *)url;

/**
 Description 切换播放倍速
 */
- (void)switchRateValue:(CGFloat)rateValue;

/**
 Description 播放
 */
- (void)play;

/**
 Description 暂停
 */
- (void)pause;

/**
 Description 播放指定位置
 */
- (void)seekToTime:(float)time;

/**
 Description 设置后台播放
 */
- (void)setBackPlay;

/**
 Description 设置锁屏信息
 
 @param info 锁屏信息
 @param image 锁屏图片
 */
- (void)setLockScreenPlayingInfoWithInfo:(NSDictionary *)info image:(UIImage *)image;

/**
 Description 设置远程控制（锁屏，耳机控制）
 */
- (void)setRemoteControl;

/**
 Description 销毁播放器
 */
- (void)deallocPlayer;

@end

NS_ASSUME_NONNULL_END
