//
//  YASSWFillNeedleNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWFillNeedleNode.h"

@implementation YASSWFillNeedleNode

- (instancetype)initWithSize:(MTLSize)size
{
    self = [super init];
    if (self) {
        YAS2DMesh *mesh = [[YAS2DMesh alloc] initWithVertexCount:4 indexCount:6 dynamic:NO];
        self.mesh = mesh;
        vertex2d_t *vertexPointer = mesh.vertexPointer;
        vertexPointer[0].position = {-0.2f, 0.0f};
        vertexPointer[1].position = {0.2f, 0.0f};
        vertexPointer[2].position = {-(float)size.width * 0.5f, (float)size.height};
        vertexPointer[3].position = {(float)size.width * 0.5f, (float)size.height};
        uint16_t *indexPointer = mesh.indexPointer;
        indexPointer[0] = 0;
        indexPointer[1] = indexPointer[4] = 2;
        indexPointer[2] = indexPointer[3] = 1;
        indexPointer[5] = 3;
    }
    return self;
}

@end
