//
//  YAS2DTouch.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DTouch.h"
#import "YAS2DNode.h"

@implementation YAS2DTouch

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    return self;
}

- (BOOL)hitTest:(float2)location
{
    if (!_enabled) {
        return NO;
    }
    
    BOOL hit = NO;
    
    if (_touchType == YAS2DTouchTypeAnywhere) {
        hit = YES;
    } else {
        float4 loc = {location.x, location.y, 0, 1};
        loc = simd::float4x4(matrix_invert(_matrix)) * loc;
        CGPoint point = CGPointMake(loc.x, loc.y);
        
        switch (_touchType) {
            case YAS2DTouchTypeCircle: {
                if (pow((point.x - _center.x), 2) + pow((point.y - _center.y), 2) < pow(_radius, 2)) {
                    hit = YES;
                }
            }
                break;
            case YAS2DTouchTypeSquare: {
                CGRect rect = CGRectMake(-_radius + _center.x, -_radius + _center.y, _radius * 2.0, _radius * 2.0);
                hit = CGRectContainsPoint(rect, point);
            }
                break;
            default:
                break;
        }
    }
    
    return hit;
}

@end
