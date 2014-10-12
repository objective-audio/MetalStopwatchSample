//
//  YAS2DSquareNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DSquareNode.h"
#import "YAS2DMesh.h"
#import "YAS2DTexture.h"

@implementation YAS2DSquareNode

- (instancetype)initWithSquareCount:(NSUInteger)squareCount dynamic:(BOOL)dynamic
{
    self = [super init];
    if (self) {
        _squareCount = squareCount;
        
        self.mesh = [[YAS2DMesh alloc] initWithVertexCount:squareCount * 4 indexCount:squareCount * 6 dynamic:dynamic];
        
        for (NSInteger i = 0; i < squareCount; i++) {
            [self.mesh setSquareIndex:i toElementIndex:i];
        }
    }
    return self;
}

@end

@implementation YAS2DMesh (YAS2DSquareNode)

- (void)setVertexWithRect:(CGRect)rect atSquareIndex:(NSUInteger)squareIndex
{
    [self setVertexWithRect:rect atSquareIndex:squareIndex matrix:matrix_identity_float4x4];
}

- (void)setVertexWithRect:(CGRect)rect atSquareIndex:(NSUInteger)squareIndex matrix:(float4x4)matrix
{
    vertex2d_t *pointer = [self vertexPointerAtSquareIndex:squareIndex];
    
    float2 positions[4];
    positions[0].x = positions[2].x = CGRectGetMinX(rect);
    positions[0].y = positions[1].y = CGRectGetMinY(rect);
    positions[1].x = positions[3].x = CGRectGetMaxX(rect);
    positions[2].y = positions[3].y = CGRectGetMaxY(rect);
    
    for (NSInteger i = 0; i < 4; i++) {
        float4 pos = matrix * (float4){positions[i].x, positions[i].y, 0, 1};
        pointer[i].position = {pos.x, pos.y};
    }
    
    [self setNeedsUpdateRenderBuffer];
}

- (void)setVertex:(const vertex2d_t *)inPointer atSquareIndex:(NSUInteger)squareIndex matrix:(float4x4)matrix
{
    vertex2d_t *outPointer = [self vertexPointerAtSquareIndex:squareIndex];
    
    for (NSInteger i = 0; i < 4; i++) {
        float4 pos = matrix * (float4){inPointer[i].position.x, inPointer[i].position.y, 0, 1};
        outPointer[i].position = {pos.x, pos.y};
        outPointer[i].texCoord = inPointer[i].texCoord;
    }
    
    [self setNeedsUpdateRenderBuffer];
}

- (void)setTexCoordsWithRegion:(MTLRegion)pixelRegion atSquareIndex:(NSUInteger)squareIndex
{
    assert(self.texture);
    
    vertex2d_t *pointer = [self vertexPointerAtSquareIndex:squareIndex];
    
    float minX = pixelRegion.origin.x;
    float minY = pixelRegion.origin.y;
    float maxX = minX + pixelRegion.size.width;
    float maxY = minY + pixelRegion.size.height;
    
    pointer[0].texCoord[0] = pointer[2].texCoord[0] = minX;
    pointer[0].texCoord[1] = pointer[1].texCoord[1] = maxY;
    pointer[1].texCoord[0] = pointer[3].texCoord[0] = maxX;
    pointer[2].texCoord[1] = pointer[3].texCoord[1] = minY;
    
    [self setNeedsUpdateRenderBuffer];
}

- (void)setSquareIndex:(NSUInteger)squareIndex toElementIndex:(NSUInteger)elementIndex
{
    uint16_t *indexPointer = self.indexPointer;
    NSUInteger topElement = elementIndex * 6;
    NSUInteger topIndex = squareIndex * 4;
    indexPointer[topElement] = topIndex;
    indexPointer[topElement + 1] = indexPointer[topElement + 4] = topIndex + 2;
    indexPointer[topElement + 2] = indexPointer[topElement + 3] = topIndex + 1;
    indexPointer[topElement + 5] = topIndex + 3;
    
    [self setNeedsUpdateRenderBuffer];
}

- (vertex2d_t *)vertexPointerAtSquareIndex:(NSUInteger)squareIndex
{
    return &self.vertexPointer[squareIndex * 4];
}

@end
