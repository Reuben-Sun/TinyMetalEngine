//
//  Options.swift
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

import Foundation

enum RenderChoice {
    case shadered, debugLight, selectItem
}

enum RenderPath {
    case forward, deferred
}

class Options: ObservableObject {
    @Published var renderChoice = RenderChoice.shadered
    @Published var renderPath = RenderPath.deferred
}
