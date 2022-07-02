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
};

#endif /* CustomCore_h */
