//
//  YAS2DTransforms.h
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import <simd/simd.h>

using namespace simd;

float4x4 yas2d_scale(const float x, const float y);
float4x4 yas2d_translate(const float x, const float y);
float4x4 yas2d_rotate(float degree);
float4x4 yas2d_ortho(const float left, const float right, const float bottom, const float top, const float near, const float far);
