//
//  YAS2DTexture.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DTexture.h"
#import "YAS2DImage.h"
#import <CoreGraphics/CoreGraphics.h>

#define YAS2DTextureDrawPadding 2

@implementation YAS2DTexture {
    MTLOrigin _drawActualPoint;
    NSUInteger _maxLineHeight;
    NSUInteger _drawActualPadding;
}

- (instancetype)initWithPointSize:(MTLSize)pointSize scaleFactor:(CGFloat)scaleFactor
{
    return [self initWithPointSize:pointSize scaleFactor:scaleFactor format:MTLPixelFormatRGBA8Unorm];
}

- (instancetype)initWithPointSize:(MTLSize)pointSize scaleFactor:(CGFloat)scaleFactor format:(uint32_t)format
{
    self = [super init];
    if (self) {
        _drawActualPadding = YAS2DTextureDrawPadding * scaleFactor;
        _pointSize = pointSize;
        _actualSize = MTLSizeMake(pointSize.width * scaleFactor, pointSize.height * scaleFactor, 1);
        _scaleFactor = scaleFactor;
        _depth = 1;
        _format = format;
        _target = MTLTextureType2D;
        _texture = nil;
        _hasAlpha = NO;
        _drawActualPoint = MTLOriginMake(YAS2DTextureDrawPadding, YAS2DTextureDrawPadding, 0);
    }
    return self;
}

- (MTLRegion)copyImage:(YAS2DImage *)image
{
    assert(image);
    assert(_texture);
    assert(_sampler);
    
    MTLSize actualImageSize = image.actualSize;
    
    [self _prepareDrawWithActualSize:actualImageSize];
    
    MTLRegion region = [self replaceImage:image atActualOrigin:_drawActualPoint];
    
    [self _moveDrawPointWithActualSize:actualImageSize];
    
    return region;
}

- (MTLRegion)replaceImage:(YAS2DImage *)image atActualOrigin:(MTLOrigin)origin
{
    assert(image);
    assert(_texture);
    assert(_sampler);
    
    MTLRegion region;
    region.origin = origin;
    region.size = image.actualSize;
    
    [_texture replaceRegion:region mipmapLevel:0 withBytes:image.data bytesPerRow:region.size.width * 4];
    
    return region;
}

- (BOOL)setupMetalBuffer:(id<MTLDevice>)device
{
    MTLTextureDescriptor *textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:_format
                                                                                                 width:_actualSize.width
                                                                                                height:_actualSize.height
                                                                                             mipmapped:NO];
    _target  = textureDescriptor.textureType;
    _texture = [device newTextureWithDescriptor:textureDescriptor];
    
    if (!_texture) {
        assert(0);
        return NO;
    }
    
    MTLSamplerDescriptor *samplerDescriptor = [MTLSamplerDescriptor new];
    
    if(!samplerDescriptor) {
        assert(0);
        return NO;
    }
    
    samplerDescriptor.minFilter             = MTLSamplerMinMagFilterLinear;
    samplerDescriptor.magFilter             = MTLSamplerMinMagFilterLinear;
    samplerDescriptor.mipFilter             = MTLSamplerMipFilterNotMipmapped;
    samplerDescriptor.maxAnisotropy         = 1.0f;
    samplerDescriptor.sAddressMode          = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.tAddressMode          = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.rAddressMode          = MTLSamplerAddressModeClampToEdge;
    samplerDescriptor.normalizedCoordinates = NO;
    samplerDescriptor.lodMinClamp           = 0;
    samplerDescriptor.lodMaxClamp           = FLT_MAX;
    
    _sampler = [device newSamplerStateWithDescriptor:samplerDescriptor];
    
    if(!_sampler) {
        assert(0);
        return NO;
    }
    
    return YES;
}

#pragma mark - Private

- (void)_moveDrawPointWithActualSize:(MTLSize)actualSize
{
    _drawActualPoint.x += actualSize.width + _drawActualPadding;
    
    if (_actualSize.width < _drawActualPoint.x) {
        _drawActualPoint.y += _maxLineHeight + _drawActualPadding;
        _maxLineHeight = 0;
        _drawActualPoint.x = 0;
    }
    
    if (_maxLineHeight < actualSize.height) {
        _maxLineHeight = actualSize.height;
    }
}

- (void)_prepareDrawWithActualSize:(MTLSize)actualSize
{
    if (_actualSize.width < (_drawActualPoint.x + actualSize.width + _drawActualPadding)) {
        [self _moveDrawPointWithActualSize:actualSize];
    }
}

@end
