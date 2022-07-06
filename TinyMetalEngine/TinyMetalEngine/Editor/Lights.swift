//
//  Lights.swift
//  TinyMetalEngine
//
//  Created by 孙政 on 2022/7/2.
//

import MetalKit

struct Lights {
    /// 总光源（包含点光、方向光）
    var lights: [Light] = []
    var dirLights: [Light]
    var pointLights: [Light]
    
    var lightsBuffer: MTLBuffer
    var dirBuffer: MTLBuffer
    var pointBuffer: MTLBuffer
    
    /// 构建默认灯光
    /// - Returns: 一个默认参数的方向光
    static func buildDefaultLight() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.attenuation = [1, 0, 0]
        light.type = Dirtctional
        return light
    }
    
    let sunlight: Light = {
        var light = Self.buildDefaultLight()
        light.position = [3, 3, -2]
        return light
    }()
    
    let fillLight: Light = {
      var light = Self.buildDefaultLight()
      light.position = [-5, 1, 3]
      light.color = float3(repeating: 0.5)
      return light
    }()
    
    let ambientLight: Light = {
        var light = Self.buildDefaultLight()
        light.color = [0.0, 0.1, 0.05]
        light.type = Ambient
        return light
    }()
    //红色点光
    let redLight: Light = {
        var light = Self.buildDefaultLight()
        light.type = Point
        light.position = [-0.8, 0.76, -0.18]
        light.color = [1, 0, 0]
        light.attenuation = [0.5, 2, 1]
        return light
    }()
    //Spot光
    lazy var spotlight: Light = {
        var light = Self.buildDefaultLight()
        light.type = Spot
        light.position = [-0.64, 0.64, -1.07]
        light.color = [1, 0, 1]
        light.attenuation = [1, 0.5, 0]
        light.coneAngle = Float(40).degreesToRadians
        light.coneDirection = [0.5, -0.7, 1]
        light.coneAttenuation = 8
        return light
    }()
    
    /// 创造很多随机点光源
    /// - Parameters:
    ///   - count: 点光
    ///   - min: 点光位置xyz的最小值
    ///   - max: 点光位置xyz的最大值
    /// - Returns: 点光数组
    static func createPointLights(count: Int, min: float3, max: float3) -> [Light] {
      let colors: [float3] = [
        float3(1, 0, 0),
        float3(1, 1, 0),
        float3(1, 1, 1),
        float3(0, 1, 0),
        float3(0, 1, 1),
        float3(0, 0, 1),
        float3(0, 1, 1),
        float3(1, 0, 1)
      ]
      var lights: [Light] = []
      for _ in 0..<count {
        var light = Self.buildDefaultLight()
        light.type = Point
        let x = Float.random(in: min.x...max.x)
        let y = Float.random(in: min.y...max.y)
        let z = Float.random(in: min.z...max.z)
        light.position = [x, y, z]
        light.color = colors[Int.random(in: 0..<colors.count)]
        light.attenuation = [0.5, 2, 1]
        lights.append(light)
      }
      return lights
    }
    
    static func createBuffer(lights: [Light]) -> MTLBuffer {
      var lights = lights
      return Renderer.device.makeBuffer(
        bytes: &lights,
        length: MemoryLayout<Light>.stride * lights.count,
        options: [])!
    }
    
    /// 灯光初始化
    init() {
        dirLights = [sunlight, ambientLight]
        dirBuffer = Self.createBuffer(lights: dirLights)
        lights = dirLights
        pointLights = Self.createPointLights(
          count: 20,
          min: [-3, 0.1, -3],
          max: [3, 0.3, 3])
        pointBuffer = Self.createBuffer(lights: pointLights)
        lights += pointLights
        lightsBuffer = Self.createBuffer(lights: lights)
    }
}
