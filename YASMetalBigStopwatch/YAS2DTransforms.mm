//
//  YAS2DTransforms.c
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YAS2DTransforms.h"

float4x4 yas2d_scale(const float x, const float y)
{
    return matrix_from_diagonal((float4){x, y, 1.0f, 1.0f});
}

float4x4 yas2d_translate(const float x, const float y)
{
    float4x4 matrix = matrix_identity_float4x4;
    matrix.columns[3].x = x;
    matrix.columns[3].y = y;
    return matrix;
}

float4x4 yas2d_rotate(const float degrees)
{
    float radians = degrees * M_PI / 180.0f;
    float3 vec = normalize((float3){0.0f, 0.0f, 1.0f});
    float cos = cosf(radians);
    float cos_inv = 1.0f - cos;
    float sin = sinf(radians);
    
    float4x4 matrix = {
        (float4){cos + cos_inv * vec.x * vec.x, cos_inv * vec.x * vec.y + vec.z * sin, cos_inv * vec.x * vec.z - vec.y * sin, 0.0f},
        (float4){cos_inv * vec.x * vec.y - vec.z * sin, cos + cos_inv * vec.y * vec.y, cos_inv * vec.y * vec.z + vec.x * sin, 0.0f},
        (float4){cos_inv * vec.x * vec.z + vec.y * sin, cos_inv * vec.y * vec.z - vec.x * sin, cos + cos_inv * vec.z * vec.z, 0.0f}, 
        (float4){0.0f, 0.0f, 0.0f, 1.0f}
    };
    
    return matrix;
}

float4x4 yas2d_ortho(const float left, const float right, const float bottom, const float top, const float near, const float far)
{
    float width = 1.0f / (right - left);
    float height = 1.0f / (top - bottom);
    float depth  = 1.0f / (far - near);
    
    float4x4 matrix = {
        (float4){2.0f * width, 0.0f, 0.0f, 0.0f},
        (float4){0.0f, 2.0f * height, 0.0f, 0.0f},
        (float4){0.0f, 0.0f, depth, 0.0f},
        (float4){- width * (left + right), - height * (top + bottom), - depth * near, 1.0f}
    };
    
    return matrix;
}