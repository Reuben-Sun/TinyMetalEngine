//
//  Fragment.metal
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#include <metal_stdlib>
using namespace metal;
#import "../ShaderLibrary/Lighting.h"
#import "../ShaderLibrary/CustomCore.h"


struct VertexDebugOut {
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex VertexDebugOut vertex_debug(
                              constant float3 *vertices [[buffer(0)]],
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                              uint id [[vertex_id]])
{
    matrix_float4x4 mvp = uniforms.projectionMatrix
    * uniforms.viewMatrix * uniforms.modelMatrix;
    VertexDebugOut out {
        .position = mvp * float4(vertices[id], 1),
        .point_size = 25.0
    };
    return out;
}

fragment float4 fragment_debug_point(
                                     float2 point [[point_coord]],
                                     constant float3 &color [[buffer(1)]])
{
    float d = distance(point, float2(0.5, 0.5));
    if (d > 0.5) {
        discard_fragment();
    }
    return float4(color, 1);
}

fragment float4 fragment_debug_line(
                                    constant float3 &color [[buffer(1)]])
{
    return float4(color ,1);
}
