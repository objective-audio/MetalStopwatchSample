//
//  YASSWTimeNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DStringsNode.h"

@class YAS2DTexture;

@interface YASSWTimeNode : YAS2DStringsNode

@property (nonatomic) NSTimeInterval time;

- (instancetype)initWithStringsData:(YAS2DStringsData *)info NS_UNAVAILABLE;
- (instancetype)initWithTexture:(YAS2DTexture *)texture fontName:(NSString *)fontName fontSize:(CGFloat)fontSize;

@end
