//
//  YASSWState.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <Foundation/Foundation.h>

@class YASSWTimeController;

@interface YASSWState : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStopwatchController:(YASSWTimeController *)controller;

- (void)enter;
- (void)exit;
- (void)main;
- (void)sub;
- (void)next;
- (void)back;
- (NSTimeInterval)time;

@end

@interface YASSWZeroState : YASSWState

@end

@interface YASSWPlayState : YASSWState

@end

@interface YASSWStopState : YASSWState

@end

@interface YASSWCountdownState : YASSWState

@end
