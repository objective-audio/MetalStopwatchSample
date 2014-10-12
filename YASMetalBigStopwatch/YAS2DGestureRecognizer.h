//
//  YAS2DGestureRecognizer.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <UIKit/UIKit.h>

@class YAS2DTouch;

@interface YAS2DGestureRecognizer : UIGestureRecognizer

@property (nonatomic, readonly) YAS2DTouch *current2DTouch;

- (void)setNeedsUpdateTouchArray;
- (void)clearTouchArrayIfNeeded;
- (void)addTouchIfNeeded:(YAS2DTouch *)touch;
- (void)finalizeTouchArray;

@end
