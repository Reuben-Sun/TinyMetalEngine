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
    
    var modelPipelineState: MTLRenderPipelineState!
    var quadPipelineState: MTLRenderPipelineState!
    
    lazy var model: Model = {
        Model(device: Renderer.device, name: "train.usd")
    }()
    
    var timer: Float = 0
    var uniforms = Uniforms()
    
    init(metalView: MTKView, options: Options) {
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        let modelVertexFunction = library?.makeFunction(name: "vertex_main")
        let quadVertexFunction = library?.makeFunction(name: "vertex_quad")
        let fragmentFunction =
        library?.makeFunction(name: "fragment_main")
        
        // create the two pipeline state objects
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = quadVertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat =
        metalView.colorPixelFormat
        do {
            quadPipelineState =
            try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor)
            pipelineDescriptor.vertexFunction = modelVertexFunction
            pipelineDescriptor.vertexDescriptor =
            MTLVertexDescriptor.defaultLayout
            modelPipelineState =
            try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        self.options = options
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 1.0,
            green: 1.0,
            blue: 0.9,
            alpha: 1.0)
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        let aspect =
        Float(view.bounds.width) / Float(view.bounds.height)
        let projectionMatrix =
        float4x4(
            projectionFov: Float(70).degreesToRadians,
            near: 0.1,
            far: 100,
            aspect: aspect)
        uniforms.projectionMatrix = projectionMatrix
    }
    
    func renderModel(encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(modelPipelineState)
        
        timer += 0.005
        uniforms.viewMatrix = float4x4(translation: [0, 0, -2]).inverse
        model.position.y = -0.6
        model.rotation.y = sin(timer)
        uniforms.modelMatrix = model.transform.modelMatrix
        encoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: 11)
        
        model.render(encoder: encoder)
    }
    
    func renderQuad(encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(quadPipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
    
    func draw(in view: MTKView) {
        guard
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }
        
        if options.renderChoice == .train {
            renderModel(encoder: renderEncoder)
        } else {
            renderQuad(encoder: renderEncoder)
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

