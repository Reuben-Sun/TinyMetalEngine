//
//  Common.h
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

//顶点函数输入
typedef struct {
    matrix_float4x4 modelMatrix;    //M矩阵
    matrix_float4x4 viewMatrix;     //V矩阵
    matrix_float4x4 projectionMatrix;   //P矩阵
    matrix_float3x3 normalMatrix;   //将法线转化为世界空间
} Uniforms;

//片元函数输入
typedef struct {
    uint width;
    uint height;
    uint tiling;
    uint lightCount;
    vector_float3 cameraPosition;
    uint objectId;
    uint touchX;
    uint touchY;
} Params;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2,
    Color = 3,
    Tangent = 4,
    Bitangent = 5
} Attributes;

typedef enum {
    VertexBuffer = 0,
    UVBuffer = 1,
    ColorBuffer = 2,
    TangentBuffer = 3,
    BitangentBuffer = 4,
    UniformsBuffer = 11,
    ParamsBuffer = 12,
    LightBuffer = 13,
    MaterialBuffer = 14
} BufferIndices;

typedef enum {
    BaseColor = 0,
    NormalTexture = 1,
    RoughnessTexture = 2,
    MetallicTexture = 3,
    AOTexture = 4
} TextureIndices;

//灯光种类
typedef enum {
    unused = 0,
    Dirtctional = 1,
    Spot = 2,
    Point = 3,
    Ambient = 4
} LightType;

//灯光参数
typedef struct {
    LightType type;
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float radius;
    vector_float3 attenuation;  //x: 恒定衰减系数，y: 线性衰减系数，z: 二次衰减系数
    float coneAngle;
    vector_float3 coneDirection;
    float coneAttenuation;
} Light;

typedef struct {
    vector_float3 baseColor;
    vector_float3 specularColor;
    float roughness;
    float metallic;
    float ambientOcclusion;
    float shininess;   //emission
} Material;     //Surface


#endif /* Common_h */
