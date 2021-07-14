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
                
                CustomTitleBar()
                    .forcingRefresh($store.forcedRefresh)
            }
            // Translucent background
            .frame(height: Metrics.unitLength)
            .ignoresSafeArea()
            .frame(height: Metrics.unitLength-Metrics.titlebarHeight)
            .background {
                #if SCREENSHOT_MODE
                #else
                EffectView(
                    material: colorScheme == .light ? .menu : .sidebar,
                    blendingMode: .behindWindow).ignoresSafeArea()
                #endif
            }
            // Forcing custom title bar to refresh when `colorScheme` changed
            .onChange(of: colorScheme) { _ in store.forcedRefresh.toggle() }
            
            if store.page == 3 && store.referenceURL == nil {
                MatchPanel()
                    .frame(height: Metrics.unitLength*1.618)
                    // .frame(minHeight: panelMinHeight, maxHeight: .infinity)
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
