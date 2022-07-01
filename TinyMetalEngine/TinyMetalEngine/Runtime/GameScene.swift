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
    lazy var house: Model = {
        Model(name: "lowpoly-house.obj")
    }()
    lazy var ground: Model = {
        var ground = Model(name: "plane.obj")
        ground.tiling = 16
        ground.scale = 40
        return ground
    }()
    lazy var models: [Model] = [ground, house]
    /// 更新场景
    /// Swift知识：mutating是异变函数的关键词，使得不可变的结构体，通过创建新结构体赋值的方式可变
    mutating func update(deltaTime: Float) {
        ground.scale = 40
        camera.rotation.y = sin(deltaTime)
    }
    
    //相机
    var camera = FPCamera()
    init() {
        camera.position = [0, 1.5, -5]
    }
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    
    
}
