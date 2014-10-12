//
//  YASSWTimeNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWTimeNode.h"
#import "YAS2DStringsData.h"

@implementation YASSWTimeNode

- (instancetype)initWithTexture:(YAS2DTexture *)texture fontName:(NSString *)fontName fontSize:(CGFloat)fontSize
{
    assert(texture);
    assert(fontName);
    assert(fontSize >= 1);
    
    YAS2DStringsData *stringsData = [[YAS2DStringsData alloc] initWithFontName:fontName fontSize:fontSize words:@"1234567890.:-" texture:texture];
    
    self = [super initWithStringsData:stringsData];
    if (self) {
        self.pivot = YAS2DStringsPivotCenter;
        self.time = 0;
    }
    return self;
}

- (void)setTime:(NSTimeInterval)time
{
    _time = time;
    self.text = [self.class timeString:time];
}

+ (NSString *)timeString:(NSTimeInterval)time
{
    NSString *resultString = nil;
    
    BOOL isMinus = (time < 0) ? YES : NO;
    if (isMinus) time *= -1;
    
    NSUInteger sec = (NSUInteger)time % 60;
    NSUInteger min = (NSUInteger)(time / 60) % 60;
    NSUInteger hour = (NSUInteger)(time / 3600);
    
    NSUInteger underPoint = (NSUInteger)(time * 100) % 100;
    if (hour > 0) {
        resultString = [NSString stringWithFormat:@"%lu:%.2lu:%.2lu.%.2lu", (unsigned long)hour, (unsigned long)min, (unsigned long)sec, (unsigned long)underPoint];
    } else {
        resultString = [NSString stringWithFormat:@"%lu:%.2lu.%.2lu", (unsigned long)min, (unsigned long)sec, (unsigned long)underPoint];
    }
    
    if (isMinus) {      
        resultString = [NSString stringWithFormat:@"-%@", resultString];
    }
    
    return resultString;
}

@end
