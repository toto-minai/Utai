//
//  PageTurner.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

struct PageTurner: View {
    @EnvironmentObject var store: Store
    
    var blurredBackground: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .opacity(store.artworkMode ? 1 : 0)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            if store.page != 3 || store.artworkMode {
                HStack(spacing: 8) {
                    PageTurnerControl(page: $store.page, target: 1,
                                      systemName: "circle.fill", helpText: "Import")
                        .onTapGesture {
                            store.page = 1
                            store.artworkMode = false
                        }
                    
                    PageTurnerControl(page: $store.page, target: 2,
                                      systemName: "triangle.fill", helpText: "Choose")
                        .onTapGesture {
                            store.page = 2
                            store.artworkMode = false
                        }
                        .disabled(store.localUnit == nil)
                    
                    PageTurnerControl(page: $store.page, target: 3,
                                      systemName: "square.fill", helpText: "Match")
                        .onTapGesture {
                            store.page = 3
                        }
                        .disabled(store.localUnit == nil)
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
