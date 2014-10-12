//
//  YASSWLineCircleNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWLineCircleNode.h"
#import "YAS2DSquareNode.h"
#import "YAS2DTexture.h"
#import "YAS2DStringsData.h"
#import "YASSWFillNeedleNode.h"
#import "YASSWStrokeNeedleNode.h"
#import "YAS2DAction.h"
#import "YAS2DRenderer.h"
#import "YAS2DTransforms.h"

@implementation YASSWCircleDescription

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineRadius = 100.0f;
        _thinDivideCount = 10;
        _fatLineColor = 1.0f;
        _thinLineColor = 1.0f;
        _fatLineSize = {1.0, 1.0};
        _thinLineSize = {1.0, 1.0};
        _numberRadius = 100.0f;
        _numberFontName = @"HelveticaNeue-Light";
        _numberFontSize = 20.0f;
        _needleRadius = 100.0f;
        _needleColor = 1.0f;
        _strokeNeedleColor = {1.0f, 0.6f, 0.0f, 1.0f};
        _needleSize = MTLSizeMake(1, 1, 1);
        _needleAngle = 0.0f;
        _strokeNeedleAngle = 0.0f;
        _strokeNeedleLineWidth = 1.0f;
    }
    return self;
}

@end

@interface YASSWLineCircleNode ()

@property (nonatomic) YAS2DNode *needleHandleNode;
@property (nonatomic) YAS2DNode *strokeNeedleHandleNode;

@end

@implementation YASSWLineCircleNode

- (instancetype)initWithCircleDescription:(YASSWCircleDescription *)description 
                                  texture:(YAS2DTexture *)texture
{
    assert(texture);
    
    self = [super init];
    if (self) {
        const NSUInteger fatLineCount = 60;
        const NSUInteger lineCount = fatLineCount * description.thinDivideCount;
        const NSUInteger thinLineCount = lineCount - fatLineCount;
        
        YAS2DSquareNode *fatLinesNode = [[YAS2DSquareNode alloc] initWithSquareCount:fatLineCount dynamic:NO];
        [self addSubNode:fatLinesNode];
        fatLinesNode.mesh.color = description.fatLineColor;
        
        YAS2DSquareNode *thinLinesNode = [[YAS2DSquareNode alloc] initWithSquareCount:thinLineCount dynamic:NO];
        [self addSubNode:thinLinesNode];
        thinLinesNode.mesh.color = description.thinLineColor;
        
        const NSUInteger numbersSquareCount = 9 + (fatLineCount - 9) * 2;
        YAS2DSquareNode *numbersNode = [[YAS2DSquareNode alloc] initWithSquareCount:numbersSquareCount dynamic:NO];
        numbersNode.mesh.texture = texture;
        [self addSubNode:numbersNode];
        
        const float fatWidth = description.fatLineSize.width;
        const float fatHeight = description.fatLineSize.height;
        
        CGRect fatRect = CGRectMake(- fatWidth * 0.5, - fatHeight * 0.5, fatWidth, fatHeight);
        
        const float thinWidth = description.thinLineSize.width;
        const float thinHeight = description.thinLineSize.height;
        
        CGRect thinRect = CGRectMake(- thinWidth * 0.5, - thinHeight * 0.5, thinWidth, thinHeight);
        
        YAS2DStringsData *stringsData = [[YAS2DStringsData alloc] initWithFontName:description.numberFontName fontSize:description.numberFontSize words:@"0123456789" texture:texture];
        
        float4x4 lineTranslateMatrix = yas2d_translate(0, description.lineRadius);
        float4x4 numberTranslateMatrix = yas2d_translate(0, description.numberRadius);
        
        NSUInteger thinIndex = 0;
        NSUInteger numberSquareIndex = 0;
        
        for (NSInteger fatIndex = 0; fatIndex < fatLineCount; fatIndex++) {
            for (NSInteger divIndex = 0; divIndex < description.thinDivideCount; divIndex++) {
                float4x4 rotateMatrix = yas2d_rotate(- (float)(fatIndex * description.thinDivideCount + divIndex) / lineCount * 360.0f);
                float4x4 lineMatrix = rotateMatrix * lineTranslateMatrix;
                if (divIndex == 0) {
                    [fatLinesNode.mesh setVertexWithRect:fatRect atSquareIndex:fatIndex matrix:lineMatrix];
                    
                    float4x4 numberMatrix = rotateMatrix * numberTranslateMatrix;
                    NSString *numberText = [NSString stringWithFormat:@"%@", @(fatIndex)];
                    YAS2DStringsInfo *stringsInfo = [stringsData stringsInfoForText:numberText pivot:YAS2DStringsPivotCenter];
                    for (NSInteger wordIndex = 0; wordIndex < stringsInfo.wordCount; wordIndex++) {
                        [numbersNode.mesh setVertex:[stringsInfo vertexPointerAtWordIndex:wordIndex] atSquareIndex:numberSquareIndex matrix:numberMatrix];
                        numberSquareIndex++;
                    }
                } else {
                    [thinLinesNode.mesh setVertexWithRect:thinRect atSquareIndex:thinIndex matrix:lineMatrix];
                    thinIndex++;
                }
            }
        }
        
        self.needleHandleNode = [[YAS2DNode alloc] init];
        [self addSubNode:self.needleHandleNode];
        
        YASSWFillNeedleNode *needleNode = [[YASSWFillNeedleNode alloc] initWithSize:description.needleSize];
        [self.needleHandleNode addSubNode:needleNode];
        needleNode.position = (float2){0.0f, description.needleRadius};
        needleNode.angle = description.needleAngle;
        needleNode.color = description.needleColor;
        
        self.strokeNeedleHandleNode = [[YAS2DNode alloc] init];
        [self addSubNode:self.strokeNeedleHandleNode];
        
        YASSWStrokeNeedleNode *strokeNeedleNode = [[YASSWStrokeNeedleNode alloc] initWithSize:description.needleSize lineWidth:description.strokeNeedleLineWidth];
        [self.strokeNeedleHandleNode addSubNode:strokeNeedleNode];
        strokeNeedleNode.position = (float2){0.0f, description.needleRadius};
        strokeNeedleNode.angle = description.strokeNeedleAngle;
        strokeNeedleNode.color = description.strokeNeedleColor;
    }
    return self;
}

- (void)setCircleAngle:(float)angle withAnimation:(BOOL)withAnim
{
    YAS2DRotateAction *action = nil;
    
    if (withAnim) {
        YAS2DRotateAction *newAction = [[YAS2DRotateAction alloc] init];
        newAction.target = self;
        newAction.curve = YAS2DActionCurveEaseOut;
        newAction.startAngle = self.angle;
        newAction.endAngle = angle;
        newAction.shortest = YES;
        action = newAction;
        [self.renderer addAction:newAction];
    }
    
    if (action) {
        action.endAngle = angle;
    } else {
        self.angle = angle;
    }
}

- (void)setNeedleAngle:(float)angle withAnimation:(BOOL)withAnim
{
    YAS2DRotateAction *action = nil;
    
    if (withAnim) {
        YAS2DRotateAction *newAction = [[YAS2DRotateAction alloc] init];
        newAction.target = self.needleHandleNode;
        newAction.curve = YAS2DActionCurveEaseOut;
        newAction.startAngle = self.needleHandleNode.angle;
        newAction.endAngle = angle;
        newAction.shortest = YES;
        action = newAction;
        [self.renderer addAction:newAction];
    }
    
    if (action) {
        action.endAngle = angle;
    } else {
        self.needleHandleNode.angle = angle;
    }
}

- (void)setStrokeNeedleAngle:(float)angle withAnimation:(BOOL)withAnim
{
    YAS2DRotateAction *action = nil;
    
    if (withAnim) {
        YAS2DRotateAction *newAction = [[YAS2DRotateAction alloc] init];
        newAction.target = self.strokeNeedleHandleNode;
        newAction.curve = YAS2DActionCurveEaseOut;
        newAction.startAngle = self.strokeNeedleHandleNode.angle;
        newAction.endAngle = angle;
        newAction.duration = 0.1f;
        newAction.shortest = YES;
        action = newAction;
        [self.renderer addAction:newAction];
    }
    
    if (action) {
        action.endAngle = angle;
    } else {
        self.strokeNeedleHandleNode.angle = angle;
    }
}

@end
