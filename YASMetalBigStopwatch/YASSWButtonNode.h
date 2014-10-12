//
//  YASSWButtonNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DNode.h"

@class YAS2DSquareNode;

@interface YASSWButtonNode : YAS2DNode

@property (nonatomic, readonly) YAS2DSquareNode *baseNode;
@property (nonatomic, readonly) YAS2DSquareNode *selectedNode;
@property (nonatomic, readonly) YAS2DSquareNode *flashNode;

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, copy) void (^touchEnded)(void);
@property (nonatomic) BOOL touchEnabled;

@property (nonatomic) float4 baseColor;
@property (nonatomic) float4 unselectedColor;
@property (nonatomic) float4 selectedColor;
@property (nonatomic) float4 flashColor;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame;

@end
