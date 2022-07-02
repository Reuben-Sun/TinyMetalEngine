//
//  Fragment.metal
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#include <metal_stdlib>
using namespace metal;
#import "../Lighting.h"
#import "../CustomCore.h"


fragment float4 fragment_main(constant Params &params [[buffer(12)]],
                              VertexOut in [[stage_in]],
                              texture2d<float> baseColorTexture [[texture(BaseColor)]],
                              constant Light *lights [[buffer(LightBuffer)]])
{
    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear);   //采样器
    float3 baseColor;
    if (is_null_texture(baseColorTexture)) {
        baseColor = in.color;
    } else {
        baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    }
    
    float3 N = normalize(in.normalWS);
    float3 color = phongLighting(N, in.positionWS, params, lights, baseColor);
    return float4(color, 1);
}
