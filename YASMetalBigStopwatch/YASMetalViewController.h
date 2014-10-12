//
//  YASMetalViewController.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <UIKit/UIKit.h>

@interface YASMetalViewController : UIViewController

@property (nonatomic, getter=isPaused) BOOL paused;

- (void)startRender;
- (void)stopRender;

- (void)viewWillRender;

@end
