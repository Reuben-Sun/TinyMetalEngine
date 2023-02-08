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
    uint2 coord = uint2(in.position.xy);
    float4 albedo = albedoTexture.read(coord);
    float3 normal = normalTexture.read(coord).xyz;
    float3 position = positionTexture.read(coord).xyz;
    Material material {
        .baseColor = albedo.xyz,
        .specularColor = float3(0),
        .shininess = 500
    };
    float3 color = phongLighting(normal,
                                 position,
                                 params,
                                 lights,
                                 material);
    color *= albedo.a;
    return float4(color, 1);
}

fragment float4 fragment_tiled_deferredSun(VertexOut in [[stage_in]],
                                           constant Params &params [[buffer(ParamsBuffer)]],
                                           constant Light *lights [[buffer(LightBuffer)]],
                                           GBufferOut gBuffer)
{
    float4 albedo = gBuffer.albedo;
    float3 normal = gBuffer.normal.xyz;
    float3 position = gBuffer.position.xyz;
    Material material {
        .baseColor = albedo.xyz,
        .specularColor = float3(0),
        .shininess = 500
    };
    float3 color = phongLighting(normal,
                                 position,
                                 params,
                                 lights,
                                 material);
    color *= albedo.a;
    return float4(color, 1);
}

struct PointLightIn {
    float4 position [[attribute(Position)]];
};

struct PointLightOut {
    float4 position [[position]];
    uint instanceId [[flat]];
};

vertex PointLightOut vertex_pointLight(PointLightIn in [[stage_in]],
                                       constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                                       constant Light *lights [[buffer(LightBuffer)]],
                                       uint instanceId [[instance_id]])
{
    float4 lightPosition = float4(lights[instanceId].position, 0);
    float4 position =
    uniforms.projectionMatrix * uniforms.viewMatrix * (in.position + lightPosition);
    PointLightOut out {
        .position = position,
        .instanceId = instanceId
    };
    return out;
}

fragment float4 fragment_pointLight(PointLightOut in [[stage_in]],
                                    texture2d<float> normalTexture [[texture(NormalTexture)]],
                                    texture2d<float> positionTexture
                                    [[texture(NormalTexture + 1)]],
                                    constant Light *lights [[buffer(LightBuffer)]])
{
    Light light = lights[in.instanceId];
    uint2 coords = uint2(in.position.xy);
    float3 normal = normalTexture.read(coords).xyz;
    float3 position = positionTexture.read(coords).xyz;
    
    Material material {
        .baseColor = 1
    };
    float3 lighting = calculatePoint(light, position, normal, material);
    lighting *= 0.5;
    return float4(lighting, 1);
}

fragment float4 fragment_tiled_pointLight(PointLightOut in [[stage_in]],
                                          constant Light *lights [[buffer(LightBuffer)]],
                                          GBufferOut gBuffer)
{
    Light light = lights[in.instanceId];
    float3 normal = gBuffer.normal.xyz;
    float3 position = gBuffer.position.xyz;
    
    Material material {
        .baseColor = 1
    };
    float3 lighting = calculatePoint(light, position, normal, material);
    lighting *= 0.5;
    return float4(lighting, 1);
}
