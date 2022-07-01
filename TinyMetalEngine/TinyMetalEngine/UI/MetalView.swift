//
//  MetalView.swift
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

import SwiftUI
import MetalKit

struct MetalView: View {
    let options: Options
    @State private var renderer: Renderer?
    @State private var metalView = MTKView()
    var body: some View {
        VStack {
            MetalViewRepresentable(
                renderer: renderer,
                metalView: $metalView,
                options: options)
            .onAppear {
                renderer = Renderer(
                    metalView: metalView,
                    options: options)
            }
        }
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias MyMetalView = NSView
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
typealias MyMetalView = UIView
#endif

struct MetalViewRepresentable: ViewRepresentable {
    let renderer: Renderer?
    @Binding var metalView: MTKView
    let options: Options
    
#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        return metalView
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        updateMetalView()
    }
#endif
    
    func updateMetalView() {
        renderer?.options = options
    }
}

struct MetalView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MetalView(options: Options())
            Text("Metal View")
        }
    }
}

