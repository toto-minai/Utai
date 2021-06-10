//
//  ContentView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/09.
//

import SwiftUI

let squareLength: CGFloat = 312
let titlebarHeight: CGFloat = 27

struct ContentView: View {
    var body: some View {
        ZStack {
            Text("Drag or")
        }
        // Translucent background
        .frame(width: squareLength, height: squareLength)
        .ignoresSafeArea()
        .frame(width: squareLength, height: squareLength-titlebarHeight)
        .background(EffectsView(
            material: .sidebar,
            blendingMode: .behindWindow).ignoresSafeArea())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct EffectsView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        
        return view
    }
    
    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        view.material = material
        view.blendingMode = blendingMode
    }
}
