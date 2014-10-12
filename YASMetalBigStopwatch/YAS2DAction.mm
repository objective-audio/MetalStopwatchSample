//
//  YAS2DAction.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DAction.h"
#import "YAS2DNode.h"
#import "YAS2DBlurNode.h"

#define YAS2DActionCurveFrames 256

static BOOL _curveSetupFinished = NO;
static float _easeInCurve[YAS2DActionCurveFrames + 1];
static float _easeOutCurve[YAS2DActionCurveFrames + 1];
static float _easeInOutCurve[YAS2DActionCurveFrames + 1];

static void YAS2DCurveSetup()
{
    if (_curveSetupFinished) {
        return;
    }
    
    for (NSInteger i = 0; i < (YAS2DActionCurveFrames + 1); i++) {
        float pos = (float)i / YAS2DActionCurveFrames;
        _easeInCurve[i] = sinf((pos - 1.0f) * M_PI_2) + 1.0f;
        _easeOutCurve[i] = sinf(pos * M_PI_2);
        _easeInOutCurve[i] = (sin((pos * 2.0f - 1.0f) * M_PI_2) + 1.0f) * 0.5f;
    }
    
    _curveSetupFinished = YES;
}

static float YAS2DConvertValueFromArray(float *ptr, float pos)
{
    float frame = pos * YAS2DActionCurveFrames;
    NSInteger index = frame;
    float frac = frame - index;
    float curVal = ptr[index];
    float nextVal = ptr[index + 1];
    return curVal + (nextVal - curVal) * frac;
}

static float YAS2DActionCurveConvert(float pos, YAS2DActionCurve curve)
{
    YAS2DCurveSetup();
    
    float result;
    
    switch (curve) {
        case YAS2DActionCurveEaseIn:
            result = YAS2DConvertValueFromArray(_easeInCurve, pos);
            break;
        case YAS2DActionCurveEaseOut:
            result = YAS2DConvertValueFromArray(_easeOutCurve, pos);
            break;
        case YAS2DActionCurveEaseInOut:
            result = YAS2DConvertValueFromArray(_easeInOutCurve, pos);
            break;
        default:
            result = pos;
            break;
    }
    
    return result;
}

@interface YAS2DAction ()

@property (nonatomic, copy) void (^updateBlock)(NSTimeInterval value);

@end

@implementation YAS2DAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        _startDate = [[NSDate alloc] init];
        _duration = 0.3;
        _curve = YAS2DActionCurveEaseInOut;
    }
    return self;
}

- (void)update:(NSDate *)date
{
    NSTimeInterval value = [date timeIntervalSinceDate:_startDate] / _duration;
    BOOL finished = NO;
    
    if (value >= 1.0) {
        value = 1.0;
        finished = YES;
    } else if (value < 0) {
        value = 0;
    }
    
    value = YAS2DActionCurveConvert(value, _curve);
    
    if (_updateBlock) {
        _updateBlock(value);
    }
    
    if (finished) {
        [self.actionSet removeObject:self];
    }
}

@end

@implementation YAS2DTranslateAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak YAS2DTranslateAction *action = self;
        self.updateBlock = ^(NSTimeInterval value) {
            action.target.position = (action.endPosition - action.startPosition) * (float)value + action.startPosition;
        };
    }
    return self;
}

@end

@implementation YAS2DRotateAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak YAS2DRotateAction *action = self;
        self.updateBlock = ^(NSTimeInterval value) {
            float endAngle = action.endAngle;
            float startAngle = action.startAngle;
            if (action.isShortest) {
                if ((endAngle - startAngle) > 180.0f) {
                    startAngle += 360.0f;
                } else if ((endAngle - startAngle) < - 180.0f) {
                    startAngle -= 360.0f;
                }
            }
            action.target.angle = (endAngle - startAngle) * value + startAngle;
        };
    }
    return self;
}

@end

@implementation YAS2DScaleAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak YAS2DScaleAction *action = self;
        self.updateBlock = ^(NSTimeInterval value) {
            action.target.scale = (action.endScale - action.startScale) * (float)value + action.startScale;
        };
    }
    return self;
}

@end

@implementation YAS2DColorAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak YAS2DColorAction *action = self;
        self.updateBlock = ^(NSTimeInterval value) {
            action.target.color = (action.endColor - action.startColor) * (float)value + action.startColor;
        };
    }
    return self;
}

@end

@implementation YAS2DBlurAction

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak YAS2DBlurAction *action = self;
        self.updateBlock = ^(NSTimeInterval value) {
            YAS2DBlurNode *target = (YAS2DBlurNode *)action.target;
            target.coef = (action.endCoef - action.startCoef) * (float)value + action.startCoef;
        };
    }
    return self;
}

@end
