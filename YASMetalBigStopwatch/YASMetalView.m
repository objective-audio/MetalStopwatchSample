//
//  YASMetalView.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASMetalView.h"

@implementation YASMetalView {
    MTLRenderPassDescriptor *_renderPassDescriptor;
    id<CAMetalDrawable> _currentDrawable;
    BOOL _needsUpdateDrawableSize;
}

+ (Class)layerClass
{
    return [CAMetalLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = nil;
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        CAMetalLayer *metalLayer = self.metalLayer;
        metalLayer.presentsWithTransaction = NO;
        metalLayer.drawsAsynchronously = YES;
        metalLayer.device = _device = MTLCreateSystemDefaultDevice();
        metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        metalLayer.framebufferOnly = YES;
        
        _needsUpdateDrawableSize = YES;
    }
    return self;
}

- (CAMetalLayer *)metalLayer
{
    return (CAMetalLayer *)self.layer;
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor
{
    [super setContentScaleFactor:contentScaleFactor];
    _needsUpdateDrawableSize = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _needsUpdateDrawableSize = YES;
}

- (id<CAMetalDrawable>)currentDrawable
{
    while (_currentDrawable == nil) {
        _currentDrawable = [self.metalLayer nextDrawable];
        if (!_currentDrawable) {
            NSLog(@"CurrentDrawable is nil");
        }
    }
    
    return _currentDrawable;
}

- (void)releaseRenderPassDescriptor
{
    _renderPassDescriptor = nil;
}

- (void)updateRenderPassDescriptor
{
    id<CAMetalDrawable> drawable = self.currentDrawable;
    assert(drawable);
    
    id<MTLTexture> drawableTexture = drawable.texture;
    
    if (_renderPassDescriptor == nil) {
        _renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
        
        MTLRenderPassColorAttachmentDescriptor *colorAttachment = [MTLRenderPassColorAttachmentDescriptor new];
        colorAttachment.loadAction = MTLLoadActionClear;
        colorAttachment.clearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 1.0f);
        
        [_renderPassDescriptor.colorAttachments setObject:colorAttachment atIndexedSubscript:0];
    }
    
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = [_renderPassDescriptor.colorAttachments objectAtIndexedSubscript:0];
    id<MTLTexture> attachmentTexture = colorAttachment.texture;
    
    if (_sampleCount > 1) {
        if (!attachmentTexture || 
            (attachmentTexture.width != drawableTexture.width) || 
            (attachmentTexture.height != drawableTexture.height) || 
            (attachmentTexture.sampleCount != _sampleCount)) {
            MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                            width:drawableTexture.width
                                                                                           height:drawableTexture.height
                                                                                        mipmapped:NO];
            desc.textureType = MTLTextureType2DMultisample;
            desc.sampleCount = _sampleCount;
            attachmentTexture = [_device newTextureWithDescriptor: desc];
        }
        
        colorAttachment.texture = attachmentTexture;
        colorAttachment.resolveTexture = drawableTexture;
        colorAttachment.storeAction = MTLStoreActionMultisampleResolve;
    } else {
        colorAttachment.texture = drawableTexture;
        colorAttachment.storeAction = MTLStoreActionStore;
    }
}

- (void)display
{
    @autoreleasepool {
        if(_needsUpdateDrawableSize) {
            CGSize drawableSize = self.bounds.size;
            drawableSize.width  *= self.contentScaleFactor;
            drawableSize.height *= self.contentScaleFactor;
            self.metalLayer.drawableSize = drawableSize;
            
            if ([_delegate respondsToSelector:@selector(metalViewDidResize:)]) {
                [_delegate metalViewDidResize:self];
            }
            
            _needsUpdateDrawableSize = NO;
        }
        
        [self updateRenderPassDescriptor];
        
        if ([_delegate respondsToSelector:@selector(metalViewRender:)]) {
            [_delegate metalViewRender:self];
        }
        
        _currentDrawable = nil;
    }
}

@end
