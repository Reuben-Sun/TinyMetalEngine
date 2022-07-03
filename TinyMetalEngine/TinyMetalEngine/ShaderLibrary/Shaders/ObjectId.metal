//
//  ObjectId.metal
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/3.
//

#include <metal_stdlib>
using namespace metal;

#import "../Common.h"

struct FragmentOut {
    uint objectId [[color(0)]];
};

fragment FragmentOut fragment_objectId(constant Params &params [[buffer(ParamsBuffer)]])
{
    FragmentOut out {
        .objectId = params.objectId
    };
    return out;
}
