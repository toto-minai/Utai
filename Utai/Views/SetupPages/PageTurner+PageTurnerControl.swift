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
        EffectView(material: .titlebar, blendingMode: .withinWindow)
            .opacity(store.infoMode ? 1 : 0)
    }
    
    var body: some View {
        ZStack {
            Group {
                Button("", action: turnToPage1)
                    .keyboardShortcut("1", modifiers: .command)
                Button("", action: turnToPage2)
                    .keyboardShortcut("2", modifiers: .command)
                Button("", action: turnToPage3)
                    .keyboardShortcut("3", modifiers: .command)
            }
            .hidden()
            
            VStack {
                Spacer()
                
                if store.page != 3 || store.infoMode {
                    HStack(spacing: 8) {
                        PageTurnerControl(page: $store.page, target: 1,
                                          systemName: "circle.fill", helpText: "Import (⌘1)")
                            .onTapGesture { turnToPage1() }
                        
                        PageTurnerControl(page: $store.page, target: 2,
                                          systemName: turner == 1 ? "triangle.fill" : "circle.fill", helpText: "Choose (⌘2)")
                            .onTapGesture { turnToPage2() }
                        
                        PageTurnerControl(page: $store.page, target: 3,
                                          systemName: turner == 1 ? "square.fill" : "circle.fill", helpText: "Match (⌘3)")
                            .onTapGesture { turnToPage3() }
                    }
                    .padding(8)
                    .background(blurredBackground)
                    .cornerRadius(4)
                }
            }
            .padding(.bottom, Metrics.lilSpacing+Metrics.lilIconLength)
            .frame(height: Metrics.unitLength)
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
