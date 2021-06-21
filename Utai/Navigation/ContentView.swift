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
                    .frame(minHeight: 226, idealHeight: Metrics.unitLength-3, maxHeight: Metrics.unitLength+249)
            }
        }
        .frame(width: Metrics.unitLength)
        .font(.custom("Yanone Kaffeesatz", size: 16))
    }
}

struct WrappedContentView: View {
    @StateObject private var store = Store()
    
    var body: some View {
        ContentView().environmentObject(store)
    }
}
