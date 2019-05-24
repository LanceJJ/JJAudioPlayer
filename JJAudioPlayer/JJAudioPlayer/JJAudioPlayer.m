//
//  JJAudioPlayer.m
//  JJAudioPlayer
//
//  Created by Lance on 2019/5/24.
//  Copyright © 2019 Lance. All rights reserved.
//

#import "JJAudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

#import <MediaPlayer/MPRemoteCommandCenter.h>
#import <MediaPlayer/MPRemoteCommand.h>

@interface JJAudioPlayer ()

@property (nonatomic, assign) float current;
@property (nonatomic, assign) float total;
@property (nonatomic, assign) CGFloat rateValue;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id timeObserve;

@end

@implementation JJAudioPlayer

- (AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

+ (JJAudioPlayer *)sharedInstance
{
    static JJAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/**
 Description 初始化播放器
 */
- (void)preparePlayAudioWithUrl:(NSURL *)url
{
    NSLog(@"%@", self.player);
    if (self.player) {
        [self deallocPlayer];
    }
    self.rateValue = 1.0;
    self.isSingleCycle = NO;
    self.isAutoPlay = NO;
    _playStatus = JJAudioPlayerPlayStatusPrepared;
    
    [self setBackPlay];
    
    AVAsset *sourceUrl = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:sourceUrl];
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    self.playerItem = playerItem;
}

#pragma mark - 通知
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        
        // 播放通知
        AVPlayerStatus staute = [change[@"new"] integerValue];
        switch (staute) {
            case AVPlayerStatusReadyToPlay:
                NSLog(@"加载成功,可以播放了");
                [self audioPlayPreparedSuccess];
                break;
            case AVPlayerStatusFailed:
                NSLog(@"加载失败");
                [self audioPlayPreparedFailed];
                break;
            case AVPlayerStatusUnknown:
                NSLog(@"资源找不到");
                [self audioPlayPreparedFailed];
                break;
            default:
                break;
        }
    }
}


/**
 Description 加载成功
 */
- (void)audioPlayPreparedSuccess
{
    _playStatus = JJAudioPlayerPlayStatusPreparedSuccess;
    
    [self enableAudioTracks:YES inPlayerItem:self.playerItem];
    [self addTimeObserve];
    
    AVAsset *asset = self.player.currentItem.asset;
    // 总时长
    CGFloat totalTime = asset.duration.value / asset.duration.timescale;
    
    self.total = totalTime;
    
    NSLog(@"%ld", (long)totalTime);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jj_audioPlayer_playPreparedSuccessWithAsset:totalTime:)]) {
        [self.delegate jj_audioPlayer_playPreparedSuccessWithAsset:asset totalTime:totalTime];
    }
    
    //是否自动播放
    if (!self.isAutoPlay) return;
    [self play];
}

/**
 Description 加载失败
 */
- (void)audioPlayPreparedFailed
{
    _playStatus = JJAudioPlayerPlayStatusFailed;
    
    [self removeTimeObserve];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jj_audioPlayer_playFailed)]) {
        [self.delegate jj_audioPlayer_playFailed];
    }
}

/**
 Description 播放结束
 */
- (void)audioPlayEnd
{
    // 播放结束通知
    NSLog(@"播放结束了");
    _playStatus = JJAudioPlayerPlayStatusEnd;
    
    [self.player seekToTime:kCMTimeZero];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jj_audioPlayer_playEnd)]) {
        [self.delegate jj_audioPlayer_playEnd];
    }
    
    //如果单曲循环，重新播放
    if (!self.isSingleCycle) return;
    [self play];
    
}

/**
 Description 添加定时器
 */
- (void)addTimeObserve
{
    [self removeTimeObserve];
    
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        float current = CMTimeGetSeconds(time);
        //总时间
        float total = CMTimeGetSeconds(weakSelf.playerItem.duration);
        
        weakSelf.current = current;
        weakSelf.total = total;
        
        NSLog(@"%f, %f", current, total);
        
        NSArray *loadedRanges = weakSelf.playerItem.seekableTimeRanges;
        
        if (loadedRanges.count > 0 && weakSelf.playerItem.duration.timescale != 0 && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(jj_audioPlayer_playTimeChangedCurrent:total:)]) {
            [weakSelf.delegate jj_audioPlayer_playTimeChangedCurrent:current total:total];
        }
        
    }];
    
}

/**
 Description 移除定时器
 */
- (void)removeTimeObserve
{
    if (!self.timeObserve) return;
    [self.player removeTimeObserver:_timeObserve];
    self.timeObserve = nil;
}

- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem
{
    for (AVPlayerItemTrack *track in playerItem.tracks) {
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio]) {
            track.enabled = enable;
        }
    }
}

/**
 Description 切换播放倍速
 */
- (void)switchRateValue:(CGFloat)rateValue
{
    self.rateValue = rateValue;
    
    if (self.playStatus == JJAudioPlayerPlayStatusPlaying) {
        [self pause];
        [self play];
    }
}

/**
 Description 播放
 */
- (void)play
{
    _playStatus = JJAudioPlayerPlayStatusPlaying;
    
    [self.player play];
    self.player.rate = self.rateValue;
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jj_audioPlayer_playBegin)]) {
        [self.delegate jj_audioPlayer_playBegin];
    }
}

/**
 Description 暂停
 */
- (void)pause
{
    _playStatus = JJAudioPlayerPlayStatusPause;
    [self.player pause];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jj_audioPlayer_playPause)]) {
        [self.delegate jj_audioPlayer_playPause];
    }
}

/**
 Description 播放指定位置
 */
- (void)seekToTime:(float)time
{
    time = time <=0 ? 0 : time;
    
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        
    }];
}

/**
 Description 设置后台播放
 */
- (void)setBackPlay
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

/**
 Description 设置锁屏信息
 
 @param info 锁屏信息
 @param image 锁屏图片
 */
- (void)setLockScreenPlayingInfoWithInfo:(NSDictionary *)info image:(UIImage *)image
{
    //锁屏信息
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
    
    infoCenter.nowPlayingInfo = @{
                                  MPMediaItemPropertyTitle : info[@"title"] ? info[@"title"] : @"",
                                  MPMediaItemPropertyArtist : info[@"autor"] ? info[@"autor"] : @"" ,
                                  MPMediaItemPropertyPlaybackDuration : info[@"total"] ? info[@"total"] : @(0),
                                  MPNowPlayingInfoPropertyElapsedPlaybackTime : info[@"current"] ? info[@"current"] : @(0),
                                  MPMediaItemPropertyArtwork : artwork,
                                  MPNowPlayingInfoPropertyPlaybackRate : @(self.player.rate) ?  @(self.player.rate) : @(0)
                                  };
}

/**
 Description 设置远程控制（锁屏，耳机控制）
 */
- (void)setRemoteControl
{
    // 直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTarget:self action:@selector(play)];
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    [commandCenter.pauseCommand addTarget:self action:@selector(pause)];
    
    if (@available(iOS 9.1, *)) {
        //滑动进度条
        commandCenter.changePlaybackPositionCommand.enabled = YES;
        [commandCenter.changePlaybackPositionCommand addTarget:self action:@selector(changePlaybackPosition:)];
    }
    
    //快进
    MPSkipIntervalCommand *skipForwardIntervalCommand = commandCenter.skipForwardCommand;
    skipForwardIntervalCommand.preferredIntervals = @[@(10)];
    skipForwardIntervalCommand.enabled = YES;
    [skipForwardIntervalCommand addTarget:self action:@selector(skipForwardEvent:)];
    
    //快退
    MPSkipIntervalCommand *skipBackwardIntervalCommand = commandCenter.skipBackwardCommand;
    skipBackwardIntervalCommand.preferredIntervals = @[@(10)];
    skipBackwardIntervalCommand.enabled = YES;
    [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
    
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(playOrPauseAction)];
}

/**
 Description 移除远程控制方法
 */
- (void)removeCommandCenterTargets
{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.playCommand removeTarget:self];
    [commandCenter.pauseCommand removeTarget:self];
    [commandCenter.skipForwardCommand removeTarget:self];
    [commandCenter.skipBackwardCommand removeTarget:self];
    [commandCenter.togglePlayPauseCommand removeTarget:self];
    
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand removeTarget:self];
    }
}

/**
 Description 滑动进度条
 */
- (void)changePlaybackPosition:(MPRemoteCommandEvent *)event
{
    MPChangePlaybackPositionCommandEvent *playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
    
    NSLog(@"%f", playbackPositionEvent.positionTime);
    
    [self seekToTime:playbackPositionEvent.positionTime];
    
}

/**
 Description 快进
 */
- (void)skipForwardEvent:(MPSkipIntervalCommandEvent *)skipEvent
{
    NSLog(@"快进了 %f秒", skipEvent.interval);
    
    [self seekToTime:self.current + skipEvent.interval];
}

/**
 Description 快退
 */
- (void)skipBackwardEvent:(MPSkipIntervalCommandEvent *)skipEvent
{
    NSLog(@"快退了 %f秒", skipEvent.interval);
    
    [self seekToTime:self.current - skipEvent.interval];
}

/**
 Description 耳机控制操作
 */
- (void)playOrPauseAction
{
    if (self.playStatus == JJAudioPlayerPlayStatusPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

/**
 Description 销毁播放器
 */
- (void)deallocPlayer
{
    [self pause];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self removeTimeObserve];
    self.playerItem = nil;
    self.player = nil;
    self.rateValue = 1.0;
    [self removeCommandCenterTargets];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    //如果初始化的item与当前item相等,则不做操作
    if (_playerItem == playerItem) {return;}
    //如果当前item不为空,移除里面的属性观察
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_playerItem removeObserver:self forKeyPath:@"status"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        //当前音频播放完毕监听,我这里写的代理,方便数据传递
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        //监听播放器状态
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //除了播放器状态,还可以监听缓冲状态:无缓冲playbackBufferEmpty,缓冲足够可以播放:playbackBufferEmpty等,具体状态可以百度查找
    }
}

@end

