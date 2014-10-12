//
//  YASSWCircleButtonNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWButtonNode.h"

@interface YASSWCircleButtonNode : YASSWButtonNode

@property (nonatomic) float radius;
@property (nonatomic) NSUInteger titleIndex;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithRadius:(float)radius texture:(YAS2DTexture *)texture titles:(NSArray *)titles fontSize:(CGFloat)fontSize lineWidth:(CGFloat)lineWidth;

- (void)rotate;

@end
