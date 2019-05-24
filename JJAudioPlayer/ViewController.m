//
//  ViewController.m
//  JJAudioPlayer
//
//  Created by Lance on 2019/5/24.
//  Copyright © 2019 Lance. All rights reserved.
//

#import "ViewController.h"
#import "JJAudioPlayer.h"

@interface ViewController () <JJAudioPlayerDelegate>

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *cycleBtn;
@property (nonatomic, strong) UIButton *speedBtn;
@property (nonatomic, strong) UIButton *forwardBtn;
@property (nonatomic, strong) UIButton *rewindBtn;
@property (nonatomic, strong) UISlider *playSlider;
@property (nonatomic, assign) float currentTime;
@property (nonatomic, assign) float totalTime;
@property (nonatomic, assign) BOOL isChangeing;
@property (nonatomic, assign) NSInteger rate;

@property (nonatomic, assign) JJAudioPlayerPlayStatus playStatus;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //开始时间
    UILabel *currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 80, 40)];
    
    currentTimeLabel.text = @"00:00";
    currentTimeLabel.font = [UIFont systemFontOfSize:14];
    currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:currentTimeLabel];
    
    self.currentTimeLabel = currentTimeLabel;
    
    
    //结束时间
    UILabel *totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 100, 80, 40)];
    
    totalTimeLabel.text = @"00:00";
    totalTimeLabel.font = [UIFont systemFontOfSize:14];
    totalTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:totalTimeLabel];
    
    self.totalTimeLabel = totalTimeLabel;

    
    //滑块
    UISlider *playSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, 100, self.view.frame.size.width - 80 * 2, 40)];
    [playSlider addTarget:self action:@selector(sliderProgressChange:)forControlEvents:UIControlEventValueChanged];
    [playSlider addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playSlider];
    
    self.playSlider = playSlider;
    

    
    //播放按钮
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
    playBtn.frame = CGRectMake((self.view.frame.size.width - 40) / 2, CGRectGetMaxY(self.playSlider.frame) + 20, 40, 40);
    
    self.playBtn = playBtn;

    //循环按钮
    UIButton *cycleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cycleBtn setTitle:@"开启单曲循环" forState:UIControlStateNormal];
    [cycleBtn addTarget:self action:@selector(cycleAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cycleBtn];
    
    cycleBtn.frame = CGRectMake(0, CGRectGetMaxY(self.playSlider.frame) + 20, 100, 40);
    
    self.cycleBtn = cycleBtn;

    
    //倍速按钮
    UIButton *speedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [speedBtn setTitle:@"1倍速" forState:UIControlStateNormal];
    [speedBtn addTarget:self action:@selector(speedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:speedBtn];
    
    speedBtn.frame = CGRectMake(self.view.frame.size.width - 40, CGRectGetMaxY(self.playSlider.frame) + 20, 40, 40);
    
    self.speedBtn = speedBtn;

    //快进按钮
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [forwardBtn setTitle:@"快进" forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forwardAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forwardBtn];
    
    
    forwardBtn.frame = CGRectMake(self.view.frame.size.width - 40, CGRectGetMaxY(self.cycleBtn.frame) + 20, 40, 40);
    
    self.forwardBtn = forwardBtn;

    //快退按钮
    UIButton *rewindBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rewindBtn setTitle:@"快退" forState:UIControlStateNormal];
    [rewindBtn addTarget:self action:@selector(rewindAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rewindBtn];
    
    rewindBtn.frame = CGRectMake(0, CGRectGetMaxY(self.cycleBtn.frame) + 20, 40, 40);
    
    self.rewindBtn = rewindBtn;

    self.playSlider.enabled = NO;
    self.cycleBtn.enabled = NO;
    self.rewindBtn.enabled = NO;
    self.forwardBtn.enabled = NO;
    self.speedBtn.enabled = NO;
    self.playBtn.enabled = NO;
    self.rate = 1;
    
    //播放本地音频
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lovest" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    //播放网络音频
//    NSURL *url = [NSURL URLWithString:@""];
    
    [[JJAudioPlayer sharedInstance] preparePlayAudioWithUrl:url];
    [JJAudioPlayer sharedInstance].delegate = self;
    
}

- (void)sliderProgressChange:(UISlider *)slider
{
    self.isChangeing = YES;
}

- (void)sliderTouchUpInSide:(UISlider *)slider
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isChangeing = NO;
    });
    
    NSLog(@"%f", self.totalTime * slider.value);
    
    [[JJAudioPlayer sharedInstance] seekToTime:self.totalTime * slider.value];
}


/**
 Description 播放
 */
- (void)playAction:(UIButton *)btn
{
    if ([JJAudioPlayer sharedInstance].playStatus == JJAudioPlayerPlayStatusPlaying) {
        [[JJAudioPlayer sharedInstance] pause];
    } else {
        [[JJAudioPlayer sharedInstance] play];
    }
    
}

/**
 Description 循环
 */
- (void)cycleAction:(UIButton *)btn
{
    [JJAudioPlayer sharedInstance].isSingleCycle = ![JJAudioPlayer sharedInstance].isSingleCycle;
    if ([JJAudioPlayer sharedInstance].isSingleCycle) {
        
        [self.cycleBtn setTitle:@"关闭单曲循环" forState:UIControlStateNormal];
    } else {
        
        [self.cycleBtn setTitle:@"开启单曲循环" forState:UIControlStateNormal];
    }
}

/**
 Description 倍速
 */
- (void)speedAction:(UIButton *)btn
{
    self.rate++;
    
    if (self.rate > 2) {
        self.rate = 1;
    }
    
    [[JJAudioPlayer sharedInstance] switchRateValue:self.rate];
    [self.speedBtn setTitle:[NSString stringWithFormat:@"%ld倍速", (long)self.rate] forState:UIControlStateNormal];
    
}

/**
 Description 快进
 */
- (void)forwardAction:(UIButton *)btn
{
    [[JJAudioPlayer sharedInstance] seekToTime:self.currentTime + 10];
}

/**
 Description 快退
 */
- (void)rewindAction:(UIButton *)btn
{
    [[JJAudioPlayer sharedInstance] seekToTime:self.currentTime - 10];
}

/**
 Description 播放指定位置
 */
- (void)seekToTime:(float)time
{
    if (self.playStatus == JJAudioPlayerPlayStatusFailed || self.playStatus == JJAudioPlayerPlayStatusPrepared) return;
    
    if (self.playStatus != JJAudioPlayerPlayStatusPlaying) {
        
        [[JJAudioPlayer sharedInstance] play];
    }
    
    [[JJAudioPlayer sharedInstance] seekToTime:time];
}

#pragma mark - JJAudioPlayerDelegate

- (void)jj_audioPlayer_playPreparedSuccessWithAsset:(AVAsset *)asset totalTime:(float)totalTime
{
    NSInteger total = (NSInteger)totalTime;
    
    self.totalTime = totalTime;
    
    NSInteger minutes = total / 60;
    NSInteger seconds = total % 60;
    
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    self.playSlider.value = 0;
    [self.speedBtn setTitle:@"1倍速" forState:UIControlStateNormal];
    
    self.playSlider.enabled = YES;
    self.cycleBtn.enabled = YES;
    self.rewindBtn.enabled = YES;
    self.forwardBtn.enabled = YES;
    self.speedBtn.enabled = YES;
    self.playBtn.enabled = YES;
    
    [[JJAudioPlayer sharedInstance] setRemoteControl];
}

- (void)jj_audioPlayer_playTimeChangedCurrent:(float)current total:(float)total
{

    NSInteger currentTime = (NSInteger)current;
    
    self.currentTime = current;
    
    NSInteger minutes = currentTime / 60;
    NSInteger seconds = currentTime % 60;
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    
    //防止跳动
    if (self.isChangeing) return;
    
    self.playSlider.value = current / total;
    
    NSDictionary *info = @{
                           @"title" : @"音乐名称",
                           @"autor" : @"作者",
                           @"total" : @(total),
                           @"current" : @(current)
                           };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[JJAudioPlayer sharedInstance] setLockScreenPlayingInfoWithInfo:info image:[UIImage imageNamed:@"20140306110441515.jpg"]];
    });
}

- (void)jj_audioPlayer_playEnd
{
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
}

- (void)jj_audioPlayer_playBegin
{
    [self.playBtn setTitle:@"暂停" forState:UIControlStateNormal];
}

- (void)jj_audioPlayer_playPause
{
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
}

- (JJAudioPlayerPlayStatus)playStatus
{
    return [JJAudioPlayer sharedInstance].playStatus;
}


@end
