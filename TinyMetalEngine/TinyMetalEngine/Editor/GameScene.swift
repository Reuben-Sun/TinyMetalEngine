//
//  GameScene.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

import MetalKit

/// 创建场景
struct GameScene {
    //模型
    lazy var sphere: Model = {
        Model(device: Renderer.device, name: "sphere.obj")
    }()
    lazy var gizmo: Model = {
        Model(device: Renderer.device, name: "gizmo.usd")
    }()
    
    var models: [Model] = []
    var camera = ArcballCamera()
    
    init() {
        camera.distance = 2.5
        camera.transform = defaultView
        models = [sphere, gizmo]
    }
    
    /// 更新场景
    /// Swift知识：mutating是异变函数的关键词，使得不可变的结构体，通过创建新结构体赋值的方式可变
    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        if input.keysPressed.contains(.one) {
            camera.transform = Transform()
        }
        if input.keysPressed.contains(.two) {
            camera.transform = defaultView
        }
        camera.update(deltaTime: deltaTime)
        calculateGizmo()
    }
    
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    var defaultView: Transform {
        Transform(
            position: [-1.18, 1.57, -1.28],
            rotation: [-0.73, 13.3, 0.0])
    }
    
    /// 辅助线
    mutating func calculateGizmo() {
        var forwardVector: float3 {
            let lookat = float4x4(eye: camera.position, center: .zero, up: [0, 1, 0])
            return [
                lookat.columns.0.z, lookat.columns.1.z, lookat.columns.2.z
            ]
        }
        var rightVector: float3 {
            let lookat = float4x4(eye: camera.position, center: .zero, up: [0, 1, 0])
            return [
                lookat.columns.0.x, lookat.columns.1.x, lookat.columns.2.x
            ]
        }
        
        let heightNear = 2 * tan(camera.fov / 2) * camera.near
        let widthNear = heightNear * camera.aspect
        let cameraNear = camera.position + forwardVector * camera.near
        let cameraUp = float3(0, 1, 0)
        let bottomLeft = cameraNear - (cameraUp * (heightNear / 2)) - (rightVector * (widthNear / 2))
        gizmo.position = bottomLeft
        gizmo.position = (forwardVector - rightVector) * 10
    }
}
