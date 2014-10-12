//
//  YASSWButtonNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWButtonNode.h"
#import "YAS2DSquareNode.h"
#import "YAS2DTouch.h"
#import "YAS2DAction.h"
#import "YAS2DRenderer.h"

using namespace simd;

static float4 YASSWButtonNodeBaseDefaultColor = 1.0f;
static float4 YASSWButtonNodeUnselectedDefaultColor = 0.0f;
static float4 YASSWButtonNodeSelectedDefaultColor = 0.1f;
static float4 YASSWButtonNodeFlashDefaultColor = 0.4f;

@interface YASSWButtonNode ()

@property (nonatomic) YAS2DSquareNode *baseNode;
@property (nonatomic) YAS2DSquareNode *selectedNode;
@property (nonatomic) YAS2DSquareNode *flashNode;

@end

@implementation YASSWButtonNode

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        _frame = frame;
        _unselectedColor = YASSWButtonNodeUnselectedDefaultColor;
        _selectedColor = YASSWButtonNodeSelectedDefaultColor;
        _flashColor = YASSWButtonNodeFlashDefaultColor;
        
        YAS2DSquareNode *baseNode  = [[YAS2DSquareNode alloc] initWithSquareCount:1 dynamic:NO];
        baseNode.mesh.color = YASSWButtonNodeBaseDefaultColor;
        [self addSubNode:baseNode];
        [baseNode.mesh setVertexWithRect:frame atSquareIndex:0];
        self.baseNode = baseNode;
        
        YAS2DSquareNode *selectedNode  = [[YAS2DSquareNode alloc] initWithSquareCount:1 dynamic:NO];
        [self addSubNode:selectedNode];
        [selectedNode.mesh setVertexWithRect:frame atSquareIndex:0];
        selectedNode.mesh.color = YASSWButtonNodeUnselectedDefaultColor;
        self.selectedNode = selectedNode;
        
        YAS2DSquareNode *flashNode  = [[YAS2DSquareNode alloc] initWithSquareCount:1 dynamic:NO];
        [self addSubNode:flashNode];
        [flashNode.mesh setVertexWithRect:frame atSquareIndex:0];
        flashNode.mesh.color = 0.0f;
        self.flashNode = flashNode;
        
        YAS2DTouch *touch = [[YAS2DTouch alloc] init];
        touch.radius = CGRectGetWidth(frame) > CGRectGetHeight(frame) ? CGRectGetWidth(frame) * 0.5 : CGRectGetHeight(frame) * 0.5;
        touch.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        touch.touchType = YAS2DTouchTypeCircle;
        touch.node = self;
        self.touch = touch;
        
        __weak YASSWButtonNode *buttonNode = self;
        
        touch.touchBegan = ^{
            selectedNode.mesh.color = buttonNode.selectedColor;
        };
        
        touch.touchEnded = ^{
            selectedNode.mesh.color = buttonNode.unselectedColor;
            
            YAS2DColorAction *action = [[YAS2DColorAction alloc] init];
            action.target = flashNode;
            action.startColor = buttonNode.flashColor;
            action.endColor = 0.0f;
            action.duration = 1.0f;
            [buttonNode.renderer removeActionForTarget:flashNode];
            [buttonNode.renderer addAction:action];
            
            if (buttonNode.touchEnded) {
                buttonNode.touchEnded();
            }
        };
        
        touch.touchCancelled = ^{
            selectedNode.mesh.color = buttonNode.unselectedColor;
        };
    }
    return self;
}

- (void)setBaseColor:(float4)baseColor
{
    self.baseNode.mesh.color = baseColor;
}

- (float4)baseColor
{
    return self.baseNode.mesh.color;
}

- (void)setUnselectedColor:(float4)unselectedColor
{
    _unselectedColor = unselectedColor;
    self.selectedNode.mesh.color = unselectedColor;
}

- (void)setTouchEnabled:(BOOL)touchEnabled
{
    self.touch.enabled = touchEnabled;
}

- (BOOL)touchEnabled
{
    return self.touch.enabled;
}

@end
