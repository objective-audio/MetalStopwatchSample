//
//  YASMetalBigStopwatchDataStoreTest.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "YASSWDataStore.h"
#import "YASSWState.h"

@interface YASMetalBigStopwatchDataStoreTest : XCTestCase

@end

@implementation YASMetalBigStopwatchDataStoreTest

- (void)setUp {
    [super setUp];
    [YASSWDataStore reset];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [YASSWDataStore reset];
}

- (void)testDataStore {
    YASSWDataStore *dataStore = [[YASSWDataStore alloc] init];
    
    Class initialClass = [YASSWZeroState class];
    double initialStopTime = 0.0;
    NSArray *initialLaps = @[@(0.0)];
    NSInteger initialLapIndex = 0;
    double initialCountdownTime = -5.0;
    
    XCTAssertEqualObjects(dataStore.stateClass, initialClass, @"");
    XCTAssertEqual(dataStore.stopTime, initialStopTime);
    XCTAssertNil(dataStore.startDate);
    XCTAssertNotNil(dataStore.laps);
    XCTAssertEqual(dataStore.laps.count, initialLaps.count);
    XCTAssertEqualObjects(dataStore.laps[0], initialLaps[0]);
    XCTAssertEqual(dataStore.lapIndex, initialLapIndex);
    XCTAssertEqual(dataStore.countdownTime, initialCountdownTime);
    
    Class stateClass = [YASSWPlayState class];
    double stopTime = 2378423.023;
    NSDate *startDate = [[NSDate alloc] init];
    NSArray *laps = @[@(0.0), @(2.0212), @(1242.3784), @(45002.28374)];
    NSInteger lapIndex = 3;
    double countdownTime = 3278204.4783;
    
    dataStore.stateClass = stateClass;
    dataStore.stopTime = stopTime;
    dataStore.startDate = startDate;
    NSMutableArray *dataStoreLaps = dataStore.laps;
    for (NSInteger i = 1; i < laps.count; i++) {
        [dataStoreLaps addObject:laps[i]];
    }
    dataStore.lapIndex = lapIndex;
    dataStore.countdownTime = countdownTime;
    
    XCTAssertEqualObjects(dataStore.stateClass, stateClass);
    XCTAssertEqual(dataStore.stopTime, stopTime);
    XCTAssertEqualObjects(dataStore.startDate, startDate);
    [dataStoreLaps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertEqualObjects(obj, laps[idx]);
    }];
    XCTAssertEqual(dataStore.lapIndex, lapIndex);
    XCTAssertEqual(dataStore.countdownTime, countdownTime);
    
    [dataStore save];
    
    dataStore = nil;
    dataStore = [[YASSWDataStore alloc] init];
    
    XCTAssertEqualObjects(dataStore.stateClass, stateClass);
    XCTAssertEqual(dataStore.stopTime, stopTime);
    XCTAssertEqualObjects(dataStore.startDate, startDate);
    [dataStoreLaps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertEqualObjects(obj, laps[idx]);
    }];
    XCTAssertEqual(dataStore.lapIndex, lapIndex);
    XCTAssertEqual(dataStore.countdownTime, countdownTime);
}

@end
