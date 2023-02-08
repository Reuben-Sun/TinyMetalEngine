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
    var gBufferRenderPass: GBufferRenderPass
    var lightingRenderPass: LightingRenderPass
    var objectIdRenderPass: ObjectIdRenderPass
    var shadowRenderPass: ShadowRenderPass
    var tiledDeferredRenderPass: TiledDeferredRenderPass?
    
    var options: Options
    
    var shadowCamera = OrthographicCamera()
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
        gBufferRenderPass = GBufferRenderPass(view: metalView)
        lightingRenderPass = LightingRenderPass(view: metalView)
        objectIdRenderPass = ObjectIdRenderPass()
        shadowRenderPass = ShadowRenderPass()
        
        // tile-basez，仅支持苹果芯片
        options.tiledSupported = device.supportsFamily(.apple3)
        if options.tiledSupported{
            tiledDeferredRenderPass = TiledDeferredRenderPass(view: metalView)
        }
        else{
            print("WARNING: TBDR features not supported. Reverting to Forward Rendering")
            tiledDeferredRenderPass = nil
            options.renderPath = .forward
        }
        
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
        gBufferRenderPass.resize(view: view, size: size)
        lightingRenderPass.resize(view: view, size: size)
        objectIdRenderPass.resize(view: view, size: size)
        shadowRenderPass.resize(view: view, size: size)
        tiledDeferredRenderPass?.resize(view: view, size: size)
    }
    
    func draw(scene: GameScene, in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        updateUniforms(scene: scene)
        updateParams(scene: scene)
        
        //绘制Select Mode
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
        
        //阴影投射
        shadowRenderPass.draw(commandBuffer: commandBuffer,
                              scene: scene,
                              uniforms: uniforms,
                              params: params)
        switch options.renderPath{
        case .deferred:
            gBufferRenderPass.shadowTexture = shadowRenderPass.shadowTexture
            gBufferRenderPass.draw(
                commandBuffer: commandBuffer,
                scene: scene,
                uniforms: uniforms,
                params: params)
            //传递GBuffer
            lightingRenderPass.albedoTexture = gBufferRenderPass.albedoTexture
            lightingRenderPass.normalTexture = gBufferRenderPass.normalTexture
            lightingRenderPass.positionTexture = gBufferRenderPass.positionTexture
            lightingRenderPass.descriptor = descriptor
            lightingRenderPass.draw(
                commandBuffer: commandBuffer,
                scene: scene,
                uniforms: uniforms,
                params: params)
        case .forward:
            forwardRenderPass.descriptor = descriptor
            forwardRenderPass.shadowTexture = shadowRenderPass.shadowTexture
            forwardRenderPass.draw(
                commandBuffer: commandBuffer,
                scene: scene,
                uniforms: uniforms,
                params: params)
        case .tiled:
            tiledDeferredRenderPass?.shadowTexture = shadowRenderPass.shadowTexture
            tiledDeferredRenderPass?.descriptor = descriptor
            tiledDeferredRenderPass?.draw(
                commandBuffer: commandBuffer,
                scene: scene,
                uniforms: uniforms,
                params: params)
        }
        
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func updateUniforms(scene: GameScene) {
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        
        shadowCamera.viewSize = 16
        shadowCamera.far = 16
        let sun = scene.sceneLights.lights[0]
        shadowCamera = OrthographicCamera.createShadowCamera(using: scene.camera, lightPosition: sun.position)
        uniforms.shadowProjectionMatrix = shadowCamera.projectionMatrix
        uniforms.shadowViewMatrix = float4x4(eye: shadowCamera.position, center: shadowCamera.center, up: [0, 1, 0])
    }
    
    func updateParams(scene: GameScene) {
        params.lightCount = UInt32(scene.sceneLights.lights.count)
        params.cameraPosition = scene.camera.position
    }
}

