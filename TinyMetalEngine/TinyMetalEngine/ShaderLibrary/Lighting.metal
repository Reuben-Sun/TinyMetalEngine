//
//  Lighting.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

#include <metal_stdlib>
using namespace metal;

#import "Lighting.h"
#import "CustomCore.h"

//着色函数库
constant float pi = 3.1415926535897932384626433832795;

//获得灯光衰减信息
float getAttenuation(Light light, float3 positionWS){
    float attenuation = 0;
    
    switch (light.type) {
        case Dirtctional: {
            attenuation = 1;
            break;
        }
        case Point: {
            float d = distance(light.position, positionWS);
            attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
            break;
        }
        case Spot: {
            float d = distance(light.position, positionWS);
            float3 lightDir = normalize(light.position - positionWS);
            float3 coneDir = normalize(light.coneDirection);
            float spotResult = dot(lightDir, -coneDir);
            if(spotResult > cos(light.coneAngle)){
                attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                attenuation *= pow(spotResult, light.coneAttenuation);
            }
            break;
        }
        case Ambient: {
            attenuation = 1;
            break;
        }
        case unused: {
            break;
        }
    }
    return attenuation;
}

float3 phongLighting(float3 normalWS,
                     float3 positionWS,
                     constant Params &params,
                     constant Light *lights,
                     Material material)
{
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    
    float3 baseColor = material.baseColor;
    float materialShininess = material.shininess;
    float3 materialSpecularColor = material.specularColor;
    
    
    
    for (uint i = 0; i < params.lightCount; i++){
        Light light = lights[i];
        float attenuation = getAttenuation(light, positionWS);
        float3 lightDir = normalize(-light.position);
        float3 reflectionDir = reflect(lightDir, normalWS);
        float3 viewDir = normalize(params.cameraPosition);
        
        float diffuseIntensity = saturate(-dot(lightDir, normalWS));
        float specularIntensity = pow(saturate(dot(reflectionDir, viewDir)), materialShininess);
        
        diffuseColor += light.color * baseColor * diffuseIntensity * attenuation;
        specularColor += light.specularColor * materialSpecularColor * specularIntensity;
    }
    return diffuseColor + specularColor + ambientColor;
}


// diffuse
float3 computeDiffuse(Material material,
                      float3 normalWS,
                      float3 lightDir)
{
    float nDotL = saturate(dot(normalWS, lightDir));
    float3 diffuse = float3(((1.0/pi) * material.baseColor) * (1.0 - material.metallic));
    diffuse = float3(material.baseColor) * (1.0 - material.metallic);
    return diffuse * nDotL * material.ambientOcclusion;
}

float G1V(float nDotV, float k)
{
    return 1.0f / (nDotV * (1.0f - k) + k);
}

// specular optimized-ggx
float3 computeSpecular(float3 normal,
                       float3 viewDirection,
                       float3 lightDirection,
                       float roughness,
                       float3 F0)
{
    float alpha = roughness * roughness;
    float3 halfVector = normalize(viewDirection + lightDirection);
    float nDotL = saturate(dot(normal, lightDirection));
    float nDotV = saturate(dot(normal, viewDirection));
    float nDotH = saturate(dot(normal, halfVector));
    float lDotH = saturate(dot(lightDirection, halfVector));
    
    float3 F;
    float D, G;
    
    // D
    float alphaSqr = alpha * alpha;
    float denom = nDotH * nDotH * (alphaSqr - 1.0) + 1.0f;
    D = alphaSqr / (pi * denom * denom);
    
    // F
    float lDotH5 = pow(1.0 - lDotH, 5);
    F = F0 + (1.0 - F0) * lDotH5;
    
    // G
    float k = alpha / 2.0f;
    G = G1V(nDotL, k) * G1V(nDotV, k);
    
    float3 specular = nDotL * D * F * G;
    return specular;
}

float3 calculatePoint(Light light,
                      float3 position,
                      float3 normal,
                      Material material)
{
    float d = distance(light.position, position);
    float3 lightDirection = normalize(light.position - position);
    float attenuation = 1.0 / (light.attenuation.x +
                               light.attenuation.y * d + light.attenuation.z * d * d);
    
    float diffuseIntensity =
    saturate(dot(lightDirection, normal));
    float3 color = light.color * material.baseColor * diffuseIntensity;
    color *= attenuation;
    return color;
}


