//
//  VertexDescriptor.swift
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor? {
        MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
    }
}

extension MDLVertexDescriptor {
    static var defaultLayout: MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        //顶点坐标
        vertexDescriptor.attributes[Position.index] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        //顶点法线
        vertexDescriptor.attributes[Normal.index] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        
        vertexDescriptor.layouts[VertexBuffer.index] = MDLVertexBufferLayout(stride: offset)
        //uv
        vertexDescriptor.attributes[UV.index] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: 0,
            bufferIndex: UVBuffer.index)
        vertexDescriptor.layouts[UVBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float2>.stride)
        return vertexDescriptor
    }
}

extension Attributes {
  var index: Int {
    return Int(self.rawValue)
  }
}

extension BufferIndices {
  var index: Int {
    return Int(self.rawValue)
  }
}
