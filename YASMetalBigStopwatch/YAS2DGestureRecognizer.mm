//
//  YAS2DGestureRecognizer.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DGestureRecognizer.h"
#import "YAS2DTouch.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <simd/simd.h>

using namespace simd;

@interface YAS2DGestureRecognizer ()

@property (nonatomic) NSMutableArray *touchArray;

@end

@implementation YAS2DGestureRecognizer {
    BOOL _needsUpdateTouchArray;
    BOOL _isTracking;
    UITouch *_currentUITouch;
    CGPoint _startLocation;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        _isTracking = NO;
    }
    return self;
}

#pragma mark -

- (void)beginTracking:(UITouch *)uiTouch touch:(YAS2DTouch *)touch
{
    if (!_isTracking) {
        _isTracking = YES;
        _currentUITouch = uiTouch;
        _current2DTouch = touch;
        _startLocation = [uiTouch locationInView:self.view];
        self.state = UIGestureRecognizerStateBegan;
        if (_current2DTouch.touchBegan) {
            _current2DTouch.touchBegan();
        }
    }
}

- (void)endTracking
{
    if (_isTracking) {
        _isTracking = NO;
        self.state = UIGestureRecognizerStateEnded;
        if (_current2DTouch.touchEnded) {
            _current2DTouch.touchEnded();
        }
        _currentUITouch = nil;
        _current2DTouch = nil;
    }
}

- (void)cancelTracking
{
    if (_isTracking) {
        _isTracking = NO;
        self.state = UIGestureRecognizerStateCancelled;
        if (_current2DTouch.touchCancelled) {
            _current2DTouch.touchCancelled();
        }
        _current2DTouch = nil;
        _currentUITouch = nil;
    }
}

#pragma mark - UIGestureRecognizer Subclass

- (void)reset
{
    [super reset];
    [self cancelTracking];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (!_isTracking) {
        for (UITouch *uiTouch in touches) {
            YAS2DTouch *touch = [self hitTest:uiTouch];
            if (touch) {
                [self beginTracking:uiTouch touch:touch];
                break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{    
    [super touchesMoved:touches withEvent:event];
    
    if (_isTracking) {
        if ([touches containsObject:_currentUITouch]) {
            YAS2DTouch *touch = [self hitTest:_currentUITouch];
            CGFloat distance = [self distance];
            if ([touch isEqual:_current2DTouch] && distance < 80.0) {
                self.state = UIGestureRecognizerStateChanged;
            } else {
                [self cancelTracking];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_isTracking) {
        if ([touches containsObject:_currentUITouch]) {
            YAS2DTouch *touch = [self hitTest:_currentUITouch];
            if (touch) {
                [self endTracking];
            } else {
                [self cancelTracking];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self cancelTracking];
}

#pragma mark - Touch Array

- (void)setNeedsUpdateTouchArray
{
    _needsUpdateTouchArray = YES;
}

- (void)clearTouchArrayIfNeeded
{
    if (_needsUpdateTouchArray) {
        _touchArray = nil;
    }
}

- (void)addTouchIfNeeded:(YAS2DTouch *)touch
{
    if (!_needsUpdateTouchArray || !touch) {
        return;
    }
    
    if (!_touchArray) {
        _touchArray = [[NSMutableArray alloc] initWithCapacity:16];
    }
    
    [_touchArray insertObject:touch atIndex:0];
}

- (void)finalizeTouchArray
{
    _needsUpdateTouchArray = NO;
}

- (YAS2DTouch *)hitTest:(UITouch *)uiTouch
{
    UIView *view = self.view;
    CGPoint location = [uiTouch locationInView:view];
    CGSize viewSize = view.bounds.size;
    float2 loc = {(float)(location.x / viewSize.width * 2.0 - 1.0), (float)(- (location.y / viewSize.height * 2.0 - 1.0))};
    
    for (YAS2DTouch *touch in _touchArray) {
        if ([touch hitTest:loc]) {
            return touch;
        }
    }
    
    return nil;
}

- (CGFloat)distance
{
    CGPoint location = [_currentUITouch locationInView:self.view];
    return sqrtf(powf(location.x - _startLocation.x, 2) + powf(location.y - _startLocation.y, 2));
}

@end
