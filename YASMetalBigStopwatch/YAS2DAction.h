//
//  YAS2DAction.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

using namespace simd;

typedef NS_ENUM(NSUInteger, YAS2DActionCurve) {
    YAS2DActionCurveLinear,
    YAS2DActionCurveEaseOut,
    YAS2DActionCurveEaseIn,
    YAS2DActionCurveEaseInOut,
};

@class YAS2DNode;

@interface YAS2DAction : NSObject

@property (nonatomic, weak) NSMutableSet *actionSet;

@property (nonatomic, weak) YAS2DNode *target;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) YAS2DActionCurve curve;

- (void)update:(NSDate *)date;

@end

@interface YAS2DTranslateAction : YAS2DAction

@property (nonatomic) float2 startPosition;
@property (nonatomic) float2 endPosition;

@end

@interface YAS2DRotateAction : YAS2DAction

@property (nonatomic) float startAngle;
@property (nonatomic) float endAngle;
@property (nonatomic, getter = isShortest) BOOL shortest;

@end

@interface YAS2DScaleAction : YAS2DAction

@property (nonatomic) float2 startScale;
@property (nonatomic) float2 endScale;

@end

@interface YAS2DColorAction : YAS2DAction

@property (nonatomic) float4 startColor;
@property (nonatomic) float4 endColor;

@end

@interface YAS2DBlurAction : YAS2DAction

@property (nonatomic) float startCoef;
@property (nonatomic) float endCoef;

@end
