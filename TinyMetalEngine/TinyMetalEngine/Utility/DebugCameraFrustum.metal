//
//  DebugCameraFrustum.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/3.
//

#include <metal_stdlib>
using namespace metal;

#include <metal_stdlib>
using namespace metal;

#import "../ShaderLibrary/Common.h"

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex VertexOut vertex_frustum(
                                constant float3 *vertices [[buffer(0)]],
                                constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                                uint id [[vertex_id]])
{
    float4 position = float4(vertices[id], 1);
    position = uniforms.projectionMatrix * uniforms.viewMatrix * position;
    VertexOut out {
        .position = position,
        .point_size = 25.0
    };
    return out;
}

fragment float4 fragment_frustum(
                                 float2 point [[point_coord]],
                                 constant float3 &color [[buffer(ColorBuffer)]])
{
    return float4(color ,1);
}


struct SphereIn {
    float4 position [[attribute(Position)]];
};

vertex float4 vertex_debug_cameraSphere(
                                        const SphereIn in [[stage_in]],
                                        constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    float4 position =
    uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * in.position;
    return position;
}

