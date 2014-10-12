//
//  Shaders.metal
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "YAS2DSharedTypes.h"

using namespace metal;

struct ColorInOut2d {
    float4 position [[position]];
    float4 color;
    float2 texCoord [[user(texturecoord)]];
};

vertex ColorInOut2d vertex2d(device vertex2d_t* vertex_array [[buffer(0)]],
                             constant uniforms2d_t& uniforms [[buffer(1)]],
                             unsigned int vid [[vertex_id]])
{
    ColorInOut2d out;
    
    float4 in_position = float4(float2(vertex_array[vid].position), 0.0, 1.0);
    out.position = uniforms.matrix * in_position;
    out.color = uniforms.color;
    out.texCoord = vertex_array[vid].texCoord;
    
    return out;
}

fragment float4 fragment2d(ColorInOut2d in [[stage_in]],
                           texture2d<float> tex2D [[texture(0)]],
                           sampler sampler2D [[sampler(0)]],
                           constant uniforms2d_t& uniforms[[buffer(0)]])
{
    return tex2D.sample(sampler2D, in.texCoord) * in.color;
}

fragment float4 fragment2d_unuse_texture(ColorInOut2d in [[stage_in]])
{
    return in.color;
}

fragment float4 fragment2d_blur_horizontal(ColorInOut2d in [[stage_in]],
                                           texture2d<float> tex2D [[texture(0)]],
                                           sampler sampler2D [[sampler(0)]],
                                           constant uniforms2d_t& uniforms[[buffer(0)]])
{
    float4 color = 0.0;
    float2 texCoord = float2(in.texCoord.x, in.texCoord.y);
    color += tex2D.sample(sampler2D, texCoord) * uniforms.blurWeight[0];
    for (int i = 1; i < uniforms.blurWeightCount; i++) {
        float weight = uniforms.blurWeight[i];
        float offset = (float)i;
        texCoord.x = in.texCoord.x + offset;
        color += tex2D.sample(sampler2D, texCoord) * weight;
        texCoord.x = in.texCoord.x - offset;
        color += tex2D.sample(sampler2D, texCoord) * weight;
    }
    return color * in.color;
}

fragment float4 fragment2d_blur_vertical(ColorInOut2d in [[stage_in]],
                                           texture2d<float> tex2D [[texture(0)]],
                                           sampler sampler2D [[sampler(0)]],
                                           constant uniforms2d_t& uniforms[[buffer(0)]])
{
    float4 color = 0.0;
    float2 texCoord = float2(in.texCoord.x, in.texCoord.y);
    color += tex2D.sample(sampler2D, texCoord) * uniforms.blurWeight[0];
    for (int i = 1; i < uniforms.blurWeightCount; i++) {
        float weight = uniforms.blurWeight[i];
        float offset = (float)i;
        texCoord.y = in.texCoord.y + offset;
        color += tex2D.sample(sampler2D, texCoord) * weight;
        texCoord.y = in.texCoord.y - offset;
        color += tex2D.sample(sampler2D, texCoord) * weight;
    }
    return color * in.color;
}

