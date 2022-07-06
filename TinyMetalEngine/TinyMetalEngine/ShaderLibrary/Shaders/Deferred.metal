//
//  Deferred.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/6.
//

#include <metal_stdlib>
using namespace metal;

#import "../Lighting.h"
#import "../CustomCore.h"
#import "../Sample.h"

fragment GBufferOut fragment_gBuffer(VertexOut in [[stage_in]],
                                     constant Material &material [[buffer(MaterialBuffer)]],
                                     depth2d<float> shadowTexture [[texture(ShadowTexture)]])
{
    GBufferOut out;
    out.albedo = float4(material.baseColor, 1);
    out.albedo.a = getShadowAttenuation(in.shadowPosition, shadowTexture);
    out.normal = float4(normalize(in.normalWS), 1.0);
    out.position = float4(in.positionWS, 1.0);
    return out;
}

constant float3 vertices[6] = {
    float3(-1,  1,  0),    // triangle 1
    float3( 1, -1,  0),
    float3(-1, -1,  0),
    float3(-1,  1,  0),    // triangle 2
    float3( 1,  1,  0),
    float3( 1, -1,  0)
};

vertex VertexOut vertex_quad(uint vertexID [[vertex_id]])
{
    VertexOut out {
        .position = float4(vertices[vertexID], 1)
    };
    return out;
}

fragment float4 fragment_deferredSun(VertexOut in [[stage_in]],
                                     constant Params &params [[buffer(ParamsBuffer)]],
                                     constant Light *lights [[buffer(LightBuffer)]],
                                     texture2d<float> albedoTexture [[texture(BaseColor)]],
                                     texture2d<float> normalTexture [[texture(NormalTexture)]],
                                     texture2d<float> positionTexture [[texture(NormalTexture + 1)]])
{
    return float4(1,0,0,1);
}

fragment float4 fragment_pointLight(VertexOut in [[stage_in]],
                                     constant Params &params [[buffer(ParamsBuffer)]],
                                     constant Light *lights [[buffer(LightBuffer)]],
                                     texture2d<float> albedoTexture [[texture(BaseColor)]],
                                     texture2d<float> normalTexture [[texture(NormalTexture)]],
                                     texture2d<float> positionTexture [[texture(NormalTexture + 1)]])
{
    return float4(1,0,0,1);
}
