//
//  TiledDeferredRenderPass.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2023/2/8.
//

import MetalKit

struct TiledDeferredRenderPass: RenderPass{
    var label = "Tiled Deferred Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    
    var gBufferPSO: MTLRenderPipelineState
    var sunLightPSO: MTLRenderPipelineState
    var pointLightPSO: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    let lightingDepthStencilState: MTLDepthStencilState?
    weak var shadowTexture: MTLTexture?
    var albedoTexture: MTLTexture?
    var normalTexture: MTLTexture?
    var positionTexture: MTLTexture?
    var depthTexture: MTLTexture?
    var icosphere = Model(name: "icosphere.obj")
    
    init(view: MTKView) {
        gBufferPSO = PipelineStates.createGBufferPSO(
            colorPixelFormat: view.colorPixelFormat,
            tiled: true)
        sunLightPSO = PipelineStates.createSunLightPSO(
            colorPixelFormat: view.colorPixelFormat,
            tiled: true)
        pointLightPSO = PipelineStates.createPointLightPSO(
            colorPixelFormat: view.colorPixelFormat,
            tiled: true)
        depthStencilState = Self.buildDepthStencilState()
        lightingDepthStencilState = Self.buildLightingDepthStencilState()
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        let frontFaceStencil = MTLStencilDescriptor()
        frontFaceStencil.stencilCompareFunction = .always
        frontFaceStencil.stencilFailureOperation = .keep
        frontFaceStencil.depthFailureOperation = .keep
        frontFaceStencil.depthStencilPassOperation = .incrementClamp
        descriptor.frontFaceStencil = frontFaceStencil
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
      }
    
    static func buildLightingDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = false
        let frontFaceStencil = MTLStencilDescriptor()
        frontFaceStencil.stencilCompareFunction = .notEqual
        frontFaceStencil.stencilFailureOperation = .keep
        frontFaceStencil.depthFailureOperation = .keep
        frontFaceStencil.depthStencilPassOperation = .keep
        descriptor.frontFaceStencil = frontFaceStencil
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    mutating func resize(view: MTKView, size: CGSize) {
        //将贴图类型设为memoryless
        albedoTexture = Self.makeTexture(
            size: size,
            pixelFormat: .bgra8Unorm,
            label: "Albedo Texture",
            storageMode: .memoryless)
        normalTexture = Self.makeTexture(
            size: size,
            pixelFormat: .rgba16Float,
            label: "Normal Texture",
            storageMode: .memoryless)
        positionTexture = Self.makeTexture(
            size: size,
            pixelFormat: .rgba16Float,
            label: "Position Texture",
            storageMode: .memoryless)
        depthTexture = Self.makeTexture(
            size: size,
            pixelFormat: .depth32Float_stencil8,
            label: "Depth Texture",
            storageMode: .memoryless)
    }
    
    func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params) {
        guard let viewCurrentRenderPassDescriptor = descriptor else {
            return
        }
        
        // MARK: G-buffer pass
        let descriptor = viewCurrentRenderPassDescriptor
        let textures = [
            albedoTexture,
            normalTexture,
            positionTexture
        ]
        //将贴图存储操作设为dontCare
        for (index, texture) in textures.enumerated() {
            let attachment =
            descriptor.colorAttachments[RenderTargetAlbedo.index + index]
            attachment?.texture = texture
            attachment?.loadAction = .clear
            attachment?.storeAction = .dontCare
            attachment?.clearColor =
            MTLClearColor(red: 0.73, green: 0.92, blue: 1, alpha: 1)
        }
        descriptor.depthAttachment.texture = depthTexture
        descriptor.stencilAttachment.texture = depthTexture
        
        // MARK: 很离谱，显式指定Tile大小后，带宽、GPU时间大幅提高
//        descriptor.tileWidth = 32
//        descriptor.tileHeight = 32
//        descriptor.threadgroupMemoryLength = MemoryLayout<Light>.size * 8
        
        guard let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor
                ) else { return }
        
        drawGBufferRenderPass(
            renderEncoder: renderEncoder,
            scene: scene,
            uniforms: uniforms,
            params: params)
        
        drawLightingRenderPass(
            renderEncoder: renderEncoder,
            scene: scene,
            uniforms: uniforms,
            params: params)
        renderEncoder.endEncoding()
    }
    
    // MARK: - G-buffer pass support
    func drawGBufferRenderPass(
        renderEncoder: MTLRenderCommandEncoder,
        scene: GameScene,
        uniforms: Uniforms,
        params: Params
    ) {
        renderEncoder.label = "G-buffer render pass"
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(gBufferPSO)
        renderEncoder.setFragmentTexture(shadowTexture, index: ShadowTexture.index)
        
        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                params: params)
        }
    }
    
    // MARK: - Lighting pass support
    func drawLightingRenderPass(
        renderEncoder: MTLRenderCommandEncoder,
        scene: GameScene,
        uniforms: Uniforms,
        params: Params
    ) {
        renderEncoder.label = "Lighting render pass"
        renderEncoder.setDepthStencilState(lightingDepthStencilState)
        var uniforms = uniforms
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)
        
        drawSunLight(
            renderEncoder: renderEncoder,
            scene: scene,
            params: params)
        drawPointLight(
            renderEncoder: renderEncoder,
            scene: scene,
            params: params)
    }
    
    func drawSunLight(
        renderEncoder: MTLRenderCommandEncoder,
        scene: GameScene,
        params: Params
    ) {
        renderEncoder.pushDebugGroup("Sun Light")
        renderEncoder.setRenderPipelineState(sunLightPSO)
        var params = params
        params.lightCount = UInt32(scene.sceneLights.dirLights.count)
        renderEncoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: ParamsBuffer.index)
        renderEncoder.setFragmentBuffer(
            scene.sceneLights.dirBuffer,
            offset: 0,
            index: LightBuffer.index)
        renderEncoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 6)
        renderEncoder.popDebugGroup()
    }
    
    func drawPointLight(
        renderEncoder: MTLRenderCommandEncoder,
        scene: GameScene,
        params: Params
    ) {
        renderEncoder.pushDebugGroup("Point lights")
        renderEncoder.setRenderPipelineState(pointLightPSO)
        renderEncoder.setVertexBuffer(
            scene.sceneLights.pointBuffer,
            offset: 0,
            index: LightBuffer.index)
        renderEncoder.setFragmentBuffer(
            scene.sceneLights.pointBuffer,
            offset: 0,
            index: LightBuffer.index)
        guard let mesh = icosphere.meshes.first,
              let submesh = mesh.submeshes.first else { return }
        for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
            renderEncoder.setVertexBuffer(
                vertexBuffer,
                offset: 0,
                index: index)
        }
        renderEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: submesh.indexCount,
            indexType: submesh.indexType,
            indexBuffer: submesh.indexBuffer,
            indexBufferOffset: submesh.indexBufferOffset,
            instanceCount: scene.sceneLights.pointLights.count)
        renderEncoder.popDebugGroup()
    }
    
}
