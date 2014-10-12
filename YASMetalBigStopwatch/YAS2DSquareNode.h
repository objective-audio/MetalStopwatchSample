//
//  YAS2DSquareNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <UIKit/UIKit.h>
#import "YAS2DNode.h"

@class YAS2DAtlasInfo;

@interface YAS2DSquareNode : YAS2DNode

@property (nonatomic, readonly) NSUInteger squareCount;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSquareCount:(NSUInteger)squareCount dynamic:(BOOL)dynamic;

@end

@interface YAS2DMesh (YAS2DSquareNode)

- (void)setVertexWithRect:(CGRect)rect atSquareIndex:(NSUInteger)squareIndex;
- (void)setVertexWithRect:(CGRect)rect atSquareIndex:(NSUInteger)squareIndex matrix:(float4x4)matrix;
- (void)setVertex:(const vertex2d_t *)inPointer atSquareIndex:(NSUInteger)squareIndex matrix:(float4x4)matrix;
- (void)setTexCoordsWithRegion:(MTLRegion)pixelRegion atSquareIndex:(NSUInteger)squareIndex;

- (void)setSquareIndex:(NSUInteger)squareIndex toElementIndex:(NSUInteger)index;

- (vertex2d_t *)vertexPointerAtSquareIndex:(NSUInteger)squareIndex;

@end
