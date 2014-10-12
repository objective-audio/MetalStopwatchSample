//
//  YASSWStrokeNeedleNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWStrokeNeedleNode.h"

static const uint16_t indices[36] = {
    0, 4, 5, 0, 5, 8, 
    0, 8, 2, 2, 8, 9, 
    2, 9, 3, 3, 9, 10, 
    3, 10, 11, 3, 11, 6, 
    1, 3, 6, 1, 6, 7, 
    0, 1, 7, 0, 7, 4,
};

@implementation YASSWStrokeNeedleNode

- (instancetype)initWithSize:(MTLSize)size lineWidth:(float)lineWidth
{
    self = [super init];
    if (self) {
        YAS2DMesh *mesh = [[YAS2DMesh alloc] initWithVertexCount:12 indexCount:36 dynamic:NO];
        self.mesh = mesh;
        vertex2d_t *vertexPointer = mesh.vertexPointer;
        
        const float2 bottomLeft = {-0.2f, 0.0f};
        const float2 bottomRight = {0.2f, 0.0f};
        const float2 topLeft = {-(float)size.width * 0.5f, (float)size.height};
        const float2 topRight = {(float)size.width * 0.5f, (float)size.height};
        
        vertexPointer[0].position = bottomLeft;
        vertexPointer[1].position = bottomRight;
        vertexPointer[2].position = topLeft;
        vertexPointer[3].position = topRight;
        vertexPointer[4].position = bottomLeft + (float2){0.0f, -lineWidth};
        vertexPointer[5].position = bottomLeft + (float2){-lineWidth, 0.0f};
        vertexPointer[6].position = bottomRight + (float2){lineWidth, 0.0f};
        vertexPointer[7].position = bottomRight + (float2){0.0f, -lineWidth};
        vertexPointer[8].position = topLeft + (float2){-lineWidth, 0.0f};
        vertexPointer[9].position = topLeft + (float2){0.0f, lineWidth};
        vertexPointer[10].position = topRight + (float2){0.0f, lineWidth};
        vertexPointer[11].position = topRight + (float2){lineWidth, 0.0f};
        
        memcpy(mesh.indexPointer, indices, sizeof(uint16_t) * 36);
    }
    return self;
}

@end
