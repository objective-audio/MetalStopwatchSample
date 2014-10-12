//
//  YASSWLineCircleNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DNode.h"

using namespace simd;

@class YAS2DTexture;

@interface YASSWCircleDescription : NSObject

@property (nonatomic) float lineRadius;
@property (nonatomic) NSUInteger thinDivideCount;
@property (nonatomic) float4 fatLineColor;
@property (nonatomic) float4 thinLineColor;
@property (nonatomic) CGSize fatLineSize;
@property (nonatomic) CGSize thinLineSize;
@property (nonatomic) float numberRadius;
@property (nonatomic, copy) NSString *numberFontName;
@property (nonatomic) CGFloat numberFontSize;
@property (nonatomic) float needleRadius;
@property (nonatomic) float4 needleColor;
@property (nonatomic) float4 strokeNeedleColor;
@property (nonatomic) MTLSize needleSize;
@property (nonatomic) float needleAngle;
@property (nonatomic) float strokeNeedleAngle;
@property (nonatomic) float strokeNeedleLineWidth;

@end

@interface YASSWLineCircleNode : YAS2DNode

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCircleDescription:(YASSWCircleDescription *)description 
                                  texture:(YAS2DTexture *)texture;

- (void)setCircleAngle:(float)angle withAnimation:(BOOL)withAnim;
- (void)setNeedleAngle:(float)angle withAnimation:(BOOL)withAnim;
- (void)setStrokeNeedleAngle:(float)angle withAnimation:(BOOL)withAnim;

@end
