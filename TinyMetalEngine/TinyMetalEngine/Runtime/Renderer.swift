//
//  Renderer.swift
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    var options: Options
    
    var pipelineState: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState?
    
    var uniforms = Uniforms()
    var params = Params()
    
    init(metalView: MTKView, options: Options) {
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
                  fatalError("GPU not available")
              }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        metalView.depthStencilPixelFormat = .depth32Float
        
        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction =
        library?.makeFunction(name: "fragment_main")
        
        // create the two pipeline state objects
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
            pipelineState =
            try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        depthStencilState = Renderer.buildDepthStencilState()
        self.options = options
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.9,
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
    
    /// 构建 depth stencil state
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = true
        descriptor.depthCompareFunction = .less
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
}

extension Renderer {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func updateUniforms(scene: GameScene) {
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
    }
    
    
    func draw(scene: GameScene, in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            return
        }
        
        updateUniforms(scene: scene)
        
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params)
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

