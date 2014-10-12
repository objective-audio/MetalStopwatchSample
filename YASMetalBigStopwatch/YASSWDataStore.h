//
//  YASSWDataStore.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <Foundation/Foundation.h>

extern NSString *const YASStopwatchKeyStartDate;
extern NSString *const YASStopwatchKeyState;
extern NSString *const YASStopwatchKeyStopTime;
extern NSString *const YASStopwatchKeyLaps;
extern NSString *const YASStopwatchKeyLapIndex;
extern NSString *const YASStopwatchKeyCountdownTime;

@class YASSWTimeController;

@interface YASSWDataStore : NSObject

@property (nonatomic) Class stateClass;
@property (nonatomic) NSTimeInterval stopTime;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSMutableArray *laps;
@property (nonatomic) NSInteger lapIndex;
@property (nonatomic) NSTimeInterval countdownTime;

- (void)save;

+ (void)reset;

@end
