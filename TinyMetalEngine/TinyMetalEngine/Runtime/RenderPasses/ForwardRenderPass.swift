//
//  ForwardRenderPass.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

import MetalKit

struct ForwardRenderPass: RenderPass {
    let label = "Forward Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    
    var pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    
    weak var idTexture: MTLTexture?
    weak var shadowTexture: MTLTexture?
    
    var options: Options
    
    init(view: MTKView, options: Options) {
        pipelineState = PipelineStates.createForwardPSO(colorPixelFormat: view.colorPixelFormat)
        depthStencilState = Self.buildDepthStencilState()
        self.options = options
    }
    
    
    
    mutating func resize(view: MTKView, size: CGSize) {
    }
    
    func draw(
        commandBuffer: MTLCommandBuffer,
        scene: GameScene,
        uniforms: Uniforms,
        params: Params
    ) {
        guard let descriptor = descriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                  return
              }
        renderEncoder.label = label
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setFragmentBuffer(scene.sceneLights.lightsBuffer, offset: 0, index: LightBuffer.index)
        renderEncoder.setFragmentTexture(idTexture, index: IdBuffer.index)
        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
        
        let input = InputController.shared
        var params = params
        params.touchX = UInt32(input.touchLocation?.x ?? 0)
        params.touchY = UInt32(input.touchLocation?.y ?? 0)
        
        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params)
        }
        
        if options.renderChoice == .debugLight {
            DebugLights.draw(lights: scene.sceneLights.lights, encoder: renderEncoder, uniforms: uniforms)
            var scene = scene
            DebugModel.debugDrawModel(renderEncoder: renderEncoder,
                                      uniforms: uniforms,
                                      model: scene.sun,
                                      color: [0.9, 0.8, 0.2])
            DebugCameraFrustum.draw(encoder: renderEncoder, scene: scene, uniforms: uniforms)
        } 
        

        renderEncoder.endEncoding()
    }
}
