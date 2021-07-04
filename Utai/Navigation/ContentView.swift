//
//  ContentView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/09.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var store: Store
    
    private var panelMinHeight: CGFloat {
        max(
            Metrics.unitLength,
            min(Metrics.unitLength*2,
                CGFloat(store.localUnit!.tracks.count+5) *
                    (Metrics.lilIconLength+Metrics.lilSpacing2x))
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SetupPages()
                
                ReferencesControl(page: $store.page)
                
                PageTurner()
            }
            // Translucent background
            .frame(height: Metrics.unitLength)
            .ignoresSafeArea()
            .frame(height: Metrics.unitLength-Metrics.titlebarHeight)
            .background(EffectsView(
                material: .sidebar,
                blendingMode: .behindWindow).ignoresSafeArea())
            
            if store.page == 3 && store.referenceURL == nil {
                MatchPanel()
                    .frame(minHeight: panelMinHeight, maxHeight: .infinity)
            }
        }
        .frame(width: Metrics.unitLength)
        .font(.custom("Yanone Kaffeesatz", size: 16))
        .animation(nil, value: store.infoMode)
        .animation(nil, value: store.page)
    }
}

struct WrappedContentView: View {
    @StateObject private var store = Store()
    
    var body: some View {
        ContentView().environmentObject(store)
    }
}
