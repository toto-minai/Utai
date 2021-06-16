//
//  PageTurner.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

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

struct PageTurner: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        VStack {
            Spacer()
            
            if store.page != 3 || store.artworkMode {
                HStack(spacing: 8) {
                    PageTurnerControl(page: $store.page, target: 1, systemName: "circle.fill", helpText: "Import")
                        .onTapGesture {
                            store.page = 1
                            store.artworkMode = false
                        }
                    
                    PageTurnerControl(page: $store.page, target: 2, systemName: "triangle.fill", helpText: "Choose")
                        .onTapGesture {
                            if store.page != 2 {
                                store.page = 2
                                store.artworkMode = false
                            }
                        }
                        .disabled(store.album == nil)
                    
                    PageTurnerControl(page: $store.page, target: 3, systemName: "square.fill", helpText: "Match")
                        .onTapGesture {
                        }
                }
                .padding(8)
                .background(PageTurnerBackground())
                .cornerRadius(4)
                
            }
        }
        .padding(.bottom, lilSpacing2x+lilIconLength)
        .animation(.easeOut, value: store.artworkMode)
    }
}

struct PageTurnerBackground: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        ZStack {
            Color.clear
            
            if store.page == 3 && store.artworkMode {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    
            }
        }
    }
}
