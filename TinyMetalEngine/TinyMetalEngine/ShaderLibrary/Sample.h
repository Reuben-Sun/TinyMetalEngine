//
//  Sample.h
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/3.
//

#ifndef Sample_h
#define Sample_h

#import "Common.h"

float getShadowAttenuation(float4 shadowPos, depth2d<float> shadowTexture);

Material sampleTexture(Material mat,
                       texture2d<float> baseColorTexture,
                       texture2d<float> roughnessTexture,
                       texture2d<float> metallicTexture,
                       texture2d<float> aoTexture,
                       texture2d<uint> idTexture,
                       float2 uv,
                       Params params);

float3 getNormal(texture2d<float> normalTexture, float2 uv, float3 normalWS, float3 tangentWS, float3 bitangentWS, Params params);
#endif /* Sample_h */
