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
    
    var keysPressed: Set<GCKeyCode> = []
    
    private init() {
        let center = NotificationCenter.default
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
        #if os(macOS)
        NSEvent.addLocalMonitorForEvents(matching: [.keyUp, .keyDown]) { _ in nil}
        #endif
    }
}
