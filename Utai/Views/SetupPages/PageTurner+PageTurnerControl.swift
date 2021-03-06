//
//  PageTurner.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

struct PageTurner: View {
    @EnvironmentObject var store: Store
    @AppStorage(Settings.pageTurnerIconType) var turner: Int = 1
    
    var blurredBackground: some View {
        Rectangle().fill(.ultraThinMaterial)
            .opacity(store.infoMode ? 1 : 0)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                if store.page != 3 || store.infoMode {
                    HStack(spacing: 8) {
                        PageTurnerControl(page: $store.page, target: 1,
                                          systemName: "circle.fill", helpText: "Import")
                            .onTapGesture { turnToPage1() }
                        
                        PageTurnerControl(page: $store.page, target: 2,
                                          systemName: turner == 1 ? "triangle.fill" : "circle.fill", helpText: "Choose")
                            .onTapGesture { turnToPage2() }
                        
                        PageTurnerControl(page: $store.page, target: 3,
                                          systemName: turner == 1 ? "square.fill" : "circle.fill", helpText: "Match")
                            .onTapGesture { turnToPage3() }
                    }
                    .padding(8)
                    .background(blurredBackground)
                    .cornerRadius(4)
                }
            }
            .padding(.bottom, Metrics.lilSpacing+Metrics.lilIconLength)
            .frame(height: Metrics.unitLength)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("turnToPage1"))) { _ in
                turnToPage1()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("turnToPage2"))) { _ in
                turnToPage2()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("turnToPage3"))) { _ in
                turnToPage3()
            }
        }
    }
}

extension PageTurner {
    private func turnToPage1() {
        store.page = 1
        store.infoMode = false
    }
    
    private func turnToPage2() {
        if store.localUnit == nil { return }
        
        store.page = 2
        store.infoMode = false
    }
    
    private func turnToPage3() {
        if store.localUnit == nil { return }
    }
}

struct PageTurnerControl: View {
    @Binding var page: Int
    
    let target: Int
    let systemName: String
    let helpText: String
    
    var body: some View {
        ButtonMini(alwaysHover: page == target,
                   systemName: systemName, helpText: helpText)
    }
}
