//
//  Vertex.metal
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#include <metal_stdlib>
using namespace metal;
#import "../Lighting.h"
#import "../CustomCore.h"


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
    out.tangentWS = uniforms.normalMatrix * in.tangent;
    out.bitangentWS = uniforms.normalMatrix * in.bitangent;
    return out;
}

fragment float4 fragment_main(constant Params &params [[buffer(12)]],
                              VertexOut in [[stage_in]],
                              texture2d<float> baseColorTexture [[texture(BaseColor)]],
                              texture2d<float> normalTexture [[texture(NormalTexture)]],
                              constant Material &_material [[buffer(MaterialBuffer)]],
                              constant Light *lights [[buffer(LightBuffer)]])
{
    Material mat = _material;
    
    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear);   //采样器
    //baseColor
    if (!is_null_texture(baseColorTexture)) {
        mat.baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    }
    
    float3 normalWS;
    if (is_null_texture(normalTexture)) {
        normalWS = in.normalWS;
    } else {
        normalWS = normalTexture.sample(textureSampler, in.uv * params.tiling).rgb;
        normalWS = normalWS * 2 - 1;
        float3x3 TBN = float3x3(in.tangentWS, in.bitangentWS, in.normalWS);
        normalWS = TBN * normalWS;
    }
    
    float3 color = phongLighting(normalWS, in.positionWS, params, lights, mat);
    return float4(color, 1);
}


