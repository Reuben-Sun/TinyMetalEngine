//
//  Lighting.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

#include <metal_stdlib>
using namespace metal;

#import "Lighting.h"

//着色函数库

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
        switch (light.type) {
            case Dirtctional: {
                float3 lightDir = normalize(-light.position);
                float3 reflectionDir = reflect(lightDir, normalWS);
                float3 viewDir = normalize(params.cameraPosition);
            
                float diffuseIntensity = saturate(-dot(lightDir, normalWS));
                float specularIntensity = pow(saturate(dot(reflectionDir, viewDir)), materialShininess);
                
                diffuseColor += light.color * baseColor * diffuseIntensity;
                specularColor += light.specularColor * materialSpecularColor * specularIntensity;
                break;
            }
            case Point: {
                float d = distance(light.position, positionWS);
                float3 lightDir = normalize(light.position - positionWS);
                float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                float diffuseIntensity = saturate(dot(lightDir, normalWS));
                diffuseColor += light.color * baseColor * diffuseIntensity * attenuation;
                break;
            }
            case Spot: {
                float d = distance(light.position, positionWS);
                float3 lightDir = normalize(light.position - positionWS);
                float3 coneDir = normalize(light.coneDirection);
                float spotResult = dot(lightDir, -coneDir);
                if(spotResult > cos(light.coneAngle)){
                    float attenuation = 1.0 / (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
                    attenuation *= pow(spotResult, light.coneAttenuation);
                    float diffuseIntensity = saturate(dot(lightDir, normalWS));
                    diffuseColor += light.color * baseColor * diffuseIntensity * attenuation;
                }
                break;
            }
            case Ambient: {
                ambientColor += light.color;
                break;
            }
            case unused: {
                break;
            }
        }
    }
    return diffuseColor + specularColor + ambientColor;
}
