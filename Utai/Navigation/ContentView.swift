//
//  ContentView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/09.
//

import SwiftUI

let unitLength: CGFloat = 312
let titlebarHeight: CGFloat = 27
let lilSpacing: CGFloat = 8
let lilSpacing2x: CGFloat = 16
let lilIconLength: CGFloat = 12

struct ContentView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        HStack (spacing: 0) {
            ZStack {
                SetupPages()
                
                PageTurner()
                
                ReferencesControl(page: $store.page)
            }
            .font(.custom("Yanone Kaffeesatz", size: 16))
            // Translucent background
            .frame(width: unitLength, height: unitLength)
            .ignoresSafeArea()
            .frame(width: unitLength, height: unitLength-titlebarHeight)
            .background(
//                Color.clear
                EffectsView(
                material: .popover,
                blendingMode: .behindWindow).ignoresSafeArea()
            )
            
            MatchPanel()
        }
        .frame(width: (store.showMatchPanel ? 3 : 1) * unitLength, alignment: .leading)
    }
}

