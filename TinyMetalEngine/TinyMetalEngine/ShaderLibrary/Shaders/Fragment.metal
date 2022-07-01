//
//  Fragment.metal
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#include <metal_stdlib>
using namespace metal;
#import "../Common.h"

struct VertexOut {
    float4 position [[position]];
    float3 normal;
};

fragment float4 fragment_main(VertexOut in [[stage_in]])
{
    return float4(in.normal, 1);
}
