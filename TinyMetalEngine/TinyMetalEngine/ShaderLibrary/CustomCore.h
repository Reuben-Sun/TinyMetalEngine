//
//  CustomCore.h
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#ifndef CustomCore_h
#define CustomCore_h

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 uv;
    float3 color;
    float3 positionWS;
    float3 normalWS;
    float3 tangentWS;
    float3 bitangentWS;
};

constant float pi = 3.1415926535897932384626433832795;

struct Input {
    
};

struct Surface {
    
};

#endif /* CustomCore_h */
