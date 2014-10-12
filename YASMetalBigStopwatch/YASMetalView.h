//
//  YASMetalView.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>
#import <UIKit/UIKit.h>

@protocol YASMetalViewDelegate;

@interface YASMetalView : UIView

@property (nonatomic, weak) id<YASMetalViewDelegate> delegate;
@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;
@property (nonatomic, readonly) MTLRenderPassDescriptor *renderPassDescriptor;
@property (nonatomic) NSUInteger sampleCount;

- (void)display;
- (void)releaseRenderPassDescriptor;

@end

@protocol YASMetalViewDelegate <NSObject>

@optional

- (void)metalViewDidResize:(YASMetalView *)view;
- (void)metalViewRender:(YASMetalView *)view;

@end