//
//  YAS2DStringsNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DStringsNode.h"

static const NSUInteger YAS2DStringsNodeMaxWordCount = 16;

@interface YAS2DStringsNode ()

@property (nonatomic) YAS2DSquareNode *squareNode;

@end

@implementation YAS2DStringsNode

- (instancetype)initWithStringsData:(YAS2DStringsData *)info
{
    self = [super init];
    if (self) {
        self.squareNode = [[YAS2DSquareNode alloc] initWithSquareCount:YAS2DStringsNodeMaxWordCount dynamic:YES];
        [self addSubNode:_squareNode];
        _squareNode.mesh.texture = info.texture;
        _stringsData = info;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    if (_text != text) {
        _text = [text copy];
        [self _updateSquareNode];
    }
}

- (void)setPivot:(YAS2DStringsPivot)pivot
{
    if (_pivot != pivot) {
        _pivot = pivot;
        [self _updateSquareNode];
    }
}

- (void)setColor:(float4)color
{
    _squareNode.mesh.color = color;
}

- (float4)color
{
    return _squareNode.mesh.color;
}

- (void)_updateSquareNode
{
    assert(_stringsData);
    
    NSUInteger length = MIN(_text.length, YAS2DStringsNodeMaxWordCount);
    
    YAS2DStringsInfo *stringsInfo = [_stringsData stringsInfoForText:_text pivot:_pivot];
    _width = stringsInfo.width;
    memcpy([_squareNode.mesh vertexPointerAtSquareIndex:0], stringsInfo.vertexPointer, length * sizeof(vertex2d_t) * 4);
    
    _squareNode.mesh.indexCount = length * 6;
    
    [_squareNode.mesh setNeedsUpdateRenderBuffer];
}

@end
