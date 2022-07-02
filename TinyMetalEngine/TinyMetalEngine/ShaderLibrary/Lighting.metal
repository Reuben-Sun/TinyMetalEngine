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
                     float3 baseColor)
{
    float3 diffuseColor = 0;
    float3 ambientColor = 0;
    float3 specularColor = 0;
    float materialShininess = 32;
    float3 materialSpecularColor = float3(1, 1, 1);
    
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
                break;
            }
            case Spot: {
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
