//
//  Common.h
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;    //M矩阵
    matrix_float4x4 viewMatrix;     //V矩阵
    matrix_float4x4 projectionMatrix;   //P矩阵
} Uniforms;

typedef struct {
    uint width;
    uint height;
    uint tiling;
} Params;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2,
    Color = 3
} Attributes;

typedef enum {
    VertexBuffer = 0,
    UVBuffer = 1,
    ColorBuffer = 2,
    UniformsBuffer = 11,
    ParamsBuffer = 12
} BufferIndices;

typedef enum {
    BaseColor = 0
} TextureIndices;
#endif /* Common_h */
