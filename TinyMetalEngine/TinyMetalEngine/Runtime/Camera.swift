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
        let transform = updateInput(deltaTime: deltaTime)
        rotation += transform.rotation
        position += transform.position
    }
}

extension FPCamera: Movement {}

/// 锚点相机
struct ArcballCamera: Camera {
    var transform = Transform()
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100
    
    var minDistance: Float = 0.0
    var maxDistance: Float = 20
    var target: float3 = [0, 0, 0]
    var distance: Float = 25
    
    var projectionMatrix: float4x4 {
        float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    var viewMatrix: float4x4 {
      let matrix: float4x4
      if target == position {
        matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
      } else {
        matrix = float4x4(eye: position, center: target, up: [0, 1, 0])
      }
      return matrix
    }
    
    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        let scrollSensitivity = Settings.mouseScrollSensitivity
        distance -= (input.mouseScroll.x + input.mouseScroll.y) * scrollSensitivity
        distance = min(maxDistance, distance)
        distance = max(minDistance, distance)
        input.mouseScroll = .zero
        
        if input.leftMouseDown {
          let sensitivity = Settings.mousePanSensitivity
          rotation.x += input.mouseDelta.y * sensitivity
          rotation.y += input.mouseDelta.x * sensitivity
          rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
          input.mouseDelta = .zero
        }
        
        let rotateMatrix = float4x4(rotationYXZ: [-rotation.x, rotation.y, 0])
        let distanceVector = float4(0, 0, -distance, 0)
        let rotatedVector = rotateMatrix * distanceVector
        position = target + rotatedVector.xyz
    }
}
