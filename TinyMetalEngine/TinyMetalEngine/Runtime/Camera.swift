//
//  Camera.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

import CoreGraphics

/// 相机
/// Swift知识：protocol是协议的关键词
protocol Camera: Transformable {
    var projectionMatrix: float4x4 {get}
    var viewMatrix: float4x4 {get}
    mutating func update(size: CGSize)
    mutating func update(deltaTime: Float)
}

/// 第一人称相机
struct FPCamera: Camera {
    var transform = Transform()
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100
    var projectionMatrix: float4x4 {
        float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) * float4x4(rotation: rotation)).inverse
    }
    
    mutating func update(deltaTime: Float) {
        
    }
}


