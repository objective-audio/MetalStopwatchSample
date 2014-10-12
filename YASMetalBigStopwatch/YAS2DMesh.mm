//
//  YAS2DMesh.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DMesh.h"
#import "YAS2DRenderer.h"
#import "YAS2DTexture.h"
#import "YAS2DNode.h"

static const NSUInteger YAS2DMeshDynamicBufferCount = 2;

@interface YAS2DMesh ()

@end

@implementation YAS2DMesh {
    BOOL _needsUpdateRenderBuffer;
    NSUInteger _dynamicBufferIndex;
    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _indexBuffer;
    NSMutableData *_vertexData;
    NSMutableData *_indexData;
}

- (instancetype)initWithVertexCount:(NSUInteger)vertexCount indexCount:(NSUInteger)indexCount dynamic:(BOOL)dynamic
{
    self = [super init];
    if (self) {
        _primitiveType = MTLPrimitiveTypeTriangle;
        _vertexMaxCount = _vertexCount = vertexCount;
        _vertexData = [[NSMutableData alloc] initWithLength:vertexCount * sizeof(vertex2d_t)];
        _indexMaxCount = _indexCount = indexCount;
        _indexData = [[NSMutableData alloc] initWithLength:indexCount * sizeof(uint16_t)];
        _dynamic = dynamic;
        _needsUpdateRenderBuffer = YES;
        _dynamicBufferIndex = 0;
        _color = 1.0f;
        _blurCoef = 0;
    }
    return self;
}

- (void)setupMetalBuffer:(id<MTLDevice>)device
{
    NSUInteger vertexLength = _vertexMaxCount * sizeof(vertex2d_t);
    NSUInteger indexLength = _indexMaxCount * sizeof(uint16_t);
    
    if (self.isDynamic) {
        vertexLength *= YAS2DMeshDynamicBufferCount;
        indexLength *= YAS2DMeshDynamicBufferCount;
    }
    
    _vertexBuffer = [device newBufferWithLength:vertexLength options:MTLResourceOptionCPUCacheModeDefault];
    _indexBuffer = [device newBufferWithLength:indexLength options:MTLResourceOptionCPUCacheModeDefault];
}

- (vertex2d_t *)vertexPointer
{
    return (vertex2d_t *)[_vertexData mutableBytes];
}

- (uint16_t *)indexPointer
{
    return (uint16_t *)[_indexData mutableBytes];
}

- (void)setNeedsUpdateRenderBuffer
{
    if (self.isDynamic) {
        _needsUpdateRenderBuffer = YES;
    }
}

- (void)metalViewRender:(YAS2DRenderer *)renderer encoder:(id<MTLRenderCommandEncoder>)encoder encodeInfo:(YAS2DEncodeInfo *)encodeInfo
{
    if (_needsUpdateRenderBuffer) {
        if (self.dynamic) {
            _dynamicBufferIndex = (_dynamicBufferIndex + 1) % YAS2DMeshDynamicBufferCount;
        }
        vertex2d_t *vertexPointer = (vertex2d_t *)[_vertexBuffer contents];
        uint16_t *indexPointer = (uint16_t *)[_indexBuffer contents];
        memcpy(&vertexPointer[_vertexMaxCount * _dynamicBufferIndex], self.vertexPointer, _vertexCount * sizeof(vertex2d_t));
        memcpy(&indexPointer[_indexMaxCount * _dynamicBufferIndex], self.indexPointer, _indexCount * sizeof(uint16_t));
        _needsUpdateRenderBuffer = NO;
    }
    
    if (_indexCount == 0) {
        return;
    }
    
    if (_color.x == 0 &&
        _color.y == 0 &&
        _color.z == 0 &&
        _color.w == 0) {
        return;
    }
    
    NSUInteger vertexBufferOffset = _vertexMaxCount * _dynamicBufferIndex * sizeof(vertex2d_t);
    NSUInteger indexBufferOffset = _indexMaxCount * _dynamicBufferIndex * sizeof(uint16_t);
    NSUInteger constantBufferOffset = renderer.dynamicConstantBufferOffset;
    
    id<MTLBuffer> currentDynamicConstantBuffer = renderer.currentDynamicConstantBuffer;
    uint8_t *constantBuffer = (uint8_t *)[currentDynamicConstantBuffer contents];
    
    uniforms2d_t *uniforms2d = (uniforms2d_t *)(&constantBuffer[constantBufferOffset]);
    uniforms2d->matrix = _matrix;
    uniforms2d->color = _color;
    
    if (_blurCoef > 0) {
        uniforms2d->blurWeightCount = [self calcGaussWeight:uniforms2d->blurWeight];
    }
    
    if (_texture) {
        [encoder setFragmentBuffer:currentDynamicConstantBuffer offset:constantBufferOffset atIndex:0];
        [encoder setRenderPipelineState:encodeInfo.pipelineState];
        [encoder setFragmentTexture:_texture.texture atIndex:0];
        [encoder setFragmentSamplerState:_texture.sampler atIndex:0];
    } else {
        [encoder setRenderPipelineState:encodeInfo.pipelineStateForUnuseTexture];
    }
    
    [encoder setVertexBuffer:_vertexBuffer offset:vertexBufferOffset atIndex:0];
    [encoder setVertexBuffer:currentDynamicConstantBuffer offset:constantBufferOffset atIndex:1];
    
    constantBufferOffset += sizeof(uniforms2d_t);
    
    [encoder drawIndexedPrimitives:_primitiveType indexCount:_indexCount indexType:MTLIndexTypeUInt16 indexBuffer:_indexBuffer indexBufferOffset:indexBufferOffset];
    
    renderer.dynamicConstantBufferOffset = constantBufferOffset;
}

- (uint8_t)calcGaussWeight:(float *)weights
{
    uint8_t count = 0;
    float total = 0.0;
    const float coef = _blurCoef * _blurCoef;
    
    for(NSInteger i = 0; i < YAS2DBlurWeightMaxCount; i++){
        float weight = exp(- 0.5f * i * i / coef);
        weights[i] = weight;
        if (i > 0) {
            weight *= 2.0;
        }
        total += weight;
    }
    
    for(NSInteger i = 0; i < YAS2DBlurWeightMaxCount; i++){
        weights[i] /= total;
        if (weights[i] > 0.005f) {
            count++;
        } else {
            break;
        }
    }
    
    return count;
}

@end
