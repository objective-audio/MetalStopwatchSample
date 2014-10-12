//
//  YAS2DStringsNode.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DSquareNode.h"
#import "YAS2DStringsData.h"

@interface YAS2DStringsNode : YAS2DNode

@property (nonatomic, readonly) YAS2DStringsData *stringsData;
@property (nonatomic, copy) NSString *text;
@property (nonatomic) YAS2DStringsPivot pivot;
@property (nonatomic) float4 color;
@property (nonatomic, readonly) float width;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStringsData:(YAS2DStringsData *)info;

@end
