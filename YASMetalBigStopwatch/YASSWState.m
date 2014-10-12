//
//  YASSWState.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWState.h"
#import "YASSWTimeController.h"

@interface YASSWTimeController (YASSWState)

@property (nonatomic) NSTimeInterval stopTime;
@property (nonatomic) NSDate *startDate;

- (void)changeState:(Class)stateClass;
- (void)resetLap;
- (void)addLap:(NSTimeInterval)timeInterval;
- (void)countUpLap;
- (void)countDownLap;
- (void)overZero;

@end

@interface YASSWState ()

@property (nonatomic, weak) YASSWTimeController *controller;

@end

@implementation YASSWState

- (instancetype)initWithStopwatchController:(YASSWTimeController *)controller
{
    self = [super init];
    if (self) {
        _controller = controller;
    }
    return self;
}

- (void)enter
{
    
}

- (void)exit
{
    
}

- (void)main
{
    
}

- (void)sub
{
    
}

- (void)next
{
    
}

- (void)back
{
    
}

- (NSTimeInterval)time
{
    return 0.0;
}

@end


@implementation YASSWZeroState


- (void)enter
{
    self.controller.stopTime = 0;
    [self.controller resetLap];
}

- (void)main
{
    [self.controller changeState:[YASSWPlayState class]];
}

- (void)sub
{
    [self.controller changeState:[YASSWCountdownState class]];
}

@end

@interface YASSWPlayState ()

@property (nonatomic, strong) NSTimer *zeroTimer;

@end

@implementation YASSWPlayState

- (void)enter
{
    self.controller.startDate = [[NSDate alloc] init];
    NSTimeInterval stopTime = self.controller.stopTime;
    if (stopTime < 0.0) {
        [self _addZeroTimer:-stopTime];
    }
}

- (void)exit
{
    [self _removeZeroTimer];
}

- (void)main
{
    [self.controller changeState:[YASSWStopState class]];
}

- (void)sub
{
    NSTimeInterval time = self.controller.time;
    if (time >= 0.0) {
        [self.controller addLap:time];
    }
}

- (void)next
{
    [self.controller countUpLap];
}

- (void)back
{
    [self.controller countDownLap];
}

- (NSTimeInterval)time
{
    NSTimeInterval time = self.controller.stopTime;
    NSDate *startDate = self.controller.startDate;
    if (startDate) {
        time -= [startDate timeIntervalSinceNow];
    }
    return time;
}

#pragma mark - Private

- (void)_addZeroTimer:(NSTimeInterval)timeInterval
{
    [self.zeroTimer invalidate];
    self.zeroTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(_overZero) userInfo:nil repeats:NO];
}

- (void)_removeZeroTimer
{
    [self.zeroTimer invalidate];
    self.zeroTimer = nil;
}

- (void)_overZero
{
    [self.controller overZero];
}

@end

@implementation YASSWStopState

- (void)enter
{
    NSTimeInterval stopTime = self.controller.stopTime;
    NSDate *startDate = self.controller.startDate;
    if (startDate) {
        stopTime -= [startDate timeIntervalSinceNow];
    }
    
    self.controller.stopTime = stopTime;
    
    if (stopTime >= 0) {
        [self.controller addLap:stopTime];
    }
}

- (void)exit
{
    
}

- (void)main
{
    [self.controller changeState:[YASSWPlayState class]];
}

- (void)sub
{
    [self.controller changeState:[YASSWZeroState class]];
}

- (void)next
{
    [self.controller countUpLap];
}

- (void)back
{
    [self.controller countDownLap];
}

- (NSTimeInterval)time
{
    return self.controller.stopTime;
}

@end

@implementation YASSWCountdownState

- (void)enter
{
    self.controller.stopTime = self.controller.countdownTime;
}

- (void)main
{
    [self.controller changeState:[YASSWPlayState class]];
}

- (void)sub
{
    [self.controller changeState:[YASSWZeroState class]];
}

- (NSTimeInterval)time
{
    return self.controller.stopTime;
}

@end
