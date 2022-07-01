//
//  TextureController.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/1.
//

import MetalKit

enum TextureController {
    static var textures: [String: MTLTexture] = [:]
    
    /// 加载贴图
    /// - Parameter filename: 贴图名称（只支持png）
    /// - Returns: 贴图
    static func loadTexture(filename: String) throws -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft, .SRGB: false]
        let fileExtension = URL(fileURLWithPath: filename).pathExtension.isEmpty ? "png" : nil
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else{
            print("Failed to load \(filename)")
            return nil
        }
        
        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        print("loaded texture: \(url.lastPathComponent)")
        return texture
    }
    
    /// 返回贴图，内置一个缓存机制
    /// - Parameter filename: 贴图名称（只支持png）
    /// - Returns: 贴图
    static func texture(filename: String) -> MTLTexture? {
        if let tex = textures[filename] {
            return tex
        }
        let tex = try? loadTexture(filename: filename)
        if tex != nil {
            textures[filename] = tex
        }
        return tex
    }
}


