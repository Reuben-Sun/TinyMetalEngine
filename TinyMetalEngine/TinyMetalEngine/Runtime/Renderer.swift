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
    var depthStencilState: MTLDepthStencilState!
    
    lazy var house: Model = {
        Model(name: "lowpoly-house.obj")
    }()
    lazy var ground: Model = {
        var ground = Model(name: "plane.obj")
        ground.tiling = 16
        return ground
    }()
    
    var timer: Float = 0
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
        let modelVertexFunction = library?.makeFunction(name: "vertex_main")
        let quadVertexFunction = library?.makeFunction(name: "vertex_quad")
        let fragmentFunction =
        library?.makeFunction(name: "fragment_main")
        
        // create the two pipeline state objects
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = quadVertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        do {
            quadPipelineState =
            try device.makeRenderPipelineState( descriptor: pipelineDescriptor)
            pipelineDescriptor.vertexFunction = modelVertexFunction
            pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
            modelPipelineState =
            try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        depthStencilState = Renderer.buildDepthStencilState()
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
    
    /// 构建 depth stencil state
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = true
        descriptor.depthCompareFunction = .less
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        let projectionMatrix =
        float4x4(
            projectionFov: Float(70).degreesToRadians,
            near: 0.1,
            far: 100,
            aspect: aspect)
        uniforms.projectionMatrix = projectionMatrix
        
        params.width = UInt32(size.width)
        params.height = UInt32(size.height)
    }
    
    /// 画模型
    func renderModel(encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(modelPipelineState)
        
        timer += 0.005
        uniforms.viewMatrix = float4x4(translation: [0, 1.5, -5]).inverse
        encoder.setRenderPipelineState(modelPipelineState)
        //一个旋转的房子
        house.rotation.y = sin(timer)
        house.render(encoder: encoder, uniforms: uniforms, params: params)
        //地面
        ground.scale = 40
        ground.rotation.y = sin(timer)
        ground.render(encoder: encoder, uniforms: uniforms, params: params)
    }
    
    /// 画平面
    func renderQuad(encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBytes(
          &uniforms,
          length: MemoryLayout<Uniforms>.stride,
          index: UniformsBuffer.index)

        encoder.setFragmentBytes(
          &params,
          length: MemoryLayout<Uniforms>.stride,
          index: ParamsBuffer.index)
        encoder.setRenderPipelineState(quadPipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
    
    
    func draw(in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            return
        }
        
        renderEncoder.setDepthStencilState(depthStencilState)
        
        if options.renderChoice == .model {
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

