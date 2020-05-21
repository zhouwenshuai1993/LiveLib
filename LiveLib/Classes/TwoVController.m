//
//  TwoVController.m
//  DemoApp
//
//  Created by 嗯，大葱 on 2019/2/13.
//  Copyright © 2019 嗯，大葱. All rights reserved.
//

#import "TwoVController.h"
#import <AVFoundation/AVFoundation.h>

#define VIDEOURL @"http://101.96.10.47/vjs.zencdn.net/v/oceans.mp4"
#define VIDEOURLTWO  @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"

@interface TwoVController ()

@property (nonatomic, strong) UILabel *timeLB;


@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) UISlider *slider;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation TwoVController

- (void)viewDidLoad {
    [super viewDidLoad];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height)];
    _activityIndicator.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    self.navigationItem.title = @"视频播放";
    [self setVideoUI];

    
}

- (void)setVideoUI {
    

    //初始化播放单元
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:VIDEOURLTWO]];
    //初始化播放器对象
    _player = [[AVPlayer alloc] initWithPlayerItem:item];
    //显示画面
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    //视频填充方式
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [layer setFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 300)];
    [self.view.layer addSublayer:layer];
    [_activityIndicator stopAnimating];
//    [self addProgressObserver];
//    [self addObserverToPlayerItem:_player.currentItem];
    
    CGFloat x = 0;
    NSArray *titleAry = @[@"暂停",@"播放"];
    for (int i = 0; i < titleAry.count; i++) {
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [btn setFrame:CGRectMake(x, 450, 50, 50)];
        [btn setTitle:titleAry[i] forState:(UIControlStateNormal)];
        [self.view addSubview:btn];
        [btn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        btn.tag = 101+i;
        [btn addTarget:self action:@selector(handleStopAndStartAction:) forControlEvents:(UIControlEventTouchUpInside)];
        x = x+ 300;
    }
    
    _timeLB = [[UILabel alloc] initWithFrame:CGRectMake(150, 70, 150, 30)];
    _timeLB.textColor = [UIColor redColor];
    _timeLB.textAlignment = NSTextAlignmentCenter;
    _timeLB.font = [UIFont systemFontOfSize:15];
    _timeLB.text = @"视频长度 00:00";
    [self.view addSubview:_timeLB];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(50, 550, 300, 10)];
//    _slider.maximumValue = 5;
//    _slider.minimumValue = 0;
    _slider.backgroundColor = [UIColor orangeColor];
    [_slider addTarget:self action:@selector(handleSliderChangeAction:) forControlEvents:(UIControlEventValueChanged)];
    [self.view addSubview:_slider];
    
}

//slider变化
- (void)handleSliderChangeAction:(UISlider *)sender {
    NSLog(@"当前滑动的进度%f",sender.value);
   
    //拖拽的时候先暂停
    BOOL isPlaying = false;
    if (self.player.rate > 0) {
        isPlaying = true;
        [self.player pause];
    }
    // 先不跟新进度
//    self.isChangeValue = true;
    float fps = [[[self.player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player.currentItem.duration) * sender.value, fps);
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (isPlaying) {
            [weakSelf.player play];
        }
//        weakSelf.isChangeValue = false;
    }];
}

- (void)handleStopAndStartAction:(UIButton *)sender {
    switch (sender.tag) {
        case 101:
            [self pause];
            break;
            
        case 102:
            [self  play];
            break;
            
        default:
            break;
    }
}

- (void)play {
    if (_player.rate == 0) {
        [_player play];
        //获取视频的总秒数
//         316.858333
        CGFloat duration = CMTimeGetSeconds([self.player.currentItem duration]);
//         [NSString stringWithFormat:@"%.f",duration/64/64];
        NSString * hT =[self notRounding:duration/60/60 afterPoint:0];
        NSString * fT = [self notRounding:(duration- (duration/60/60)*60)/60 afterPoint:0];
        NSString *sT =[self notRounding:duration-[hT floatValue]*60*60-[fT floatValue]*60 afterPoint:0];
        _timeLB.text = [NSString stringWithFormat:@"%@:%@:%@",hT,fT,sT];
        NSLog(@"------%f",((duration/64/64)));
    }
}

//不四舍五入
-(NSString *)notRounding:(float)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

- (void)pause {
    if (_player.rate !=0) {
        [_player pause];
    }
}

- (void)progressAction {
    __weak typeof(self)WeakSelf = self;
    __strong typeof(WeakSelf) strongSelf = WeakSelf;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC)
                                                queue:NULL
                                           usingBlock:^(CMTime time) {
                                               //进度 当前时间/总时间
                                               CGFloat progress = CMTimeGetSeconds(WeakSelf.player.currentItem.currentTime) / CMTimeGetSeconds(WeakSelf.player.currentItem.duration);
                                               //在这里截取播放进度并处理
                                               if (progress == 1.0f) {
                                               }
                                           }];
}


#pragma mark - 监听
- (void)addProgressObserver {
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//        if (weakSelf.isChangeValue) {
//            return;
//        }
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
        if (current) {
            [weakSelf.slider setValue:(current / total) animated:YES];
        }
    }];
}
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
@end
