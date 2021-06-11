//
//  ContentView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/09.
//

import SwiftUI

let unitLength: CGFloat = 312
let titlebarHeight: CGFloat = 27

struct ContentView: View {
    @State var page = 1
    
    var body: some View {
        ZStack {
            SetupPages(page: $page)
            
            PageTurner(page: $page)
        }
        .font(.custom("Yanone Kaffeesatz", size: 16))
        // Translucent background
        .frame(width: unitLength, height: unitLength)
        .ignoresSafeArea()
        .frame(width: unitLength, height: unitLength-titlebarHeight)
        .background(EffectsView(
            material: .sidebar,
            blendingMode: .behindWindow).ignoresSafeArea())
    }
}
