//
//  YAS2DNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "YAS2DMesh.h"
#import <CoreGraphics/CoreGraphics.h>

using namespace simd;

@class YAS2DRenderer, YAS2DTouch, YAS2DNode;

@interface YAS2DEncodeInfo : NSObject

@property (nonatomic, readonly) MTLRenderPassDescriptor *renderPassDescriptor;
@property (nonatomic, readonly) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, readonly) id<MTLRenderPipelineState> pipelineStateForUnuseTexture;
@property (nonatomic, readonly) NSMutableArray *meshes;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRenderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor 
                               pipelineState:(id<MTLRenderPipelineState>)pipelineState 
                pipelineStateForUnuseTexture:(id<MTLRenderPipelineState>)pipelineStateForUnuseTexture;
- (void)addMesh:(YAS2DMesh *)mesh;

@end

@interface YAS2DRenderInfo : NSObject

@property (nonatomic, readonly) NSEnumerator *encodeInfoEnumerator;
@property (nonatomic, readonly) YAS2DEncodeInfo *currentEncodeInfo;
@property (nonatomic) float4x4 renderMatrix;
@property (nonatomic) float4x4 touchMatrix;

- (void)pushRenderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor 
                   pipelineState:(id<MTLRenderPipelineState>)pipelineState 
    pipelineStateForUnuseTexture:(id<MTLRenderPipelineState>)pipelineStateForUnuseTexture;
- (void)popRenderPassDescriptor;

@end

@interface YAS2DNode : NSObject

@property (nonatomic) float2 position;
@property (nonatomic) float angle;
@property (nonatomic) float2 scale;
@property (nonatomic) float4 color;
@property (nonatomic) YAS2DMesh *mesh;
@property (nonatomic) YAS2DTouch *touch;
@property (nonatomic) BOOL enabled;

@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, weak, readonly) YAS2DNode *parent;
@property (nonatomic, weak) YAS2DRenderer *renderer;

- (void)addSubNode:(YAS2DNode *)subNode;
- (void)removeFromSuperNode;

- (void)updateRenderInfo:(YAS2DRenderInfo *)renderInfo;

- (void)setupMetalBuffer:(id<MTLDevice>)device;

// subclass
@property (nonatomic, readonly) float4x4 renderMatrix;
@property (nonatomic, readonly) float4x4 touchMatrix;

- (void)updateMatrixForRender:(float4x4)matrix;
- (void)updateTouchForRender:(float4x4)touchMatrix;

@end
