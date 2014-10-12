//
//  YASMetalBigStopwatchControllerTests.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "YASSWTimeController.h"
#import "YASSWDataStore.h"
#import "YASSWState.h"

@interface YASMetalBigStopwatchControllerTests : XCTestCase <YASSWTimeControllerDelegate>

@property (nonatomic, strong) YASSWTimeController *controller;

@end

@implementation YASMetalBigStopwatchControllerTests

- (void)setUp {
    [super setUp];
    [YASSWDataStore reset];
    self.controller = [[YASSWTimeController alloc] initWithDelegate:nil];
}

- (void)tearDown {
    self.controller = nil;
    [super tearDown];
}

- (void)testStateChanges {
    XCTAssertEqualObjects(self.controller.state.class, [YASSWZeroState class]);
    [self.controller main];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWPlayState class]);
    [self.controller main];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWStopState class]);
    [self.controller main];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWPlayState class]);
    [self.controller sub];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWPlayState class]);
    [self.controller main];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWStopState class]);
    [self.controller sub];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWZeroState class]);
    [self.controller sub];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWCountdownState class]);
    [self.controller sub];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWZeroState class]);
    [self.controller sub];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWCountdownState class]);
    [self.controller main];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWPlayState class]);
    [self.controller main];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWStopState class]);
    [self.controller sub];
    XCTAssertEqualObjects(self.controller.state.class, [YASSWZeroState class]);
}

- (void)testLaps
{
    XCTAssertEqual(self.controller.laps.count, 1);
    XCTAssertEqual(self.controller.lapIndex, 0);
    
    NSInteger lapCount = self.controller.laps.count;
    
    [self.controller main];
    
    for (NSInteger i = 0; i < 6; i++) {
        [self.controller sub];
        lapCount++;
    }
    
    XCTAssertEqual(self.controller.laps.count, lapCount);
    
    [self.controller main];
    lapCount++;
    
    XCTAssertEqual(self.controller.laps.count, lapCount);
    
    [self.controller main];
    
    XCTAssertEqual(self.controller.laps.count, lapCount);
    
    [self.controller main];
    lapCount++;
    
    XCTAssertEqual(self.controller.laps.count, lapCount);
    
    [self.controller sub];
    
    XCTAssertEqual(self.controller.laps.count, 1);
}

@end
