//
//  YAS2DTouch.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <UIKit/UIKit.h>
#import <simd/simd.h>

using namespace simd;

typedef NS_ENUM(NSUInteger, YAS2DTouchType) {
    YAS2DTouchTypeAnywhere,
    YAS2DTouchTypeCircle,
    YAS2DTouchTypeSquare,
};

@class YAS2DNode;

@interface YAS2DTouch : NSObject

@property (nonatomic, weak) YAS2DNode *node;

@property (nonatomic) YAS2DTouchType touchType;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;
@property (nonatomic) float4x4 matrix;
@property (nonatomic) BOOL enabled;

@property (nonatomic, copy) void (^touchBegan)(void);
@property (nonatomic, copy) void (^touchEnded)(void);
@property (nonatomic, copy) void (^touchCancelled)(void);

- (BOOL)hitTest:(float2)location;

@end
