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
    var forwardRenderPass: ForwardRenderPass
    var objectIdRenderPass: ObjectIdRenderPass
    
    var options: Options
    
    
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
        self.options = options
        forwardRenderPass = ForwardRenderPass(view: metalView, options: options)
        objectIdRenderPass = ObjectIdRenderPass()
        super.init()
        
        metalView.clearColor = MTLClearColor(
            red: 0.93,
            green: 0.97,
            blue: 1.9,
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
    }
    
}

extension Renderer {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        forwardRenderPass.resize(view: view, size: size)
        objectIdRenderPass.resize(view: view, size: size)
    }
    
    func draw(scene: GameScene, in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        updateUniforms(scene: scene)
        updateParams(scene: scene)
        
        if options.renderChoice == .selectItem {
            objectIdRenderPass.draw(commandBuffer: commandBuffer,
                                    scene: scene,
                                    uniforms: uniforms,
                                    params: params)
            //传递深度RT
            forwardRenderPass.idTexture = objectIdRenderPass.idTexture
        } else {
            forwardRenderPass.idTexture = nil
        }
        
        forwardRenderPass.descriptor = descriptor
        forwardRenderPass.draw(commandBuffer: commandBuffer,
                               scene: scene,
                               uniforms: uniforms,
                               params: params)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateUniforms(scene: GameScene) {
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
    }
    
    func updateParams(scene: GameScene) {
        params.lightCount = UInt32(scene.sceneLights.lights.count)
        params.cameraPosition = scene.camera.position
    }
}

