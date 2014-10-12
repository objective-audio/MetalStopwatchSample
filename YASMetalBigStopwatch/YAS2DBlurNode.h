//
//  YAS2DBlurNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DSquareNode.h"

@protocol MTLDevice;

@interface YAS2DBlurNode : YAS2DSquareNode

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic) float coef;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithSquareCount:(NSUInteger)squareCount dynamic:(BOOL)dynamic NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame textureSize:(MTLSize)textureSize;

@end
