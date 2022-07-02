//
//  Lighting.h
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

float3 phongLighting(float3 normalWS,
                     float3 positionWS,
                     constant Params &params,
                     constant Light *lights,
                     Material material);

#endif /* Lighting_h */
