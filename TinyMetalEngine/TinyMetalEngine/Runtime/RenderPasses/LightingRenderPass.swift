//
//  LightingRenderPass.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/6.
//

import MetalKit

struct LightingRenderPass: RenderPass {
    let label = "Lighting Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    var sunLightPSO: MTLRenderPipelineState
    var pointLightPSO: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    weak var albedoTexture: MTLTexture?
    weak var normalTexture: MTLTexture?
    weak var positionTexture: MTLTexture?
    weak var stencilTexture: MTLTexture?
    var icosphere = Model(name: "icosphere.obj")
    
    func resize(view: MTKView, size: CGSize) {}
    
    init(view: MTKView){
        sunLightPSO = PipelineStates.createSunLightPSO(colorPixelFormat: view.colorPixelFormat)
        pointLightPSO = PipelineStates.createPointLightPSO(colorPixelFormat: view.colorPixelFormat)
        depthStencilState = Self.buildDepthStencilState()
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
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
    
    func draw(commandBuffer: MTLCommandBuffer,
              scene: GameScene,
              uniforms: Uniforms,
              params: Params
    ) {
        descriptor?.stencilAttachment.texture = stencilTexture
        descriptor?.depthAttachment.texture = stencilTexture
        descriptor?.stencilAttachment.loadAction = .load
        descriptor?.depthAttachment.loadAction = .dontCare
        
        guard let descriptor = descriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                  return
              }
        renderEncoder.label = label
        renderEncoder.setDepthStencilState(depthStencilState)
        var uniforms = uniforms
        renderEncoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)
        renderEncoder.setFragmentTexture(
            albedoTexture,
            index: BaseColor.index)
        renderEncoder.setFragmentTexture(
            normalTexture,
            index: NormalTexture.index)
        renderEncoder.setFragmentTexture(
            positionTexture, index:
                NormalTexture.index + 1)
        drawSunLight(
            renderEncoder: renderEncoder,
            scene: scene,
            params: params)
        drawPointLight(
            renderEncoder: renderEncoder,
            scene: scene,
            params: params)
        renderEncoder.endEncoding()
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
