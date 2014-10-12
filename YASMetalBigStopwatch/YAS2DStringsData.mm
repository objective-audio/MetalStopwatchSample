//
//  YAS2DStringsData.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DStringsData.h"
#import "YAS2DImage.h"
#import <CoreText/CoreText.h>

@implementation YAS2DStringsInfo {
    NSMutableData *_data;
}

- (instancetype)initWithWordCount:(NSUInteger)wordCount
{
    self = [super init];
    if (self) {
        _wordCount = wordCount;
        NSUInteger dataLength = wordCount * sizeof(vertex2d_t) * 4;
        _data = [[NSMutableData alloc] initWithLength:dataLength];
        _vertexPointer = (vertex2d_t *)[_data mutableBytes];
    }
    return self;
}

- (vertex2d_t *)vertexPointerAtWordIndex:(NSUInteger)wordIndex
{
    return &_vertexPointer[wordIndex * 4];
}

- (void)setWidth:(CGFloat)width
{
    _width = width;
}

@end

@implementation YAS2DStringsData {
    NSString *_words;
    NSMutableData *_vertexData;
    NSMutableData *_advanceData;
}

- (instancetype)initWithFontName:(NSString *)fontName
                        fontSize:(CGFloat)fontSize
                           words:(NSString *)words
                         texture:(YAS2DTexture *)texture
{
    self = [super init];
    if (self) {
        _words = [[NSString alloc] initWithFormat:@" %@", words];
        _texture = texture;
        
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
        [self setupWithFont:ctFont];
        CFRelease(ctFont);
    }
    return self;
}

- (void)setupWithFont:(CTFontRef)ctFont
{
    NSUInteger wordCount = _words.length;
    
    _vertexData = [[NSMutableData alloc] initWithLength:wordCount * sizeof(vertex2d_t) * 4];
    _advanceData = [[NSMutableData alloc] initWithLength:wordCount * sizeof(CGSize)];
    NSMutableData *glyphData = [[NSMutableData alloc] initWithLength:wordCount * sizeof(CGGlyph)];
    
    CGSize *advances = (CGSize *)[_advanceData mutableBytes];
    CGGlyph *glyphs = (CGGlyph *)[glyphData mutableBytes];
    UniChar characters[wordCount];
    
    CFStringGetCharacters((CFStringRef)_words, CFRangeMake(0, wordCount), characters);
    CTFontGetGlyphsForCharacters(ctFont, characters, glyphs, wordCount);
    CTFontGetAdvancesForGlyphs(ctFont, kCTFontDefaultOrientation, glyphs, advances, wordCount);
    
    CGFloat ascent = CTFontGetAscent(ctFont);
    CGFloat descent = CTFontGetDescent(ctFont);
    CGFloat stringHeight = descent + ascent;
    
    for (NSInteger i = 0; i < wordCount; i++) {
        CGRect imageRect = CGRectMake(0, roundf(-descent), ceilf(advances[i].width), ceilf(stringHeight));
        [self setVertexPositionWithRect:imageRect atWordIndex:i];
        MTLSize imageSize = {(NSUInteger)CGRectGetWidth(imageRect), (NSUInteger)CGRectGetHeight(imageRect), 1};
        YAS2DImage *image = [[YAS2DImage alloc] initWithPointSize:imageSize];
        [image draw:^(CGContextRef ctx) {
            CGContextSaveGState(ctx); {
                CGContextTranslateCTM(ctx, 0.0, CGRectGetHeight(imageRect));
                CGContextScaleCTM(ctx, 1.0, - 1.0);
                CGContextTranslateCTM(ctx, 0.0, descent);
                CGPathRef path = CTFontCreatePathForGlyph(ctFont, glyphs[i], NULL);
                CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
                CGContextAddPath(ctx, path);
                CGContextFillPath(ctx);
                CGPathRelease(path);
            } CGContextRestoreGState(ctx);
        }];
        
        MTLRegion textureRegion = [self.texture copyImage:image];
        [self setVertexTexCoordsWithRegion:textureRegion atWordIndex:i];
    }
}

- (vertex2d_t *)vertexPointerAtWordIndex:(NSUInteger)index
{
    vertex2d_t *pointer = (vertex2d_t *)[_vertexData mutableBytes];
    return &pointer[index * 4];
}

- (CGSize *)advancePointerAtWordIndex:(NSUInteger)index
{
    CGSize *pointer = (CGSize *)[_advanceData mutableBytes];
    return &pointer[index];
}

- (void)setVertexPositionWithRect:(CGRect)rect atWordIndex:(NSUInteger)index
{
    vertex2d_t *pointer = [self vertexPointerAtWordIndex:index];
    float minX = rect.origin.x;
    float minY = rect.origin.y;
    float maxX = minX + rect.size.width;
    float maxY = minY + rect.size.height;
    pointer[0].position[0] = pointer[2].position[0] = minX;
    pointer[0].position[1] = pointer[1].position[1] = minY;
    pointer[1].position[0] = pointer[3].position[0] = maxX;
    pointer[2].position[1] = pointer[3].position[1] = maxY;
}

- (void)setVertexTexCoordsWithRegion:(MTLRegion)region atWordIndex:(NSUInteger)index
{
    vertex2d_t *pointer = [self vertexPointerAtWordIndex:index];
    float minX = region.origin.x;
    float minY = region.origin.y;
    float maxX = minX + region.size.width;
    float maxY = minY + region.size.height;
    pointer[0].texCoord[0] = pointer[2].texCoord[0] = minX;
    pointer[0].texCoord[1] = pointer[1].texCoord[1] = maxY;
    pointer[1].texCoord[0] = pointer[3].texCoord[0] = maxX;
    pointer[2].texCoord[1] = pointer[3].texCoord[1] = minY;
}

- (const vertex2d_t *)vertexPointerForWord:(NSString *)word
{
    NSRange range = [_words rangeOfString:word];
    if (range.location == NSNotFound) {
        range = NSMakeRange(0, 1);
    }
    return [self vertexPointerAtWordIndex:range.location];
}

- (const CGSize *)advancePointerForWord:(NSString *)word
{
    NSRange range = [_words rangeOfString:word];
    if (range.location == NSNotFound) {
        range = NSMakeRange(0, 1);
    }
    return [self advancePointerAtWordIndex:range.location];
}

- (YAS2DStringsInfo *)stringsInfoForText:(NSString *)text pivot:(YAS2DStringsPivot)pivot
{
    NSUInteger wordCount = text.length;
    YAS2DStringsInfo *stringsInfo = [[YAS2DStringsInfo alloc] initWithWordCount:wordCount];
    
    CGFloat width = 0;
    
    for (NSInteger i = 0; i < wordCount; i++) {
        NSString *word = [text substringWithRange:NSMakeRange(i, 1)];
        const vertex2d_t *strPointer = [self vertexPointerForWord:word];
        vertex2d_t *pointer = [stringsInfo vertexPointerAtWordIndex:i];
        for (NSInteger j = 0; j < 4; j++) {
            pointer[j] = strPointer[j];
            pointer[j].position[0] += roundf(width);
        }
        const CGSize *advancePointer = [self advancePointerForWord:word];
        if (advancePointer) {
            width += advancePointer->width;
        }
    }
    
    width = ceil(width);
    
    stringsInfo.width = width;
    
    if (pivot != YAS2DStringsPivotLeft) {
        CGFloat offset = 0;
        if (pivot == YAS2DStringsPivotCenter) {
            offset = - width * 0.5;
        } else {
            offset = - width;
        }
        for (NSInteger i = 0; i < wordCount; i++) {
            vertex2d_t *pointer = [stringsInfo vertexPointerAtWordIndex:i];
            for (NSInteger j = 0; j < 4; j++) {
                pointer[j].position[0] += offset;
            }
        }
    }
    
    return stringsInfo;
}

@end
