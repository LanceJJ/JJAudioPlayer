# JJAudioPlayer

## 音频播放器

* 使用AVPlayer封装的音频播放器
* 支持单曲循环，自动播放，倍速播放，快进，快退，后台播放，锁屏控制，耳机控制等功能

## 使用方法

* 初始化播放器（支持本地音频与网络音频）

```objc
  /**
 Description 初始化播放器
 */
- (void)preparePlayAudioWithUrl:(NSURL *)url;
```	

* 播放回调代理与播放状态（在外部实时监听播放状态）


```objc

typedef NS_ENUM(NSUInteger, JJAudioPlayerPlayStatus) {
    JJAudioPlayerPlayStatusPrepared, // 准备播放
    JJAudioPlayerPlayStatusPreparedSuccess, // 预加载成功
    JJAudioPlayerPlayStatusPlaying, // 播放中
    JJAudioPlayerPlayStatusPause, // 暂停
    JJAudioPlayerPlayStatusEnd, // 播放结束
    JJAudioPlayerPlayStatusFailed // 播放失败
};

- (void)jj_audioPlayer_playPreparedSuccessWithAsset:(AVAsset *)asset totalTime:(float)totalTime;
- (void)jj_audioPlayer_playBegin;
- (void)jj_audioPlayer_playPause;
- (void)jj_audioPlayer_playFailed;
- (void)jj_audioPlayer_playEnd;
- (void)jj_audioPlayer_playTimeChangedCurrent:(float)current total:(float)total;

```	

* 控制方法（切换倍速，播放，暂停，播放指定位置，后台播放，设置锁屏信息，设置远程控制）


```objc
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
```	

* 注：`后台播放需要在 Info.plist 中添加 Required background modes ，并在下面添加一项 App plays audio or streams audio/video using AirPlay 同时修改Capabilities，在 Capabilities 中开启 Background Modes`

* 销毁播放器（界面退出后需要销毁播放器）

```objc
/**
 Description 销毁播放器
 */
- (void)deallocPlayer;
```	

