//
//  Fragment.metal
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#include <metal_stdlib>
using namespace metal;
#import "../Common.h"
#import "../CustomCore.h"


fragment float4 fragment_main(constant Params &params [[buffer(12)]], VertexOut in [[stage_in]], texture2d<float> baseColorTexture [[texture(BaseColor)]])
{
    constexpr sampler textureSampler(filter::linear, address::repeat);   //采样器，采样方式为线性滤波+重复
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    return float4(baseColor, 1);
}
