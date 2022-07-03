//
//  File.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/3.
//

import MetalKit

/// 所有渲染管线的基类
protocol RenderPass {
    var label: String { get }
    var descriptor: MTLRenderPassDescriptor? { get set }
    mutating func resize(view: MTKView, size: CGSize)
    func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params)
}

extension RenderPass{
    /// 构建深度测试
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    static func makeTexture(size: CGSize,
                            pixelFormat: MTLPixelFormat,
                            label: String,
                            storageMode: MTLStorageMode = .private,
                            usage: MTLTextureUsage = [.shaderRead, .renderTarget]
    ) -> MTLTexture? {
        let width = Int(size.width)
        let height = Int(size.height)
        guard width > 0 && height > 0 else { return nil }
        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat,
                                                                   width: width,
                                                                   height: height,
                                                                   mipmapped: false)
        textureDesc.storageMode = storageMode
        textureDesc.usage = usage
        guard let texture = Renderer.device.makeTexture(descriptor: textureDesc) else {
            fatalError("Failed to create texture")
        }
        texture.label = label
        return texture
    }
}
