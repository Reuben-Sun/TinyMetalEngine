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
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
} Uniforms;

#endif /* Common_h */
