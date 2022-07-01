//
//  InputController.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

import GameController

class InputController {
    //单例
    static let shared = InputController()
    
    ///此刻按下的所有按键
    var keysPressed: Set<GCKeyCode> = []
    ///鼠标是否在左手
    var leftMouseDown = false
    ///记录鼠标位置移动
    var mouseDelta = Point.zero
    ///记录鼠标滚轮转动
    var mouseScroll = Point.zero
    
    private init() {
        let center = NotificationCenter.default
        //监听键盘
        center.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: nil) {
            notification in
            let keyboard = notification.object as? GCKeyboard
            keyboard?.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                if pressed {
                    self.keysPressed.insert(keyCode)
                } else {
                    self.keysPressed.remove(keyCode)
                }
            }
        }
        //监听鼠标
        center.addObserver(forName: .GCMouseDidConnect, object: nil, queue: nil) {
            notification in
            let mouse = notification.object as? GCMouse
            mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in self.leftMouseDown = pressed }
            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in self.mouseDelta = Point(x: deltaX, y: deltaY)}
            mouse?.mouseInput?.scroll.valueChangedHandler = { _, xValue, yValue in self.mouseScroll.x = xValue
                self.mouseScroll.y = yValue
            }
        }
        #if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown]) { _ in nil}
        #endif
    }
    
    /// 鼠标控制点
    struct Point {
        var x: Float
        var y: Float
        static let zero = Point(x: 0, y: 0)
    }
}
