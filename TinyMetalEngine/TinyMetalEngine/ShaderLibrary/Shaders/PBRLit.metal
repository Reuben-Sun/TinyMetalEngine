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
#import "../Sample.h"

fragment float4 fragment_PBR(VertexOut in [[stage_in]],
                             constant Params &params [[buffer(ParamsBuffer)]],
                             constant Light *lights [[buffer(LightBuffer)]],
                             constant Material &_material [[buffer(MaterialBuffer)]],
                             texture2d<float> baseColorTexture [[texture(BaseColor)]],
                             texture2d<float> normalTexture [[texture(NormalTexture)]],
                             texture2d<float> roughnessTexture [[texture(RoughnessTexture)]],
                             texture2d<float> metallicTexture [[texture(MetallicTexture)]],
                             texture2d<float> aoTexture [[texture(AOTexture)]],
                             texture2d<uint> idTexture [[texture(IdBuffer)]],
                             depth2d<float> shadowTexture [[texture(ShadowTexture)]])
{
    Material material = sampleTexture(_material, baseColorTexture, roughnessTexture, metallicTexture, aoTexture, idTexture, in.uv, params);
    
    // normal map
    float3 normal = getNormal(normalTexture, in.uv, in.normalWS, in.tangentWS, in.bitangentWS, params);
    
    float3 viewDirection = normalize(params.cameraPosition);
    //着色
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
    
    //接受阴影
    float shadow = getShadowAttenuation(in.shadowPosition, shadowTexture);
    diffuseColor *= shadow;
    
    return float4(diffuseColor + specularColor, 1);
}




