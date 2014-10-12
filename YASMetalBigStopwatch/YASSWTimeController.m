//
//  YASSWTimeController.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWTimeController.h"
#import "YASSWState.h"
#import "YASSWDataStore.h"

@interface YASSWTimeController ()

@property (nonatomic, weak) id<YASSWTimeControllerDelegate> delegate;
@property (nonatomic) YASSWState *state;
@property (nonatomic) YASSWDataStore *dataStore;

@end

@implementation YASSWTimeController

- (instancetype)initWithDelegate:(id<YASSWTimeControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        self.dataStore = [[YASSWDataStore alloc] init];
        self.state = [[_dataStore.stateClass alloc] initWithStopwatchController:self];
    }
    return self;
}

#pragma mark - Accessor

- (void)setStopTime:(NSTimeInterval)stopTime
{
    _dataStore.stopTime = stopTime;
}

- (NSTimeInterval)stopTime
{
    return _dataStore.stopTime;
}

- (void)setStartDate:(NSDate *)startDate
{
    _dataStore.startDate = startDate;
}

- (NSDate *)startDate
{
    return _dataStore.startDate;
}

- (NSTimeInterval)time
{
    return [_state time];
}

- (NSInteger)lapIndex
{
    return _dataStore.lapIndex;
}

- (NSArray *)laps
{
    return _dataStore.laps;
}

- (NSTimeInterval)countdownTime
{
    return _dataStore.countdownTime;
}

#pragma mark - Control

- (void)main
{
    [_state main];
}

- (void)sub
{
    [_state sub];
}

- (void)next
{
    [_state next];
}

- (void)back
{
    [_state back];
}

#pragma mark - From State

- (void)changeState:(Class)stateClass
{
    Class prevStateClass = [_state class];
    [_state exit];
    self.state = nil;
    
    _dataStore.stateClass = stateClass;
    
    self.state = [[stateClass alloc] initWithStopwatchController:self];
    [_state enter];
    
    if ([_delegate respondsToSelector:@selector(timeController:didChangeStateFrom:)]) {
        [_delegate timeController:self didChangeStateFrom:prevStateClass];
    }
    
    [_dataStore save];
}

- (BOOL)isLastLapIndex
{
    if (_dataStore.laps.count - 1 == _dataStore.lapIndex) {
        return YES;
    }
    return NO;
}

- (void)resetLap
{
    _dataStore.laps = [[NSMutableArray alloc] initWithObjects:@(0.0), nil];
    _dataStore.lapIndex = 0;
    [_dataStore save];
    
    [self _notifyDidChangeLap];
}

- (void)addLap:(NSTimeInterval)timeInterval
{
    if (_dataStore.laps.count >= NSIntegerMax) {
        [_dataStore.laps removeObjectAtIndex:0];
    }
    
    [_dataStore.laps addObject:@(timeInterval)];
    _dataStore.lapIndex = _dataStore.laps.count - 1;
    [_dataStore save];
    
    [self _notifyDidChangeLap];
}

- (void)countUpLap
{
    if (_dataStore.lapIndex < _dataStore.laps.count - 1) {
        _dataStore.lapIndex++;
    } else {
        _dataStore.lapIndex = 0;
    }
    [_dataStore save];
    
    [self _notifyDidChangeLap];
}

- (void)countDownLap
{
    if (_dataStore.lapIndex > 0) {
        _dataStore.lapIndex--;
    } else {
        _dataStore.lapIndex = _dataStore.laps.count - 1;
    }
    [_dataStore save];
    
    [self _notifyDidChangeLap];
}

- (void)overZero
{
    [self _notifyDidOverZero];
}

#pragma mark - Private

- (void)_notifyDidChangeLap
{
    if ([_delegate respondsToSelector:@selector(timeControllerDidChangeLap:)]) {
        [_delegate timeControllerDidChangeLap:self];
    }
}

- (void)_notifyDidOverZero
{
    if ([_delegate respondsToSelector:@selector(timeControllerDidOverZero:)]) {
        [_delegate timeControllerDidOverZero:self];
    }
}

@end
