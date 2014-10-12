//
//  YAS2DMesh.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "YAS2DSharedTypes.h"

using namespace simd;

@class YAS2DRenderer, YAS2DTexture, YAS2DEncodeInfo;

@interface YAS2DMesh : NSObject

@property (nonatomic) YAS2DTexture *texture;

@property (nonatomic) MTLPrimitiveType primitiveType;
@property (nonatomic) float4 color;
@property (nonatomic, readonly) vertex2d_t *vertexPointer;
@property (nonatomic) NSUInteger vertexCount;
@property (nonatomic, readonly) NSUInteger vertexMaxCount;
@property (nonatomic, readonly) uint16_t *indexPointer;
@property (nonatomic) NSUInteger indexCount;
@property (nonatomic, readonly) NSUInteger indexMaxCount;
@property (nonatomic, readonly, getter=isDynamic) BOOL dynamic;
@property (nonatomic) float4x4 matrix;
@property (nonatomic) float blurCoef;

- (instancetype)initWithVertexCount:(NSUInteger)vertexCount indexCount:(NSUInteger)indexCount dynamic:(BOOL)dynamic;

- (void)setupMetalBuffer:(id<MTLDevice>)device;

- (void)setNeedsUpdateRenderBuffer;
- (void)metalViewRender:(YAS2DRenderer *)renderer encoder:(id<MTLRenderCommandEncoder>)encoder encodeInfo:(YAS2DEncodeInfo *)encodeInfo;

@end
