//
//  YASMetalRenderer.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <UIKit/UIKit.h>
#import "YASMetalViewController.h"
#import "YASMetalView.h"
#import <simd/simd.h>

using namespace simd;

@interface YASMetalRenderer : NSObject <YASMetalViewDelegate>

@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, readonly) id<MTLLibrary> defaultLibrary;
@property (nonatomic, readonly) MTLPixelFormat depthPixelFormat;
@property (nonatomic, readonly) MTLPixelFormat stencilPixelFormat;
@property (nonatomic, readonly) NSUInteger sampleCount;
@property (nonatomic, readonly) id<MTLRenderPipelineState> multiSamplePipelineState;
@property (nonatomic, readonly) id<MTLRenderPipelineState> multiSamplePipelineStateForUnuseTexture;
@property (nonatomic, readonly) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, readonly) id<MTLRenderPipelineState> pipelineStateForUnuseTexture;
@property (nonatomic, readonly) id<MTLRenderPipelineState> blurHorizontalPipelineState;
@property (nonatomic, readonly) id<MTLRenderPipelineState> blurVerticalPipelineState;

@property (nonatomic, readonly) float4x4 projectionMatrix;
@property (nonatomic, readonly) id<MTLBuffer> currentDynamicConstantBuffer;
@property (nonatomic) NSUInteger dynamicConstantBufferOffset;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(YASMetalView *)view;

@end
