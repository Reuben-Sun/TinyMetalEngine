//
//  ContentView.swift
//  TinyMetalEngine
//
//  Created by bytedance on 2022/7/1.
//

import SwiftUI

let size: CGFloat = 400
struct ContentView: View {
    @State var options = Options()
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                MetalView(options: options)
                    .border(Color.black, width: 2)
                    .frame(width: size * 2, height: size)
            }
            Picker(
                selection: $options.renderChoice,
                label: Text("Render Options")) {
                    Text("Shadered").tag(RenderChoice.shadered)
                    Text("DebugLight").tag(RenderChoice.debugLight)
                    Text("Select Item").tag(RenderChoice.selectItem)
                }
                .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
