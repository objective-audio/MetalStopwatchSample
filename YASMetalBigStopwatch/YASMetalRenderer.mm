//
//  YASMetalRenderer.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASMetalRenderer.h"
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "YAS2DTransforms.h"

static const long YASDynamicConstantBufferMaxBytes = 1024 * 1024;
static const long YASInFlightCommandBufferCount = 2;

@interface YASMetalRenderer ()

@property (nonatomic) UIView *view;

@end

@implementation YASMetalRenderer {
    id<MTLBuffer> _dynamicConstantBuffer[YASInFlightCommandBufferCount];
    uint8_t _constantDataBufferIndex;
    
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLLibrary> _defaultLibrary;
    
    dispatch_semaphore_t _inflight_semaphore;
}

- (instancetype)initWithView:(YASMetalView *)view
{
    self = [super init];
    if (self) {
        _sampleCount = 4;
        _depthPixelFormat = MTLPixelFormatInvalid;
        _stencilPixelFormat = MTLPixelFormatInvalid;
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];
        _defaultLibrary = [_device newDefaultLibrary];
        assert(_defaultLibrary);
        _constantDataBufferIndex = 0;
        _inflight_semaphore = dispatch_semaphore_create(YASInFlightCommandBufferCount);
        
        for (NSInteger i = 0; i < YASInFlightCommandBufferCount; i++) {
            _dynamicConstantBuffer[i] = [_device newBufferWithLength:YASDynamicConstantBufferMaxBytes options:0];
        }
        
        self.view = view;
        [self configure:view];
    }
    return self;
}

#pragma mark - Accessor

- (id<MTLBuffer>)currentDynamicConstantBuffer
{
    return _dynamicConstantBuffer[_constantDataBufferIndex];
}

- (void)setDynamicConstantBufferOffset:(NSUInteger)dynamicConstantBufferOffset
{
    assert(dynamicConstantBufferOffset < YASDynamicConstantBufferMaxBytes);
    _dynamicConstantBufferOffset = dynamicConstantBufferOffset;
}

#pragma mark - Delegate

- (void)configure:(YASMetalView *)view
{
    view.sampleCount = _sampleCount;
    
    id<MTLFunction> fragmentProgram = [_defaultLibrary newFunctionWithName:@"fragment2d"];
    assert(fragmentProgram);
    
    id<MTLFunction> fragmentProgramForUnuseTexture = [_defaultLibrary newFunctionWithName:@"fragment2d_unuse_texture"];
    assert(fragmentProgramForUnuseTexture);
    
    id<MTLFunction> blurHorizontalFragmentProgram = [_defaultLibrary newFunctionWithName:@"fragment2d_blur_horizontal"];
    assert(blurHorizontalFragmentProgram);
    
    id<MTLFunction> blurVerticalFragmentProgram = [_defaultLibrary newFunctionWithName:@"fragment2d_blur_vertical"];
    assert(blurVerticalFragmentProgram);
    
    id<MTLFunction> vertexProgram = [_defaultLibrary newFunctionWithName:@"vertex2d"];
    assert(vertexProgram);
    
    MTLRenderPipelineColorAttachmentDescriptor *colorDescriptor = [MTLRenderPipelineColorAttachmentDescriptor new];
    colorDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    colorDescriptor.blendingEnabled = YES;
    colorDescriptor.rgbBlendOperation = MTLBlendOperationAdd;
    colorDescriptor.alphaBlendOperation = MTLBlendOperationAdd;
    colorDescriptor.sourceRGBBlendFactor = MTLBlendFactorOne;
    colorDescriptor.sourceAlphaBlendFactor = MTLBlendFactorOne;
    colorDescriptor.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    colorDescriptor.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineStateDescriptor.sampleCount = _sampleCount;
    pipelineStateDescriptor.vertexFunction = vertexProgram;
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    [pipelineStateDescriptor.colorAttachments setObject:colorDescriptor atIndexedSubscript:0];
    pipelineStateDescriptor.depthAttachmentPixelFormat = _depthPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = _stencilPixelFormat;
    _multiSamplePipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    pipelineStateDescriptor.fragmentFunction = fragmentProgramForUnuseTexture;
    _multiSamplePipelineStateForUnuseTexture = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    pipelineStateDescriptor.sampleCount = 1;
    _pipelineStateForUnuseTexture = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    pipelineStateDescriptor.fragmentFunction = fragmentProgram;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    pipelineStateDescriptor.fragmentFunction = blurHorizontalFragmentProgram;
    pipelineStateDescriptor.sampleCount = 1;
    _blurHorizontalPipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    pipelineStateDescriptor.fragmentFunction = blurVerticalFragmentProgram;
    pipelineStateDescriptor.sampleCount = 1;
    _blurVerticalPipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
}

- (void)metalViewDidResize:(YASMetalView *)view
{
    CGRect viewBounds = view.bounds;
    float halfWidth = viewBounds.size.width * 0.5;
    float halfHeight = viewBounds.size.height * 0.5;
    _projectionMatrix = yas2d_ortho(-halfWidth, halfWidth, -halfHeight, halfHeight, -1.0f, 1.0f);
}

- (void)metalViewRender:(YASMetalView *)view
{
    dispatch_semaphore_wait(_inflight_semaphore, DISPATCH_TIME_FOREVER);
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.renderPassDescriptor;
    assert(renderPassDescriptor);
    
    _dynamicConstantBufferOffset = 0;
    
    [self renderWithCommandBuffer:commandBuffer renderPassDescriptor:renderPassDescriptor];
    
    __block dispatch_semaphore_t block_semaphore = _inflight_semaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
        dispatch_semaphore_signal(block_semaphore);
    }];
    
    _constantDataBufferIndex = (_constantDataBufferIndex + 1) % YASInFlightCommandBufferCount;
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)renderWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer renderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor
{
    // Virtual
}

@end
