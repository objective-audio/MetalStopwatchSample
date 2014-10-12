//
//  YAS2DStringsData.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DTexture.h"
#import "YAS2DSharedTypes.h"

typedef NS_ENUM(NSUInteger, YAS2DStringsPivot) {
    YAS2DStringsPivotLeft,
    YAS2DStringsPivotCenter,
    YAS2DStringsPivotRight,
};

@interface YAS2DStringsInfo : NSObject

@property (nonatomic, readonly) vertex2d_t *vertexPointer;
@property (nonatomic, readonly) NSUInteger wordCount;
@property (nonatomic, readonly) CGFloat width;

- (vertex2d_t *)vertexPointerAtWordIndex:(NSUInteger)wordIndex;

@end

@interface YAS2DStringsData : NSObject

@property (nonatomic, readonly) YAS2DTexture *texture;

- (instancetype)initWithFontName:(NSString *)fontName
                        fontSize:(CGFloat)fontSize
                           words:(NSString *)words
                         texture:(YAS2DTexture *)texture;

- (YAS2DStringsInfo *)stringsInfoForText:(NSString *)text pivot:(YAS2DStringsPivot)pivot;

@end
