//
//  YASSWDataStore.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWDataStore.h"
#import "YASSWTimeController.h"
#import "YASSWState.h"

NSString *const YASStopwatchKeyStartDate = @"StartDate";
NSString *const YASStopwatchKeyState = @"State";
NSString *const YASStopwatchKeyStopTime = @"StopTime";
NSString *const YASStopwatchKeyLaps = @"Laps";
NSString *const YASStopwatchKeyLapIndex = @"LapIndex";
NSString *const YASStopwatchKeyCountdownTime = @"CountdownSec";

@interface YASSWDataStore ()

@property (nonatomic) NSString *stateClassName;

@end

@implementation YASSWDataStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _register];
        [self _load];
    }
    return self;
}

- (void)setStateClass:(Class)stateClass
{
    _stateClassName = NSStringFromClass(stateClass);
}

- (Class)stateClass
{
    if (_stateClassName) {
        Class class = NSClassFromString(_stateClassName);
        if (class) {
            return class;
        }
    }
    return [YASSWZeroState class];
}

- (void)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [NSUserDefaults resetStandardUserDefaults];
    [userDefaults setObject:_startDate forKey:YASStopwatchKeyStartDate];
    [userDefaults setObject:_stateClassName forKey:YASStopwatchKeyState];
    [userDefaults setDouble:_stopTime forKey:YASStopwatchKeyStopTime];
    [userDefaults setObject:_laps forKey:YASStopwatchKeyLaps];
    [userDefaults setInteger:_lapIndex forKey:YASStopwatchKeyLapIndex];
    [userDefaults setDouble:_countdownTime forKey:YASStopwatchKeyCountdownTime];
}

+ (void)reset
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

#pragma mark - Private

- (void)_register
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{YASStopwatchKeyCountdownTime: @(-5.0),
                                     YASStopwatchKeyLaps: @[@(0.0)],
                                     YASStopwatchKeyState: NSStringFromClass([YASSWZeroState class])}];
}

- (void)_load
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.startDate = [userDefaults objectForKey:YASStopwatchKeyStartDate];
    self.stateClassName = [userDefaults stringForKey:YASStopwatchKeyState];
    self.stopTime = [userDefaults doubleForKey:YASStopwatchKeyStopTime];
    self.laps = [[userDefaults objectForKey:YASStopwatchKeyLaps] mutableCopy];
    self.lapIndex = [userDefaults integerForKey:YASStopwatchKeyLapIndex];
    self.countdownTime = [userDefaults doubleForKey:YASStopwatchKeyCountdownTime];
}

@end
