//
//  YASSWTimeController.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <Foundation/Foundation.h>

@class YASSWState;
@protocol YASSWTimeControllerDelegate;

@interface YASSWTimeController : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id<YASSWTimeControllerDelegate>)delegate;

@property (nonatomic, readonly) YASSWState *state;
@property (nonatomic, readonly) NSTimeInterval time;
@property (nonatomic, readonly) NSInteger lapIndex;
@property (nonatomic, readonly) NSArray *laps;
@property (nonatomic, readonly) NSTimeInterval countdownTime;
@property (nonatomic, readonly) BOOL isLastLapIndex;

- (void)main;
- (void)sub;
- (void)next;
- (void)back;

@end

@protocol YASSWTimeControllerDelegate <NSObject>

@optional

- (void)timeController:(YASSWTimeController *)controller didChangeStateFrom:(Class)stateClass;
- (void)timeControllerDidChangeLap:(YASSWTimeController *)controller;
- (void)timeControllerDidOverZero:(YASSWTimeController *)controller;

@end
