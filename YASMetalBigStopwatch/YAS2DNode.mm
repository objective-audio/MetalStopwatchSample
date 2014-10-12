//
//  YAS2DNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DNode.h"
#import "YAS2DMesh.h"
#import "YAS2DTouch.h"
#import "YAS2DRenderer.h"
#import "YAS2DTransforms.h"

@implementation YAS2DEncodeInfo

- (instancetype)initWithRenderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor 
                               pipelineState:(id<MTLRenderPipelineState>)pipelineState 
                pipelineStateForUnuseTexture:(id<MTLRenderPipelineState>)pipelineStateForUnuseTexture
{
    self = [super init];
    if (self) {
        _meshes = [[NSMutableArray alloc] initWithCapacity:256];
        _renderPassDescriptor = renderPassDescriptor;
        _pipelineState = pipelineState;
        _pipelineStateForUnuseTexture = pipelineStateForUnuseTexture;
    }
    return self;
}

- (void)addMesh:(YAS2DMesh *)mesh
{
    [_meshes addObject:mesh];
}

@end

@interface YAS2DRenderInfo ()

@property (nonatomic) NSMutableArray *encodeInfos;
@property (nonatomic) NSMutableArray *mutableRenderEncodeInfos;

@end

@implementation YAS2DRenderInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _encodeInfos = [[NSMutableArray alloc] initWithCapacity:16];
        _mutableRenderEncodeInfos = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return self;
}

- (void)pushRenderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor 
                   pipelineState:(id<MTLRenderPipelineState>)pipelineState 
    pipelineStateForUnuseTexture:(id<MTLRenderPipelineState>)pipelineStateForUnuseTexture
{
    YAS2DEncodeInfo *encodeInfo = [[YAS2DEncodeInfo alloc] initWithRenderPassDescriptor:renderPassDescriptor 
                                                                          pipelineState:pipelineState 
                                                           pipelineStateForUnuseTexture:pipelineStateForUnuseTexture];
    [_encodeInfos addObject:encodeInfo];
    [_mutableRenderEncodeInfos addObject:encodeInfo];
}

- (void)popRenderPassDescriptor
{
    [_encodeInfos removeLastObject];
}

- (NSEnumerator *)encodeInfoEnumerator
{
    return _mutableRenderEncodeInfos.reverseObjectEnumerator;
}

- (YAS2DEncodeInfo *)currentEncodeInfo
{
    return _encodeInfos.lastObject;
}

@end

@interface YAS2DNode ()

@property (nonatomic) NSMutableArray *mutableChildren;
@property (nonatomic) YAS2DNode *parent;

@end

@implementation YAS2DNode {
    float4x4 _localMatrix;
    BOOL _needsUpdateMatrix;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mutableChildren = [[NSMutableArray alloc] init];
        _localMatrix = matrix_identity_float4x4;
        _scale = 1.0f;
        _needsUpdateMatrix = YES;
        _enabled = YES;
    }
    return self;
}

#pragma mark - Hierarchie

- (NSArray *)children
{
    return _mutableChildren;
}

- (void)addSubNode:(YAS2DNode *)subNode
{
    if (![subNode isKindOfClass:[YAS2DNode class]]) {
        assert(0);
        return;
    }
    
    [_mutableChildren addObject:subNode];
    subNode.parent = self;
    subNode.renderer = self.renderer;
    
    if (subNode.touch) {
        [self.renderer setNeedsUpdateTouchArray];
    }
}

- (void)removeSubNode:(YAS2DNode *)subNode
{
    subNode.parent = nil;
    subNode.renderer = nil;
    [_mutableChildren removeObject:subNode];
    
    if (subNode.touch) {
        [self.renderer setNeedsUpdateTouchArray];
    }
}

- (void)removeFromSuperNode
{
    [_parent removeSubNode:self];
}

- (void)setPosition:(float2)position
{
    _position = position;
    _needsUpdateMatrix = YES;
}

- (void)setAngle:(float)angle
{
    if (_angle != angle) {
        _angle = angle;
        _needsUpdateMatrix = YES;
    }
}

- (void)setScale:(float2)scale
{
    _scale = scale;
    _needsUpdateMatrix = YES;
}

- (void)setTouch:(YAS2DTouch *)touch
{
    if (_touch != touch) {
        _touch = touch;
        [self.renderer setNeedsUpdateTouchArray];
    }
}

- (void)setColor:(float4)color
{
    self.mesh.color = color;
}

- (float4)color
{
    return self.mesh.color;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    [self.renderer setNeedsUpdateTouchArray];
}

#pragma mark - Render

- (void)updateRenderInfo:(YAS2DRenderInfo *)renderInfo
{
    if (!_enabled) {
        return;
    }
    
    [self updateMatrixForRender:renderInfo.renderMatrix];
    [self updateTouchForRender:renderInfo.touchMatrix];
    
    if (_mesh) {
        _mesh.matrix = _renderMatrix;
        YAS2DEncodeInfo *encodeInfo = renderInfo.currentEncodeInfo;
        [encodeInfo addMesh:_mesh];
    }
    
    for (YAS2DNode *subNode in _mutableChildren) {
        renderInfo.renderMatrix = _renderMatrix;
        renderInfo.touchMatrix = _touchMatrix;
        [subNode updateRenderInfo:renderInfo];
    }
}

- (void)setupMetalBuffer:(id<MTLDevice>)device
{
    [_mesh setupMetalBuffer:device];
    
    for (YAS2DNode *subNode in _mutableChildren) {
        [subNode setupMetalBuffer:device];
    }
}

#pragma mark -

- (void)updateMatrixForRender:(float4x4)matrix
{
    if (_needsUpdateMatrix) {
        _localMatrix = yas2d_translate(_position.x, _position.y) * yas2d_rotate(_angle) * yas2d_scale(_scale.x, _scale.y);
        _needsUpdateMatrix = NO;
    }
    
    _renderMatrix = matrix * _localMatrix;
}

- (void)updateTouchForRender:(float4x4)touchMatrix
{
    [self.renderer addTouchIfNeeded:self.touch];
    
    _touchMatrix = touchMatrix * _localMatrix;
    _touch.matrix = _touchMatrix;
}

@end
