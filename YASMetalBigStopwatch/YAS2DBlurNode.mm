//
//  YAS2DBlurNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DBlurNode.h"
#import "YAS2DTexture.h"
#import "YAS2DImage.h"
#import "YAS2DRenderer.h"
#import "YAS2DTransforms.h"

using namespace simd;

@implementation YAS2DBlurNode {
    float4x4 _blurProjectionMatrix;
    float4x4 _inProjectionMatrix;
    YAS2DMesh *_inMesh;
    YAS2DMesh *_blurMesh;
    YAS2DMesh *_outMesh;
    MTLRenderPassDescriptor *_outRenderPassDescriptor;
    MTLRenderPassDescriptor *_blurRenderPassDescriptor;
    MTLRenderPassDescriptor *_inRenderPassDescriptor;
    YAS2DTexture *_outTexture;
    YAS2DTexture *_blurTexture;
    YAS2DTexture *_inTexture;
    MTLSize _textureSize;
}

- (instancetype)initWithFrame:(CGRect)frame textureSize:(MTLSize)textureSize
{
    NSUInteger squareCount = 1;
    
    self = [super initWithSquareCount:squareCount dynamic:NO];
    if (self) {
        _frame = frame;
        _textureSize = textureSize;
        
        _outMesh = self.mesh;
        self.mesh = nil;
        
        NSUInteger vertexCount = _outMesh.vertexCount;
        NSUInteger indexCount = _outMesh.indexCount;
        
        _blurMesh = [[YAS2DMesh alloc] initWithVertexCount:vertexCount indexCount:indexCount dynamic:NO];
        _inMesh = [[YAS2DMesh alloc] initWithVertexCount:vertexCount indexCount:indexCount dynamic:NO];
        
        for (NSInteger i = 0; i < squareCount; i++) {
            [_blurMesh setSquareIndex:i toElementIndex:i];
            [_inMesh setSquareIndex:i toElementIndex:i];
        }
    }
    return self;
}

#pragma mark -

- (void)setCoef:(float)coef
{
    _blurMesh.blurCoef = coef;
    _inMesh.blurCoef = coef;
}

- (float)coef
{
    return _blurMesh.blurCoef;
}

#pragma mark - Render

- (void)updateRenderInfo:(YAS2DRenderInfo *)renderInfo
{
    if (self.coef > 1.0) {
        [self updateMatrixForRender:renderInfo.renderMatrix];
        [self updateTouchForRender:renderInfo.touchMatrix];
        _outMesh.matrix = self.renderMatrix;
        _blurMesh.matrix = _blurProjectionMatrix;
        _inMesh.matrix = _blurProjectionMatrix;
        
        [renderInfo.currentEncodeInfo addMesh:_outMesh];
        
        [renderInfo pushRenderPassDescriptor:_outRenderPassDescriptor 
                               pipelineState:self.renderer.blurVerticalPipelineState 
                pipelineStateForUnuseTexture:nil];
        
        [renderInfo.currentEncodeInfo addMesh:_blurMesh];
        
        [renderInfo pushRenderPassDescriptor:_blurRenderPassDescriptor 
                               pipelineState:self.renderer.blurHorizontalPipelineState 
                pipelineStateForUnuseTexture:nil];
        
        [renderInfo.currentEncodeInfo addMesh:_inMesh];
        
        [renderInfo pushRenderPassDescriptor:_inRenderPassDescriptor 
                               pipelineState:self.renderer.pipelineState 
                pipelineStateForUnuseTexture:self.renderer.pipelineStateForUnuseTexture];
        
        for (YAS2DNode *subNode in self.children) {
            renderInfo.renderMatrix = _inProjectionMatrix;
            renderInfo.touchMatrix = self.touchMatrix;
            [subNode updateRenderInfo:renderInfo];
        }
        
        [renderInfo popRenderPassDescriptor];
        [renderInfo popRenderPassDescriptor];
        [renderInfo popRenderPassDescriptor];
    } else {
        [super updateRenderInfo:renderInfo];
    }
}

- (void)setupMetalBuffer:(id<MTLDevice>)device
{
    CGRect frame = self.frame;
    CGRect meshFrame = CGRectMake(-CGRectGetWidth(frame) * 0.5, -CGRectGetHeight(frame) * 0.5, CGRectGetWidth(frame), CGRectGetHeight(frame));
    
    float halfWidth = frame.size.width * 0.5;
    float halfHeight = frame.size.height * 0.5;
    
    _blurProjectionMatrix = yas2d_ortho(-halfWidth, halfWidth, -halfHeight, halfHeight, -1, 1);
    _inProjectionMatrix = yas2d_ortho(CGRectGetMinX(frame), CGRectGetMaxX(frame), CGRectGetMinY(frame), CGRectGetMaxY(frame), -1, 1);
    
    MTLRegion region = {0};
    region.size = _textureSize;
    CGFloat scaleFactor = 1.0;
    
    _outTexture = [[YAS2DTexture alloc] initWithPointSize:region.size scaleFactor:scaleFactor format:MTLPixelFormatBGRA8Unorm];
    [_outTexture setupMetalBuffer:device];
    _outMesh.texture = _outTexture;
    [_outMesh setVertexWithRect:frame atSquareIndex:0];
    [_outMesh setTexCoordsWithRegion:region atSquareIndex:0];
    
    _blurTexture = [[YAS2DTexture alloc] initWithPointSize:region.size scaleFactor:scaleFactor format:MTLPixelFormatBGRA8Unorm];
    [_blurTexture setupMetalBuffer:device];
    _blurMesh.texture = _blurTexture;
    [_blurMesh setVertexWithRect:meshFrame atSquareIndex:0];
    [_blurMesh setTexCoordsWithRegion:region atSquareIndex:0];
    
    _inTexture = [[YAS2DTexture alloc] initWithPointSize:region.size scaleFactor:scaleFactor format:MTLPixelFormatBGRA8Unorm];
    [_inTexture setupMetalBuffer:device];
    _inMesh.texture = _inTexture;
    [_inMesh setVertexWithRect:meshFrame atSquareIndex:0];
    [_inMesh setTexCoordsWithRegion:region atSquareIndex:0];
    
    [self setupRenderPassDescriptor];
    
    [_outMesh setupMetalBuffer:device];
    [_blurMesh setupMetalBuffer:device];
    [_inMesh setupMetalBuffer:device];
    
    [super setupMetalBuffer:device];
}

- (void)setupRenderPassDescriptor
{
    _outRenderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    MTLRenderPassColorAttachmentDescriptor *outColorAttachment = [MTLRenderPassColorAttachmentDescriptor new];
    outColorAttachment.texture = _outTexture.texture;
    outColorAttachment.loadAction = MTLLoadActionClear;
    outColorAttachment.clearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 0.0f);
    [outColorAttachment setStoreAction: MTLStoreActionStore];
    [_outRenderPassDescriptor.colorAttachments setObject:outColorAttachment atIndexedSubscript:0];
    
    _blurRenderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    MTLRenderPassColorAttachmentDescriptor *blurColorAttachment = [MTLRenderPassColorAttachmentDescriptor new];
    blurColorAttachment.texture = _blurTexture.texture;
    blurColorAttachment.loadAction = MTLLoadActionClear;
    blurColorAttachment.clearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 0.0f);
    [blurColorAttachment setStoreAction: MTLStoreActionStore];
    [_blurRenderPassDescriptor.colorAttachments setObject:blurColorAttachment atIndexedSubscript:0];
    
    _inRenderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    MTLRenderPassColorAttachmentDescriptor *inColorAttachment = [MTLRenderPassColorAttachmentDescriptor new];
    inColorAttachment.texture = _inTexture.texture;
    inColorAttachment.loadAction = MTLLoadActionClear;
    inColorAttachment.clearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 0.0f);
    [inColorAttachment setStoreAction: MTLStoreActionStore];
    [_inRenderPassDescriptor.colorAttachments setObject:inColorAttachment atIndexedSubscript:0];
}

@end
