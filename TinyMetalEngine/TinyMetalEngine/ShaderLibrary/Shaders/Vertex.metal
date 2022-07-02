//
//  Vertex.metal
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#include <metal_stdlib>
using namespace metal;
#import "../Common.h"
#import "../CustomCore.h"

struct VertexIn {
  float4 position [[attribute(Position)]];
  float3 normal [[attribute(Normal)]];
  float2 uv [[attribute(UV)]];
    float3 color [[attribute(Color)]];
};

vertex VertexOut vertex_main(
                             VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(11)]])
{
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    out.normal = in.normal;
    out.uv = in.uv;
    out.color = in.color;
    out.positionWS = (uniforms.modelMatrix * in.position).xyz;
    out.normalWS = uniforms.normalMatrix * in.normal;
    return out;
}



