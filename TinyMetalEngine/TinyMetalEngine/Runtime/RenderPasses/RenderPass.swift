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
}
