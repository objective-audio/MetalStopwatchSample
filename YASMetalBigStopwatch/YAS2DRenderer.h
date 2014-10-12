//
//  YAS2DRenderer.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASMetalRenderer.h"

@class YAS2DNode, YAS2DAction, YAS2DTouch;

@interface YAS2DRenderer : YASMetalRenderer

@property (nonatomic, readonly) YAS2DNode *rootNode;

- (void)setupMetalBuffer;

- (void)addAction:(YAS2DAction *)action;
- (void)removeActionForTarget:(YAS2DNode *)target;

- (void)setNeedsUpdateTouchArray;
- (void)addTouchIfNeeded:(YAS2DTouch *)touch;

@end
