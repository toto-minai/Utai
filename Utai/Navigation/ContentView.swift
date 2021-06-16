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
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ZStack {
                    SetupPages()
                    
                    ReferencesControl(page: $store.page)
                }
                .frame(width: unitLength)

                if store.showMatchPanel {
                    if colorScheme == .light {
                        Rectangle()
                            .frame(width: 1, height: unitLength+2)
                            .foregroundColor(Color.secondary.opacity(0.4))
                    } else {
                        Rectangle()
                            .frame(width: 1, height: unitLength-1)
                            .foregroundColor(Color.secondary.opacity(0.4))
                            .offset(y: 0.5)
                    }
                    MatchPanel()
                        .frame(width: store.showMatchPanel ? unitLength : 0, alignment: .leading)
                        .background(EffectsView(
                            material: .contentBackground,
                            blendingMode: .behindWindow).ignoresSafeArea())
                }
            }
            
            if store.page == 3 { MatchView() }
            
            HStack(spacing: 0) {
                PageTurner()
                    .frame(width: unitLength)
                
                Spacer()
            }
            .frame(width: store.showMatchPanel ? 2*unitLength : unitLength, alignment: .leading)
        }
        .font(.custom("Yanone Kaffeesatz", size: 16))
        // Translucent background
        .frame(height: unitLength)
        .ignoresSafeArea()
        .frame(height: unitLength-titlebarHeight)
        .background(EffectsView(
            material: .sidebar,
            blendingMode: .behindWindow).ignoresSafeArea())
    }
}

