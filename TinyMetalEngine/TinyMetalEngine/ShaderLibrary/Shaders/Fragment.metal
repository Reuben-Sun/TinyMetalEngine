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
    constexpr sampler textureSampler;
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    return float4(baseColor, 1);
}
