//
//  Movement.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

import Foundation

/// 移动参数
enum Settings {
    static var rotationSpeed: Float {2.0}
    static var translationSpeed: Float {3.0}
    static var mouseScrollSensitivity: Float {0.1}
    static var mousePanSensitivity: Float {0.008}
}

protocol Movement where Self: Transformable {
}

extension Movement {
    func updateInput(deltaTime: Float) -> Transform {
        var transform = Transform()
        let rotationAmount = deltaTime * Settings.rotationSpeed
        let input = InputController.shared
        if input.keysPressed.contains(.leftArrow) {
            transform.rotation.y -= rotationAmount
        }
        if input.keysPressed.contains(.rightArrow) {
            transform.rotation.y += rotationAmount
        }
        return transform
    }
}
