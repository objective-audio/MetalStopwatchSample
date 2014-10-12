//
//  YAS2DSharedTypes.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <simd/simd.h>

#define YAS2DBlurWeightMaxCount 32

using namespace simd;

typedef struct {
    float2 position;
    float2 texCoord;
} vertex2d_t;

typedef struct {
    float4x4 matrix;
    float4 color;
    float blurWeight[YAS2DBlurWeightMaxCount];
    uint8_t blurWeightCount;
} __attribute__((aligned(16))) uniforms2d_t;
