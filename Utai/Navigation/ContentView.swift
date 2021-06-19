//
//  ContentView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/09.
//

import SwiftUI

struct ContentView: View {
    public static let windowWillResize = Notification.Name("windowWillResize")
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var store: Store
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SetupPages()
                
                ReferencesControl(page: $store.page)
                
                PageTurner()
            }
            .frame(height: Metrics.unitLength)
            
            if store.page == 3 && store.referenceURL == nil {
                ZStack {
                    Text("Match Here!")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(EffectsView(material: .contentBackground,
                                        blendingMode: .behindWindow))
                .onAppear {
                    NotificationCenter.default.post(name: Self.windowWillResize, object: CGSize(width: 312, height: 624))
                }
            }
        }
        .frame(width: Metrics.unitLength)
        .font(.custom("Yanone Kaffeesatz", size: 16))
        // Translucent background
        .frame(height: (store.page == 3 && store.referenceURL == nil) ? 2*Metrics.unitLength : Metrics.unitLength)
        .ignoresSafeArea()
        .frame(height: (store.page == 3 && store.referenceURL == nil) ? 2*Metrics.unitLength-Metrics.titlebarHeight : Metrics.unitLength-Metrics.titlebarHeight)
        .background(EffectsView(
            material: .sidebar,
            blendingMode: .behindWindow).ignoresSafeArea())
    }
}

struct WrappedContentView: View {
    @StateObject private var store = Store()
    
    var body: some View {
        ContentView().environmentObject(store)
    }
}
