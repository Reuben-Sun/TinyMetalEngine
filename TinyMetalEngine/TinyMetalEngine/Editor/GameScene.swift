//
//  GameScene.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

import MetalKit

/// 创建场景
struct GameScene {
    static var objectId: UInt32 = 1
    lazy var train: Model = {
      createModel(name: "train.obj")
    }()
    lazy var treefir1: Model = {
      createModel(name: "treefir.obj")
    }()
    lazy var treefir2: Model = {
      createModel(name: "treefir.obj")
    }()
    lazy var treefir3: Model = {
      createModel(name: "treefir.obj")
    }()
    lazy var ground: Model = {
        Model(name: "large_plane.obj", objectId: 0)
    }()
    
    lazy var gizmo: Model = {
        createModel(name: "gizmo.usd")
    }()
    
    var models: [Model] = []
    var camera = ArcballCamera()
    var sceneLights = Lights()
    
    init() {
      camera.transform = defaultView
      camera.target = [0, 1, 0]
      camera.distance = 4
      treefir1.position = [-1, 0, 2.5]
      treefir2.position = [-3, 0, -2]
      treefir3.position = [1.5, 0, -0.5]
      models = [treefir1, treefir2, treefir3, train, ground]
    }
    
    func createModel(name: String) -> Model {
        let model = Model(name: name, objectId: Self.objectId)
        Self.objectId += 1
        return model
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
            position: [3.2, 3.1, 1.0],
            rotation: [-0.6, 10.7, 0.0])
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
