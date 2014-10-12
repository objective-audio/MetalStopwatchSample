//
//  YAS2DImage.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DImage.h"

@interface YAS2DImage ()

@end

@implementation YAS2DImage {
    CGContextRef _bitmapContext;
}

- (instancetype)initWithPointSize:(MTLSize)pointSize scaleFactor:(CGFloat)scaleFactor
{
    self = [super init];
    if (self) {
        _pointSize = pointSize;
        _scaleFactor = scaleFactor;
        _actualSize = MTLSizeMake(pointSize.width * scaleFactor, pointSize.height * scaleFactor, 1);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
        _bitmapContext = CGBitmapContextCreate(NULL, _actualSize.width, _actualSize.height, 8, _actualSize.width * 4, colorSpace, bitmapInfo);
        CGColorSpaceRelease(colorSpace);
    }
    return self;
}

- (instancetype)initWithPointSize:(MTLSize)size
{
    return [self initWithPointSize:size scaleFactor:[UIScreen mainScreen].scale];
}

- (void)dealloc
{
    CGContextRelease(_bitmapContext);
}

- (void *)data
{
    return CGBitmapContextGetData(_bitmapContext);
}

- (void)clearBuffer
{
    CGContextClearRect(_bitmapContext, CGRectMake(0, 0, _actualSize.width, _actualSize.height));
}

- (void)draw:(void (^)(CGContextRef))block
{
    if (block) {
        CGContextSaveGState(_bitmapContext); {
            CGContextTranslateCTM(_bitmapContext, 0.0, _actualSize.height);
            CGContextScaleCTM(_bitmapContext, (CGFloat)_actualSize.width / (CGFloat)_pointSize.width, -(CGFloat)_actualSize.height / (CGFloat)_pointSize.height);
            block(_bitmapContext);
        } CGContextRestoreGState(_bitmapContext);
    }
}

@end
