//
//  YAS2DTexture.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

@class YAS2DImage, YAS2DAtlasInfo;

@interface YAS2DTexture : NSObject

@property (nonatomic, readonly) id<MTLSamplerState> sampler;
@property (nonatomic, readonly) id<MTLTexture> texture;
@property (nonatomic, readonly) MTLTextureType target;
@property (nonatomic, readonly) MTLSize pointSize;
@property (nonatomic, readonly) MTLSize actualSize;
@property (nonatomic, readonly) CGFloat scaleFactor;
@property (nonatomic, readonly) uint32_t depth;
@property (nonatomic, readonly) uint32_t format;
@property (nonatomic, readonly) BOOL hasAlpha;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPointSize:(MTLSize)pointSize scaleFactor:(CGFloat)scaleFactor;
- (instancetype)initWithPointSize:(MTLSize)pointSize scaleFactor:(CGFloat)scaleFactor format:(uint32_t)format;

- (MTLRegion)replaceImage:(YAS2DImage *)image atActualOrigin:(MTLOrigin)origin;
- (MTLRegion)copyImage:(YAS2DImage *)image;

- (BOOL)setupMetalBuffer:(id<MTLDevice>)device;

@end
