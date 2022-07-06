//
//  Lighting.h
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

float getAttenuation(Light light, float3 positionWS);

float3 phongLighting(float3 normalWS,
                     float3 positionWS,
                     constant Params &params,
                     constant Light *lights,
                     Material material);

float3 computeDiffuse(Material material,
                      float3 normalWS,
                      float3 lightDir);

// functions
float3 computeSpecular(float3 normal,
                       float3 viewDirection,
                       float3 lightDirection,
                       float roughness,
                       float3 F0);

float3 calculatePoint(Light light,
                      float3 position,
                      float3 normal,
                      Material material);
#endif /* Lighting_h */
