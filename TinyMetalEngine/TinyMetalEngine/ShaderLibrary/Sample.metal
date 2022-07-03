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
float getShadowAttenuation(float4 shadowPos, depth2d<float> shadowTexture)
{
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

//返回采样后的材质
Material sampleTexture(Material _mat,
                    texture2d<float> baseColorTexture,
                    texture2d<float> roughnessTexture,
                    texture2d<float> metallicTexture,
                    texture2d<float> aoTexture,
                    texture2d<uint> idTexture,
                    float2 uv,
                    Params params)
{
    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear);
    Material mat = _mat;
    
    // extract color
    if (!is_null_texture(baseColorTexture)) {
        mat.baseColor = baseColorTexture.sample(textureSampler, uv * params.tiling).rgb;
    }
    
    if (!is_null_texture(idTexture)) {
        uint2 coord = uint2(params.touchX * 2, params.touchY * 2);
        uint objectID = idTexture.read(coord).r;
        if (params.objectId != 0 && objectID == params.objectId) {
            mat.baseColor = float3(0.9, 0.5, 0);
        }
    }
    
    //metallic
    if (!is_null_texture(metallicTexture)) {
        mat.metallic = metallicTexture.sample(textureSampler, uv).r;
    }
    
    //roughness
    if (!is_null_texture(roughnessTexture)) {
        mat.roughness = roughnessTexture.sample(textureSampler, uv).r;
    }
    
    //ambient occlusion
    if (!is_null_texture(aoTexture)) {
        mat.ambientOcclusion = aoTexture.sample(textureSampler, uv).r;
    }
    
    return mat;
}

//返回世界空间法线
float3 getNormal(texture2d<float> normalTexture, float2 uv, float3 normalWS, float3 tangentWS, float3 bitangentWS, Params params)
{
    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear);
    float3 normal;
    if (is_null_texture(normalTexture)) {
        normal = normalWS;
    } else {
        float3 normalValue = normalTexture.sample(textureSampler, uv * params.tiling).xyz * 2.0 - 1.0;
        normal = float3x3(tangentWS, bitangentWS, normalWS) * normalValue;
    }
    normal = normalize(normal);
    return normal;
}
