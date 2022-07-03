//
//  Shadow.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/3.
//

#include <metal_stdlib>
using namespace metal;

#import "../Common.h"

struct VertexIn {
    float4 position [[attribute(0)]];
};

vertex float4
vertex_depth(const VertexIn in [[stage_in]],
             constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    matrix_float4x4 mvp =
    uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix
    * uniforms.modelMatrix;
    return mvp * in.position;
}
