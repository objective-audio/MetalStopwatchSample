//
//  YAS2DImage.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

@interface YAS2DImage : NSObject

@property (nonatomic, assign, readonly) MTLSize pointSize;
@property (nonatomic, assign, readonly) MTLSize actualSize;
@property (nonatomic, assign, readonly) float scaleFactor;
@property (nonatomic, assign, readonly) void *data;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPointSize:(MTLSize)pointSize scaleFactor:(CGFloat)scaleFactor;
- (instancetype)initWithPointSize:(MTLSize)size;

- (void)clearBuffer;
- (void)draw:(void (^)(CGContextRef))block;

@end
