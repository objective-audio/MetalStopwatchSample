//
//  YAS2DRenderer.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DRenderer.h"
#import "YAS2DNode.h"
#import "YAS2DSharedTypes.h"
#import "YAS2DTouch.h"
#import "YAS2DAction.h"
#import "YAS2DGestureRecognizer.h"

@interface YAS2DRenderer ()

@property (nonatomic) NSMutableSet *actionSet;
@property (nonatomic) YAS2DGestureRecognizer *gestureRecognizer;

@end

@implementation YAS2DRenderer

- (instancetype)initWithView:(YASMetalView *)view
{
    self = [super initWithView:view];
    if (self) {
        _rootNode = [[YAS2DNode alloc] init];
        _rootNode.renderer = self;
        
        view.delegate = self;
        
        self.gestureRecognizer = [[YAS2DGestureRecognizer alloc] initWithTarget:self action:@selector(gestureStateChanged:)];
        [view addGestureRecognizer:self.gestureRecognizer];
    }
    return self;
}

#pragma mark - Accessor

- (void)addAction:(YAS2DAction *)action
{
    if (!_actionSet) {
        _actionSet = [[NSMutableSet alloc] init];
    }
    
    action.actionSet = _actionSet;
    [_actionSet addObject:action];
}

- (void)removeActionForTarget:(YAS2DNode *)target
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"target == %@", target];
    NSSet *set = [_actionSet filteredSetUsingPredicate:predicate];
    [_actionSet minusSet:set];
}

#pragma mark - Render

- (void)renderWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer renderPassDescriptor:(MTLRenderPassDescriptor *)renderPassDescriptor
{
    [self updateActions];
    
    [self.gestureRecognizer clearTouchArrayIfNeeded];
    
    YAS2DRenderInfo *renderInfo = [[YAS2DRenderInfo alloc] init];
    [renderInfo pushRenderPassDescriptor:renderPassDescriptor 
                           pipelineState:self.multiSamplePipelineState 
            pipelineStateForUnuseTexture:self.multiSamplePipelineStateForUnuseTexture];
    
    renderInfo.renderMatrix = self.projectionMatrix;
    renderInfo.touchMatrix = self.projectionMatrix;
    
    [self.rootNode updateRenderInfo:renderInfo];
    
    [self.gestureRecognizer finalizeTouchArray];
    
    for (YAS2DEncodeInfo *encodeInfo in renderInfo.encodeInfoEnumerator) {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:encodeInfo.renderPassDescriptor];
        for (YAS2DMesh *mesh in encodeInfo.meshes) {
            [mesh metalViewRender:self encoder:renderEncoder encodeInfo:encodeInfo];
        }
        [renderEncoder endEncoding];
    }
}

- (void)setupMetalBuffer
{
    [_rootNode setupMetalBuffer:self.device];
}

- (void)updateActions
{
    NSDate *date = [[NSDate alloc] init];
    
    for (YAS2DAction *action in _actionSet.allObjects) {
        [action update:date];
    }
}

#pragma mark - Tap

- (void)gestureStateChanged:(YAS2DGestureRecognizer *)gesture
{
    
}

- (void)setNeedsUpdateTouchArray
{
    [self.gestureRecognizer setNeedsUpdateTouchArray];
}

- (void)addTouchIfNeeded:(YAS2DTouch *)touch
{
    [self.gestureRecognizer addTouchIfNeeded:touch];
}

@end
