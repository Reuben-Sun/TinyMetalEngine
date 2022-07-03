//
//  Sample.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/3.
//

#include <metal_stdlib>
using namespace metal;

#import "Sample.h"

//阴影图集采样
float getShadowAttenuation(float4 shadowPos, depth2d<float> shadowTexture){
    float attenuation = 1;
    float3 shadowPosition = shadowPos.xyz / shadowPos.w;
    float2 xy = shadowPosition.xy;
    xy = xy * 0.5 + 0.5;
    xy.y = 1 - xy.y;
    xy = saturate(xy);
    constexpr sampler s(coord::normalized, filter::linear, address::clamp_to_edge, compare_func::less);
    float shadow_sample = shadowTexture.sample(s, xy);
    
    if(shadowPosition.z > shadow_sample) {
        attenuation *= 0.5;
    }
    return attenuation;
}
