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
            .background(EffectsView(
                material: .popover,
                blendingMode: .behindWindow).ignoresSafeArea())
            
//            if store.showMatchPanel {
                MatchPanel()
//            }
        }
        .frame(width: (store.showMatchPanel ? 3 : 1) * unitLength, alignment: .leading)
    }
}

