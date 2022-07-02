//
//  PBRLit.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

#include <metal_stdlib>
using namespace metal;
#import "../Lighting.h"
#import "../CustomCore.h"

fragment float4 fragment_PBR(VertexOut in [[stage_in]],
                             constant Params &params [[buffer(ParamsBuffer)]],
                             constant Light *lights [[buffer(LightBuffer)]],
                             constant Material &_material [[buffer(MaterialBuffer)]],
                             texture2d<float> baseColorTexture [[texture(BaseColor)]],
                             texture2d<float> normalTexture [[texture(NormalTexture)]],
                             texture2d<float> roughnessTexture [[texture(RoughnessTexture)]],
                             texture2d<float> metallicTexture [[texture(MetallicTexture)]],
                             texture2d<float> aoTexture [[texture(AOTexture)]])
{
    constexpr sampler textureSampler(filter::linear,
                                     address::repeat,
                                     mip_filter::linear);
    
    Material material = _material;
    
    // extract color
    if (!is_null_texture(baseColorTexture)) {
        material.baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    }
    // extract metallic
    if (!is_null_texture(metallicTexture)) {
        material.metallic = metallicTexture.sample(textureSampler, in.uv).r;
    }
    // extract roughness
    if (!is_null_texture(roughnessTexture)) {
        material.roughness = roughnessTexture.sample(textureSampler, in.uv).r;
    }
    // extract ambient occlusion
    if (!is_null_texture(aoTexture)) {
        material.ambientOcclusion = aoTexture.sample(textureSampler, in.uv).r;
    }
    
    // normal map
    float3 normal;
    if (is_null_texture(normalTexture)) {
        normal = in.normalWS;
    } else {
        float3 normalValue = normalTexture.sample(textureSampler, in.uv * params.tiling).xyz * 2.0 - 1.0;
        normal = float3x3(in.tangentWS,
                          in.bitangentWS,
                          in.normalWS) * normalValue;
    }
    normal = normalize(normal);
    
    float3 viewDirection = normalize(params.cameraPosition);
    
    float3 specularColor = 0;
    float3 diffuseColor = 0;
    float3 F0 = mix(0.04, material.baseColor, material.metallic);
    for (uint i = 0; i < params.lightCount; i++) {
        Light light = lights[i];
        float attenuation = getAttenuation(light, in.positionWS);
        float3 lightDirection = normalize(light.position);
        
        specularColor += saturate(computeSpecular(normal,
                                 viewDirection,
                                 lightDirection,
                                 material.roughness,
                                 F0));
        
        diffuseColor += saturate(computeDiffuse(material,
                                normal,
                                lightDirection) * light.color * attenuation);
    }
    return float4(diffuseColor + specularColor, 1);
}




