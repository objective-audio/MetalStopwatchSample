//
//  YASMetalViewController.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASMetalViewController.h"
#import "YASMetalView.h"

@interface YASMetalViewController ()

@end

@implementation YASMetalViewController {
    CADisplayLink *_timer;
    BOOL _paused;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRender];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.paused = NO;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.paused = YES;
}

- (YASMetalView *)metalView
{
    return (YASMetalView *)self.view;
}

#pragma mark -

- (void)viewWillRender
{
    // Virtual
}

- (void)render
{
    [self viewWillRender];
    [self.metalView display];
}

#pragma mark -

- (void)startRender
{
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    _timer.frameInterval = 1;
    [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopRender
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)setPaused:(BOOL)pause
{
    if (_timer && _timer.paused != pause) {
        if(pause == YES) {
            _timer.paused = YES;
            [self.metalView releaseRenderPassDescriptor];
        } else {
            _timer.paused = NO;
        }
    }
}

- (BOOL)isPaused
{
    return _timer.paused;
}

#pragma mark -

- (void)didEnterBackground:(NSNotification *)notification
{
    self.paused = YES;
}

- (void)willEnterForeground:(NSNotification *)notification
{
    self.paused = NO;
}

@end
